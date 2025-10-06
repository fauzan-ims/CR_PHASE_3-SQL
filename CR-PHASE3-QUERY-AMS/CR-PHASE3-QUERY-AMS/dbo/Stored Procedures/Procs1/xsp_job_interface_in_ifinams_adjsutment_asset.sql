-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_job_interface_in_ifinams_adjsutment_asset]
as
declare @msg						nvarchar(max)
		,@row_to_process			int
		,@id_interface				bigint
		,@code_sys_job				nvarchar(50)
		,@last_id					bigint		= 0
		,@number_rows				int			= 0
		,@is_active					nvarchar(1)
		,@mod_date					datetime		= getdate()
		,@mod_by					nvarchar(15) = 'job'
		,@mod_ip_address			nvarchar(15) = '127.0.0.1'
		,@from_id					bigint		= 0
		,@code_header				nvarchar(50)
		,@branch_code				nvarchar(50)
		,@branch_name				nvarchar(250)
		,@adjust_date				datetime
		,@fa_code					nvarchar(50)
		,@fa_name					nvarchar(250)
		,@division_code				nvarchar(50)
		,@division_name				nvarchar(250)
		,@department_code			nvarchar(50)
		,@department_name			nvarchar(250)
		,@net_book_value_comm		decimal(18,2)
		,@net_book_value_fiscal		decimal(18,2)
		,@purchase_price			decimal(18,2)
		,@original_price			decimal(18,2)
		,@vendor_code				nvarchar(50)
		,@vendor_name				nvarchar(250)
		,@adjustment_amount			decimal(18,2)
		,@new_nbv_comm				decimal(18,2)
		,@new_nbv_fiscal			decimal(18,2)
		,@current_mod_date			datetime
		,@item_name					nvarchar(250)
		,@type_asset				nvarchar(15)
		,@uom						nvarchar(15)
		,@quantity					int
		,@adjust_type				nvarchar(50)
		,@is_from_proc				nvarchar(1)
		,@is_final_grn				nvarchar(1)

begin try
select	@code_sys_job = code
		,@row_to_process = row_to_process
		,@is_active = is_active
from	dbo.sys_job_tasklist
where	sp_name = 'xsp_job_interface_in_ifinams_adjsutment_asset' ; -- sesuai dengan nama sp ini

