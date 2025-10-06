CREATE PROCEDURE dbo.xsp_job_interface_in_ifinams_new_asset
as
declare @msg							nvarchar(max)
		,@row_to_process				int
		,@last_id_from_job				bigint
		,@type_asset_code				nvarchar(50)
		,@id_interface					bigint
		,@code_sys_job					nvarchar(50)
		,@is_active						nvarchar(1)
		,@last_id						bigint		  = 0
		,@number_rows					int			  = 0
		,@mod_date						datetime	  = getdate()
		,@mod_by						nvarchar(15)  = N'job'
		,@mod_ip_address				nvarchar(15)  = N'127.0.0.1'
		,@from_id						bigint		  = 0
		,@current_mod_date				datetime
		,@is_success					nvarchar(1)	  = 0
		,@err_msg						nvarchar(4000)
		,@merk_code						nvarchar(50)
		,@model_code					nvarchar(50)
		,@request_code					nvarchar(50)
		,@type_code						nvarchar(50)
		,@item_code						nvarchar(50)
		,@purchase_price				decimal(18, 2)
		,@category_name					nvarchar(250)
		,@category_code					nvarchar(50)
		,@depre_cat_comm_code			nvarchar(50)
		,@depre_cat_fiscal_code			nvarchar(50)
		,@use_life						int
		,@amt_threshold					decimal(18, 2)
		,@value_type					nvarchar(50)
		,@is_valid						int
		,@is_depre						nvarchar(1)
		,@code							nvarchar(50)
		,@item_group_code				nvarchar(50)
		,@category_code_header			nvarchar(50)
		,@unit_from						nvarchar(50)
		,@is_maintenance				nvarchar(1)
		,@model_code_main				nvarchar(50)
		,@usefull						int
		,@rate							decimal(9, 6)
		,@posting_date					datetime	--(+) Ari 2024-03-26 ket : add posting date
		,@asset_code					nvarchar(50)
		,@depre_date_comm				datetime
		,@depre_date_fiscal				datetime
		,@rv							decimal(18, 2)
		,@orig_amount					decimal(18, 2)
		,@depreciation_date				datetime
		,@original_price_comm			decimal(18,2)
		,@depreciation_amount_comm		decimal(18,2)
		,@accum_depre_amount_comm		decimal(18,2)
		,@net_book_value_comm			decimal(18,2)
		,@transaction_code				nvarchar(50)
		,@original_price_fiscal			decimal(18,2)
		,@depreciation_amount_fiscal	decimal(18,2)
		,@accum_depre_amount_fiscal		decimal(18,2)
		,@net_book_value_fiscal			decimal(18,2)
		,@type							nvarchar(50)
		,@new_purchase_date				datetime
		,@post_date						datetime
		,@return_date					datetime
		,@invoice_type					nvarchar(50)

select	@code_sys_job		= code
		,@row_to_process	= row_to_process
		,@last_id_from_job	= last_id
		,@is_active			= is_active
from	dbo.sys_job_tasklist
where	sp_name				= 'xsp_job_interface_in_ifinams_new_asset' ; -- sesuai dengan nama sp ini

