
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_job_interface_in_ifinproc_final_grn_request]
as
declare @msg							nvarchar(max)
		,@row_to_process				int
		,@last_id_from_job				bigint
		,@id_interface					bigint
		,@procurement_request_code		nvarchar(50)
		,@code_sys_job					nvarchar(50)
		,@last_id						bigint		 = 0
		,@number_rows					int			 = 0
		,@is_active						nvarchar(1)
		,@purchase_request_code			nvarchar(50)
		,@remark						nvarchar(4000)
		,@req_date						datetime	
		,@mod_date						datetime		 = getdate()
		,@mod_by						nvarchar(15)	 = 'job'
		,@mod_ip_address				nvarchar(15)	 = '127.0.0.1'
		,@from_id						bigint		 = 0
		,@unit_code						nvarchar(50)
		,@unit_name						nvarchar(250)
		,@branch_code					nvarchar(50)
		,@branch_name					nvarchar(250)
		,@marketing_code				nvarchar(50)
		,@marketing_name				nvarchar(250)
		,@warehouse_code				nvarchar(50)
		,@procurement_code				nvarchar(50)
		,@current_mod_date				datetime
		,@purchase_request_remark		nvarchar(4000) 
		,@item_category_code			nvarchar(50)
		,@item_category_name			nvarchar(250)
		,@item_merk_code				nvarchar(50)
		,@item_merk_name				nvarchar(250)
		,@item_model_code				nvarchar(50)
		,@item_model_name				nvarchar(250)
		,@item_type_code				nvarchar(50)
		,@item_type_name				nvarchar(250)
		,@specification					nvarchar(4000)
		,@unit_from						nvarchar(25)
		,@categori_type					nvarchar(20)
		,@asset_no						nvarchar(50)
		,@spaf_amount					decimal(18,2)
		,@subvention_amount				decimal(18,2)
		,@to_province_code				nvarchar(50)	
		,@to_province_name				nvarchar(250)	
		,@to_city_code					nvarchar(50)	
		,@to_city_name					nvarchar(250)	
		,@to_area_phone_no				nvarchar(4)		
		,@to_phone_no					nvarchar(15)	
		,@to_address					nvarchar(4000)	
		,@procurement_type				nvarchar(50)
		,@mobilization_fa_code			nvarchar(50)
		,@mobilization_fa_name			nvarchar(250)
		,@asset_amount					decimal(18,2)
		,@asset_discount_amount			decimal(18,2)
		,@karoseri_amount				decimal(18,2)
		,@karoseri_discount_amount		decimal(18,2)
		,@accesories_amount				decimal(18,2)
		,@accesories_discount_amount	decimal(18,2)
		,@application_no				nvarchar(50)
		,@mobilization_amount			decimal(18,2)
		,@otr_amount					decimal(18,2)
		,@gps_amount					decimal(18,2)
		,@budget_amount					decimal(18,2)
		,@final_grn_request_no			nvarchar(50)
		,@delivery_to					nvarchar(4000)
		,@year							nvarchar(4)
		,@colour						nvarchar(50)
		,@bbn_name						nvarchar(250)
		,@bbn_location					nvarchar(4000)
		,@bbn_address					nvarchar(4000)

select	@code_sys_job		= code
		,@row_to_process	= row_to_process
		,@last_id_from_job	= last_id
		,@is_active			= is_active
from	dbo.sys_job_tasklist
where	sp_name				= 'xsp_job_interface_in_ifinproc_final_grn_request' ; -- sesuai dengan nama sp ini

