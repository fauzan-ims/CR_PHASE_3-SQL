/*
created by, Rian at 05/07/2023 

exec xsp_job_interface_in_ifinopl_interface_asset_vehicle_update
*/
CREATE procedure dbo.xsp_job_interface_in_ifinopl_interface_asset_vehicle_update
as
declare @msg				nvarchar(max)
		,@row_to_process	int
		,@last_id_from_job	bigint
		,@id_interface		bigint
		,@code_sys_job		nvarchar(50)
		,@last_id			bigint		= 0
		,@number_rows		int			= 0
		,@is_active			nvarchar(1)
		,@fa_code			nvarchar(50)
		,@fa_reff_no_1		nvarchar(50)
		,@fa_reff_no_2		nvarchar(50)
		,@fa_reff_no_3		nvarchar(50)
		,@from_id			bigint		= 0
		,@asset_no			nvarchar(50) 
		,@current_mod_date	datetime
		,@mod_date			datetime		 = getdate()
		,@mod_by			nvarchar(15)	 = 'job'
		,@mod_ip_address	nvarchar(15)	 = '127.0.0.1'

select	@code_sys_job		= code
		,@row_to_process	= row_to_process
		,@last_id_from_job	= last_id
		,@is_active			= is_active
from	dbo.sys_job_tasklist
where	sp_name = 'xsp_job_interface_in_ifinopl_interface_asset_vehicle_update' ; -- sesuai dengan nama sp ini

if (@is_active <> '0')
begin
	declare c_purchase_order cursor for
	select		id
				,fa_code
				,fa_reff_no_1
				,fa_reff_no_2
				,fa_reff_no_3
	from		dbo.opl_interface_asset_vehicle_update
	where		job_status in
	(
		'HOLD', 'FAILED'
	)
	order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open	c_purchase_order ;

	fetch	c_purchase_order
	into	@id_interface
			,@fa_code		
			,@fa_reff_no_1	
			,@fa_reff_no_2	
			,@fa_reff_no_3	

	while @@fetch_status = 0
	begin
		begin try
			begin transaction ;

			if (@number_rows = 0)
			begin
				set @from_id = @id_interface ;
			end ;

			update	dbo.application_asset
			set		fa_reff_no_01	= @fa_reff_no_1
					,fa_reff_no_02	= @fa_reff_no_2
					,fa_reff_no_03	= @fa_reff_no_3
					--
					,mod_date		= @mod_date
					,mod_by			= @mod_by
					,mod_ip_address	= @mod_ip_address
			where	fa_code			= @fa_code ;

			update	dbo.agreement_asset
			set		fa_reff_no_01	= @fa_reff_no_1
					,fa_reff_no_02	= @fa_reff_no_2
					,fa_reff_no_03	= @fa_reff_no_3
					--
					,mod_date		= @mod_date
					,mod_by			= @mod_by
					,mod_ip_address	= @mod_ip_address
			where	fa_code			= @fa_code ;

			set @number_rows = +1 ;
			set @last_id = @id_interface ;

			update	dbo.opl_interface_asset_vehicle_update --cek poin
			set		job_status = 'POST'
			where	id = @id_interface ;

			commit transaction ;
		end try
		begin catch
			rollback transaction ;

			set @msg = error_message() ;

			update	dbo.opl_interface_asset_vehicle_update --cek poin
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
		end catch ;

		fetch	c_purchase_order
		into	@id_interface
				,@fa_code		
				,@fa_reff_no_1	
				,@fa_reff_no_2	
				,@fa_reff_no_3	
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

		exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code = @code_sys_job
												 ,@p_status = N'Success'
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
end ;