if (@is_active = '1')
begin
	--get approval request
	declare curr_asset cursor for
	select		id 
	from		dbo.ifinams_new_asset
	where		job_status in
	(
		'HOLD', 'FAILED'
	)
	order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_asset ;

	fetch next from curr_asset
	into @id_interface 
		

	while @@fetch_status = 0
	begin
		begin try
			set @is_success = '0' ;

			begin transaction ;

			if (@number_rows = 0)
			begin
				set @from_id = @id_interface ;
			end ;

			--Cek Apakah Depre atau tidak
			select @asset_code			= asset_code
					,@purchase_price	= purchase_price
					,@orig_amount		= orig_amount
					,@type				= type
					,@post_date			= posting_date
					,@return_date		= return_date
					,@invoice_type		= invoice_date_type
			from dbo.ifinams_new_asset
			where id = @id_interface

			if(@invoice_type = 'POST')
			begin
				update	dbo.asset
				set		invoice_post_date = @post_date
				where	code = @asset_code ;
			end
			else
			begin
				update	dbo.asset
				set		invoice_return_date = @return_date
				where	code = @asset_code ;
			end
			

			select @category_code_header = category_code 
			from dbo.asset
			where code = @asset_code

			select	@category_name					= mc.description -- temporary 
					,@amt_threshold					= depre_amount_threshold
					,@type_asset_code				= isnull(mc.asset_type_code,'')
					,@category_code					= mc.code
					,@depre_cat_comm_code			= mc.depre_cat_commercial_code
					,@depre_cat_fiscal_code			= mc.depre_cat_fiscal_code
					,@use_life						= mdcc.usefull
					,@amt_threshold					= mc.depre_amount_threshold
					,@value_type					= mc.value_type
			from	dbo.master_category mc
					inner join dbo.master_depre_category_commercial mdcc on mc.depre_cat_commercial_code = mdcc.code
			where	mc.code = @category_code_header

			if(@type = 'ASSET')
			begin

				-- jika unit from nya RENT maka tidak ter depre
				if(@unit_from =  'BUY')
				begin
					select @is_valid = dbo.xfn_depre_threshold_validation('DSF', @category_code, @purchase_price)
					if @is_valid = 1
					    set @is_depre = '1';
					else
					    set @is_depre = '0';

					set @is_maintenance = '1';
				end
				else
					set @is_maintenance = '0';
						
				--insert rv commercial
				select @rate = 100 - (usefull * rate)
				from dbo.master_depre_category_commercial
				where code = @depre_cat_comm_code
				
				set @rv = (@rate / 100 * @purchase_price)

				update dbo.asset
				set purchase_price			= @purchase_price
					,original_price			= @orig_amount 
					,net_book_value_comm	= @purchase_price
					,net_book_value_fiscal	= @purchase_price
					,residual_value			= @rv
					,total_depre_comm		= 0
					,total_depre_fiscal		= 0
					,depre_period_comm		= null
					,depre_period_fiscal	= null
				where code = @asset_code
			
				--tampung depre schedule yang sudah terdepre
				declare curr_temp_depre cursor fast_forward read_only for
				select	comm.depreciation_date
						,comm.original_price
						,comm.depreciation_amount
						,comm.accum_depre_amount
						,comm.net_book_value
						,comm.transaction_code
						,fisc.original_price
						,fisc.depreciation_amount
						,fisc.accum_depre_amount
						,fisc.net_book_value
				from	dbo.asset_depreciation_schedule_commercial		  comm
						inner join dbo.asset_depreciation_schedule_fiscal fisc on comm.asset_code			  = fisc.asset_code
																				  and  comm.depreciation_date = fisc.depreciation_date
				where	comm.asset_code						  = @asset_code
						and isnull(comm.transaction_code, '') <> '' ;

				open curr_temp_depre
				
				fetch next from curr_temp_depre 
				into @depreciation_date
					,@original_price_comm
					,@depreciation_amount_comm
					,@accum_depre_amount_comm
					,@net_book_value_comm
					,@transaction_code
					,@original_price_fiscal
					,@depreciation_amount_fiscal
					,@accum_depre_amount_fiscal
					,@net_book_value_fiscal
				
				while @@fetch_status = 0
				begin
			    exec dbo.xsp_temp_asset_schedule_commercial_insert @p_id					= 0
			    												   ,@p_asset_code			= @asset_code
			    												   ,@p_depreciation_date	= @depreciation_date
			    												   ,@p_original_price		= @original_price_comm
			    												   ,@p_depreciation_amount	= @depreciation_amount_comm
			    												   ,@p_accum_depre_amount	= @accum_depre_amount_comm
			    												   ,@p_net_book_value		= @net_book_value_comm
			    												   ,@p_transaction_code		= @transaction_code
																   ,@p_status				= 'HOLD'
			    												   ,@p_date					= @mod_date
																   --
			    												   ,@p_cre_date				= @mod_date
			    												   ,@p_cre_by				= @mod_by
			    												   ,@p_cre_ip_address		= @mod_ip_address
			    												   ,@p_mod_date				= @mod_date
			    												   ,@p_mod_by				= @mod_by
			    												   ,@p_mod_ip_address		= @mod_ip_address
				
				exec dbo.xsp_temp_asset_schedule_fiscal_insert @p_id					= 0
															   ,@p_asset_code			= @asset_code
															   ,@p_depreciation_date	= @depreciation_date
															   ,@p_original_price		= @original_price_fiscal
															   ,@p_depreciation_amount	= @depreciation_amount_fiscal
															   ,@p_accum_depre_amount	= @accum_depre_amount_fiscal
															   ,@p_net_book_value		= @net_book_value_fiscal
															   ,@p_transaction_code		= @transaction_code
															   ,@p_date					= @mod_date
															   --
															   ,@p_cre_date				= @mod_date
															   ,@p_cre_by				= @mod_by
															   ,@p_cre_ip_address		= @mod_ip_address
															   ,@p_mod_date				= @mod_date
															   ,@p_mod_by				= @mod_by
															   ,@p_mod_ip_address		= @mod_ip_address
				
			    
			
			    fetch next from curr_temp_depre 
				into @depreciation_date
					,@original_price_comm
					,@depreciation_amount_comm
					,@accum_depre_amount_comm
					,@net_book_value_comm
					,@transaction_code
					,@original_price_fiscal
					,@depreciation_amount_fiscal
					,@accum_depre_amount_fiscal
					,@net_book_value_fiscal
			end
				
				close curr_temp_depre
				deallocate curr_temp_depre

				-- delete schedule depre
				delete dbo.asset_depreciation_schedule_commercial where asset_code = @asset_code
				delete dbo.asset_depreciation_schedule_fiscal where asset_code = @asset_code
				
				--generate ulang schedule depre
				exec dbo.xsp_asset_depreciation_schedule_commercial_generate @p_code			 = @asset_code
																			 ,@p_mod_date		 = @mod_date	  
																			 ,@p_mod_by			 = @mod_by		  
																			 ,@p_mod_ip_address	 = @mod_ip_address

				exec dbo.xsp_asset_depreciation_schedule_fiscal_generate @p_code			 = @asset_code
																		 ,@p_mod_date		 = @mod_date	  
																		 ,@p_mod_by			 = @mod_by		
																		 ,@p_mod_ip_address	 = @mod_ip_address

				select @depre_date_comm =  min(depreciation_date) 
				from dbo.asset_depreciation_schedule_commercial
				where asset_code = @asset_code

				select @depre_date_fiscal =  min(depreciation_date) 
				from dbo.asset_depreciation_schedule_fiscal
				where asset_code = @asset_code

				if(@depre_date_comm <> @depre_date_fiscal)
				begin
					set @msg = 'The start date of depreciation between Commercial and Fiscal must be the same';
					raiserror(@msg ,16,-1);	
				end
			end
			else
			begin
				select		top 1
							@new_purchase_date = new_purchase_date
				from		dbo.adjustment
				where		asset_code		= @asset_code
							and adjust_type <> 'INVOICE'
				order by	cre_date desc ;

				--tampung depre schedule yang sudah terdepre
				declare curr_temp_depre cursor fast_forward read_only for
				select	comm.depreciation_date
						,comm.original_price
						,comm.depreciation_amount
						,comm.accum_depre_amount
						,comm.net_book_value
						,comm.transaction_code
						,fisc.original_price
						,fisc.depreciation_amount
						,fisc.accum_depre_amount
						,fisc.net_book_value
				from	dbo.asset_depreciation_schedule_commercial		  comm
						inner join dbo.asset_depreciation_schedule_fiscal fisc on comm.asset_code			  = fisc.asset_code
																				  and  comm.depreciation_date = fisc.depreciation_date
				where	comm.asset_code						  = @asset_code
						and isnull(comm.transaction_code, '') <> ''
						and comm.depreciation_date >= @new_purchase_date

				open curr_temp_depre
				
				fetch next from curr_temp_depre 
				into @depreciation_date
					,@original_price_comm
					,@depreciation_amount_comm
					,@accum_depre_amount_comm
					,@net_book_value_comm
					,@transaction_code
					,@original_price_fiscal
					,@depreciation_amount_fiscal
					,@accum_depre_amount_fiscal
					,@net_book_value_fiscal
				
				while @@fetch_status = 0
				begin
					exec dbo.xsp_temp_asset_schedule_commercial_insert @p_id					= 0
																	   ,@p_asset_code			= @asset_code
																	   ,@p_depreciation_date	= @depreciation_date
																	   ,@p_original_price		= @original_price_comm
																	   ,@p_depreciation_amount	= @depreciation_amount_comm
																	   ,@p_accum_depre_amount	= @accum_depre_amount_comm
																	   ,@p_net_book_value		= @net_book_value_comm
																	   ,@p_transaction_code		= @transaction_code
																	   ,@p_status				= 'HOLD'
																	   ,@p_date					= @mod_date
																	   --
																	   ,@p_cre_date				= @mod_date
																	   ,@p_cre_by				= @mod_by
																	   ,@p_cre_ip_address		= @mod_ip_address
																	   ,@p_mod_date				= @mod_date
																	   ,@p_mod_by				= @mod_by
																	   ,@p_mod_ip_address		= @mod_ip_address
					
					exec dbo.xsp_temp_asset_schedule_fiscal_insert @p_id					= 0
																   ,@p_asset_code			= @asset_code
																   ,@p_depreciation_date	= @depreciation_date
																   ,@p_original_price		= @original_price_fiscal
																   ,@p_depreciation_amount	= @depreciation_amount_fiscal
																   ,@p_accum_depre_amount	= @accum_depre_amount_fiscal
																   ,@p_net_book_value		= @net_book_value_fiscal
																   ,@p_transaction_code		= @transaction_code
																   ,@p_date					= @mod_date
																   --
																   ,@p_cre_date				= @mod_date
																   ,@p_cre_by				= @mod_by
																   ,@p_cre_ip_address		= @mod_ip_address
																   ,@p_mod_date				= @mod_date
																   ,@p_mod_by				= @mod_by
																   ,@p_mod_ip_address		= @mod_ip_address
					
					
			
					fetch next from curr_temp_depre 
					into @depreciation_date
						,@original_price_comm
						,@depreciation_amount_comm
						,@accum_depre_amount_comm
						,@net_book_value_comm
						,@transaction_code
						,@original_price_fiscal
						,@depreciation_amount_fiscal
						,@accum_depre_amount_fiscal
						,@net_book_value_fiscal
				end
				
				close curr_temp_depre
				deallocate curr_temp_depre

				update	dbo.asset_depreciation_schedule_commercial
				set		transaction_code = ''
				where	asset_code			  = @asset_code
						and depreciation_date >= @new_purchase_date ;

				update	dbo.asset
				set		original_price = original_price + @orig_amount
				where	code = @asset_code ;
			end


			set @number_rows = +1 ;
			set @last_id = @id_interface ;

			update	dbo.ifinams_new_asset --cek poin
			set		job_status		= 'POST'
			where	id				= @id_interface ;

			commit transaction ;

			set @is_success = '1' ;	
		end try
		begin catch
			rollback transaction ;

			set @is_success = '0' ;
			set @msg = error_message() ;
			set @current_mod_date = getdate() ;

			update	dbo.efam_interface_asset --cek poin
			set		job_status			= 'FAILED'
					,failed_remarks		= @msg
			where	id					= @id_interface ; --cek poin	

			/*insert into dbo.sys_job_tasklist_log*/
			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
													 ,@p_status				= N'Error'
													 ,@p_start_date			= @mod_date
													 ,@p_end_date			= @current_mod_date --cek poin
													 ,@p_log_description	= @msg
													 ,@p_run_by				= 'job'
													 ,@p_from_id			= @from_id --cek poin
													 ,@p_to_id				= @id_interface --cek poin
													 ,@p_number_of_rows		= @number_rows --cek poin
													 ,@p_cre_date			= @current_mod_date --cek poin
													 ,@p_cre_by				= N'job'
													 ,@p_cre_ip_address		= N'127.0.0.1'
													 ,@p_mod_date			= @current_mod_date --cek poin
													 ,@p_mod_by				= N'job'
													 ,@p_mod_ip_address		= N'127.0.0.1' ;
		end catch ;

		fetch next from curr_asset
		into @id_interface 
			 ,@type_code
			 ,@request_code
	end ;

	begin -- close cursor
		if cursor_status('global', 'curr_asset') >= -1
		begin
			if cursor_status('global', 'curr_asset') > -1
			begin
				close curr_asset ;
			end ;

			deallocate curr_asset ;
		end ;
	end ;

	if (@last_id > 0) --cek poin
	begin
		set @current_mod_date = getdate() ;

		update	dbo.sys_job_tasklist
		set		last_id = @last_id
		where	code = @code_sys_job ;

		/*insert into dbo.sys_job_tasklist_log*/
		exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
												 ,@p_status				= 'Success'
												 ,@p_start_date			= @mod_date
												 ,@p_end_date			= @current_mod_date --cek poin
												 ,@p_log_description	= ''
												 ,@p_run_by				= 'job'
												 ,@p_from_id			= @from_id --cek poin
												 ,@p_to_id				= @last_id --cek poin
												 ,@p_number_of_rows		= @number_rows --cek poin
												 ,@p_cre_date			= @current_mod_date --cek poin
												 ,@p_cre_by				= 'job'
												 ,@p_cre_ip_address		= '127.0.0.1'
												 ,@p_mod_date			= @current_mod_date --cek poin
												 ,@p_mod_by				= 'job'
												 ,@p_mod_ip_address		= '127.0.0.1' ;
	end ;
end ;