if (@is_active <> '0')
begin
	--get cashier received request
	declare curr_adjustment_asset cursor for
	select		id
				,branch_code
				,branch_name
				,isnull(date,cre_date)
				,fa_code
				,fa_name
				,division_code
				,division_code
				,department_code
				,department_name
				,isnull(adjustment_amount,0)
				,item_name
				,type_asset
				,uom
				,quantity
				,adjust_type
				,isnull(is_from_proc,'0')
	from		dbo.ams_interface_adjustment_asset
	where		job_status IN
							(
								'HOLD', 'FAILED'
							)
	and			fa_code in (select code from dbo.asset)
	order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_adjustment_asset ;

	fetch next from curr_adjustment_asset
	into @id_interface
		,@branch_code
		,@branch_name
		,@adjust_date
		,@fa_code
		,@fa_name
		,@division_code
		,@division_name
		,@department_code
		,@department_name
		,@adjustment_amount
		,@item_name
		,@type_asset
		,@uom
		,@quantity
		,@adjust_type
		,@is_from_proc

	while @@fetch_status = 0
	begin
		begin try
			begin transaction ;

			if (@number_rows = 0)
			begin
				set @from_id = @id_interface ;
			end ;

			--insert ke adjustment
			select	@net_book_value_comm	= isnull(net_book_value_comm,0)
					,@net_book_value_fiscal	= isnull(net_book_value_fiscal,0)
					,@purchase_price		= isnull(purchase_price,0)
					,@original_price		= isnull(original_price,0)
					,@vendor_code			= vendor_code
					,@vendor_name			= vendor_name
					,@is_final_grn			= is_final_grn
			from dbo.asset
			where code = @fa_code
			-- set @new_nbv_comm	= isnull(@net_book_value_comm,0) + isnull(@adjustment_amount,0)
			-- set @new_nbv_fiscal = isnull(@net_book_value_fiscal,0) + isnull(@adjustment_amount,0)

			if(@type_asset = 'MULTIPLE' and @is_final_grn <> '0')
			begin
				set @new_nbv_comm	= @net_book_value_comm
				set @new_nbv_fiscal = @net_book_value_fiscal
			end
			else
			begin
				set @new_nbv_comm	= @net_book_value_comm + @adjustment_amount
				set @new_nbv_fiscal = @net_book_value_fiscal + @adjustment_amount
			end

			exec dbo.xsp_adjustment_insert @p_code							= @code_header output
										   ,@p_company_code					= 'DSF'
										   ,@p_branch_code					= @branch_code
										   ,@p_branch_name					= @branch_name
										   ,@p_date							= @mod_date
										   ,@p_new_purchase_date			= @adjust_date
										   ,@p_asset_code					= @fa_code
										   ,@p_old_netbook_value_fiscal		= @net_book_value_fiscal
										   ,@p_old_netbook_value_comm		= @net_book_value_comm
										   ,@p_new_netbook_value_fiscal		= @new_nbv_fiscal
										   ,@p_new_netbook_value_comm		= @new_nbv_comm
										   ,@p_total_adjustment				= @adjustment_amount
										   ,@p_payment_by					= 'HO'
										   ,@p_vendor_code					= @vendor_code
										   ,@p_vendor_name					= @vendor_name
										   ,@p_remark						= 'ADJUSTMENT FROM PROCUREMENT'
										   ,@p_status						= 'HOLD'
										   ,@p_adjust_type					= @adjust_type
										   --
										   ,@p_cre_date						= @mod_date
										   ,@p_cre_by						= @mod_by
										   ,@p_cre_ip_address				= @mod_ip_address
										   ,@p_mod_date						= @mod_date
										   ,@p_mod_by						= @mod_by
										   ,@p_mod_ip_address				= @mod_ip_address
										   ,@p_is_from_proc					= @is_from_proc

			exec dbo.xsp_adjustment_detail_insert @p_id								= 0
												  ,@p_adjustment_code				= @code_header
												  ,@p_adjusment_transaction_code	= null
												  ,@p_adjustment_description		= @item_name
												  ,@p_amount						= @adjustment_amount
												  ,@p_uom							= @uom
												  ,@p_quantity						= @quantity
												  ,@p_cre_date						= @mod_date
												  ,@p_cre_by						= @mod_by
												  ,@p_cre_ip_address				= @mod_ip_address
												  ,@p_mod_date						= @mod_date
												  ,@p_mod_by						= @mod_by
												  ,@p_mod_ip_address				= @mod_ip_address


			if(@type_asset = 'MULTIPLE' and @is_final_grn <> '0')



			begin
				update	dbo.adjustment
				set		status = 'POST'
				where	code = @code_header
			end
			else
			begin
				-- langsung di proceed
				exec dbo.xsp_adjustment_proceed @p_code				= @code_header
												,@p_mod_date		= @mod_date
												,@p_mod_by			= @mod_by
												,@p_mod_ip_address	= @mod_ip_address

				-- langsung di post
				exec dbo.xsp_adjustment_post @p_code				= @code_header
											 ,@p_mod_date			= @mod_date
											 ,@p_mod_by				= @mod_by
											 ,@p_mod_ip_address		= @mod_ip_address
			end

			set @number_rows = +1 ;
			set @last_id = @id_interface ;

			update	dbo.ams_interface_adjustment_asset --cek poin
			set		job_status = 'POST'
			where	id = @id_interface ;

			commit transaction ;
		end try
		begin catch
			rollback transaction ;

			set @msg = error_message() ;

			update	dbo.ams_interface_adjustment_asset --cek poin
			set		job_status = 'FAILED'
					,failed_remarks = @msg
			where	id = @id_interface ;

			print @msg
			--cek poin	

			/*insert into dbo.sys_job_tasklist_log*/
			set @current_mod_date = getdate() ;

			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code = @code_sys_job
													 ,@p_status = N'Error'
													 ,@p_start_date = @mod_date
													 ,@p_end_date = @current_mod_date --cek poin
													 ,@p_log_description = @msg
													 ,@p_run_by = @mod_by
													 ,@p_from_id = @from_id --cek poin
													 ,@p_to_id = @id_interface --cek poin
													 ,@p_number_of_rows = @number_rows --cek poin
													 ,@p_cre_date = @current_mod_date --cek poin
													 ,@p_cre_by = @mod_by
													 ,@p_cre_ip_address = @mod_ip_address
													 ,@p_mod_date = @current_mod_date --cek poin
													 ,@p_mod_by = @mod_by
													 ,@p_mod_ip_address = @mod_ip_address ;

			-- clear cursor when error
			close curr_adjustment_asset ;
			deallocate curr_adjustment_asset ;

			-- stop looping
			break ;
		end catch ;

		fetch next from curr_adjustment_asset
		into @id_interface
			,@branch_code
			,@branch_name
			,@adjust_date
			,@fa_code
			,@fa_name
			,@division_code
			,@division_name
			,@department_code
			,@department_name
			,@adjustment_amount
			,@item_name
			,@type_asset
			,@uom
			,@quantity
			,@adjust_type
			,@is_from_proc
	end ;

	begin -- close cursor
		if cursor_status('global', 'curr_adjustment_asset') >= -1
		begin
			if cursor_status('global', 'curr_adjustment_asset') > -1
			begin
				close curr_adjustment_asset ;
			end ;

			deallocate curr_adjustment_asset ;
		end ;
	end ;

	if (@last_id > 0) --cek poin
	begin
		update	dbo.sys_job_tasklist
		set		last_id = @last_id
		where	code = @code_sys_job ;

		/*insert into dbo.sys_job_tasklist_log*/
		set @current_mod_date = getdate() ;

		exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code = @code_sys_job
												 ,@p_status = 'Success'
												 ,@p_start_date = @mod_date
												 ,@p_end_date = @current_mod_date --cek poin
												 ,@p_log_description = ''
												 ,@p_run_by = @mod_by
												 ,@p_from_id = @from_id --cek poin
												 ,@p_to_id = @id_interface --cek poin
												 ,@p_number_of_rows = @number_rows --cek poin
												 ,@p_cre_date = @current_mod_date --cek poin
												 ,@p_cre_by = @mod_by
												 ,@p_cre_ip_address = @mod_ip_address
												 ,@p_mod_date = @current_mod_date --cek poin
												 ,@p_mod_by = @mod_by
												 ,@p_mod_ip_address = @mod_ip_address ;
	end ;
	end
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;	