if (@is_active <> '0')
begin
	--get cashier received request
	declare curr_purchase_request cursor for
	select		id
	from		dbo.proc_interface_final_request_grn
	where		job_status in
	(
		'HOLD', 'FAILED'
	)
	order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_purchase_request ;

	fetch next from curr_purchase_request
	into @id_interface

	while @@fetch_status = 0
	begin
		begin try
			begin transaction ;

			if (@number_rows = 0)
			begin
				set @from_id = @id_interface ;
			end ;

			insert into dbo.final_grn_request
			(
				final_grn_request_no
				,application_no
				,client_name
				,branch_code
				,branch_name
				,requestor_name
				,application_date
				,status
				,total_purchase_data
				,is_manual
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select final_request_no
				  ,application_no
				  ,client_name
				  ,branch_code
				  ,branch_name
				  ,requestor_name
				  ,application_date
				  ,'INCOMPLETE'
				  ,total_purchase_data
				  ,'0'
				  --
				  ,@mod_date
				  ,@mod_by
				  ,@mod_ip_address
				  ,@mod_date
				  ,@mod_by
				  ,@mod_ip_address 
			from dbo.proc_interface_final_request_grn
			where id = @id_interface

			select	@final_grn_request_no = final_request_no
			from	dbo.proc_interface_final_request_grn
			where	id = @id_interface ;

			declare curr_final_detail cursor fast_forward read_only for
			select	asset_no
					,delivery_to
					,year
					,colour
					,bbn_name
					,bbn_location
					,bbn_address
			from	dbo.proc_interface_final_grn_request_detail
			where	final_grn_request_no = @final_grn_request_no

			open curr_final_detail

			fetch next from curr_final_detail 
			into @asset_no
				,@delivery_to
				,@year
				,@colour
				,@bbn_name
				,@bbn_location
				,@bbn_address

			while @@fetch_status = 0
			begin
					insert into dbo.final_grn_request_detail
					(
						final_grn_request_no
						,asset_no
						,delivery_to
						,bbn_name
						,bbn_location
						,bbn_address
						,year
						,colour
						,po_code_asset
						,grn_code_asset
						,supplier_name_asset
						,grn_receive_date
						,status
						--
						,cre_date
						,cre_by
						,cre_ip_address
						,mod_date
						,mod_by
						,mod_ip_address
					)
					values
					(
						@final_grn_request_no
						,@asset_no
						,@delivery_to
						,@bbn_name
						,@bbn_location
						,@bbn_address
						,@year
						,@colour
						,''
						,''
						,''
						,null
						,'HOLD'
						--
						,@mod_date
						,@mod_by
						,@mod_ip_address
						,@mod_date
						,@mod_by
						,@mod_ip_address 
					)
			    fetch next from curr_final_detail 
				into @asset_no
					,@delivery_to
					,@year
					,@colour
					,@bbn_name
					,@bbn_location
					,@bbn_address
			end

			close curr_final_detail
			deallocate curr_final_detail


			set @number_rows = +1 ;
			set @last_id = @id_interface ;

			update	dbo.proc_interface_final_request_grn --cek poin
			set		job_status = 'POST'
			where	id = @id_interface ;

			commit transaction ;
		end try
		begin catch
			rollback transaction ;

			set @msg = error_message() ;

			update	dbo.proc_interface_final_request_grn --cek poin
			set		job_status = 'FAILED'
					,failed_remarks = @msg
			where	id = @id_interface ;

			print @msg ;

			--cek poin	

			/*insert into dbo.sys_job_tasklist_log*/
			set @current_mod_date = getdate() ;

			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
													 ,@p_status				= N'Error'
													 ,@p_start_date			= @mod_date
													 ,@p_end_date			= @current_mod_date --cek poin
													 ,@p_log_description	= @msg
													 ,@p_run_by				= @mod_by
													 ,@p_from_id			= @from_id --cek poin
													 ,@p_to_id				= @id_interface --cek poin
													 ,@p_number_of_rows		= @number_rows --cek poin
													 ,@p_cre_date			= @current_mod_date --cek poin
													 ,@p_cre_by				= @mod_by
													 ,@p_cre_ip_address		= @mod_ip_address
													 ,@p_mod_date			= @current_mod_date --cek poin
													 ,@p_mod_by				= @mod_by
													 ,@p_mod_ip_address		= @mod_ip_address ;

			-- clear cursor when error
			--close curr_purchase_request ;
			--deallocate curr_purchase_request ;

			-- stop looping
			--break ;
		end catch ;

		fetch next from curr_purchase_request
		into @id_interface

	end ;

	begin -- close cursor
		if cursor_status('global', 'curr_purchase_request') >= -1
		begin
			if cursor_status('global', 'curr_purchase_request') > -1
			begin
				close curr_purchase_request ;
			end ;

			deallocate curr_purchase_request ;
		end ;
	end ;

	if (@last_id > 0) --cek poin
	begin
		update	dbo.sys_job_tasklist
		set		last_id = @last_id
		where	code = @code_sys_job ;

		/*insert into dbo.sys_job_tasklist_log*/
		set @current_mod_date = getdate() ;

		exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
												 ,@p_status				= N'Success'
												 ,@p_start_date			= @mod_date
												 ,@p_end_date			= @current_mod_date --cek poin
												 ,@p_log_description	= ''
												 ,@p_run_by				= @mod_by
												 ,@p_from_id			= @from_id --cek poin
												 ,@p_to_id				= @id_interface --cek poin
												 ,@p_number_of_rows		= @number_rows --cek poin
												 ,@p_cre_date			= @current_mod_date --cek poin
												 ,@p_cre_by				= @mod_by
												 ,@p_cre_ip_address		= @mod_ip_address
												 ,@p_mod_date			= @current_mod_date --cek poin
												 ,@p_mod_by				= @mod_by
												 ,@p_mod_ip_address		= @mod_ip_address ; 
	end ;
end ;
