
-- Stored Procedure

/*
exec xsp_job_interface_in_ifinams_asset_update_ongrn 
*/ 
CREATE PROCEDURE [dbo].[xsp_job_interface_in_ifinams_asset_update_ongrn]
as
declare @msg								nvarchar(max)
		,@row_to_process					int
		,@last_id_from_job					bigint
		,@type_asset_code					nvarchar(50)
		,@id_interface						bigint
		,@code_sys_job						nvarchar(50)
		,@is_active							nvarchar(1)
		,@last_id							bigint		= 0
		,@number_rows						int			= 0
		,@mod_date							datetime		= getdate()
		,@mod_by							nvarchar(15) = 'job'
		,@mod_ip_address					nvarchar(15) = '127.0.0.1'
		,@from_id							bigint		= 0
		,@current_mod_date					datetime
		,@unit_from							nvarchar(50)
		,@cover_note						nvarchar(50)
		,@cover_note_date					datetime
		,@cover_exp_date					datetime
		,@cover_file_name					nvarchar(250)
		,@cover_file_path					nvarchar(250)
		--
		,@asset_code						nvarchar(50)
		,@is_success						nvarchar(1)	= 0
		,@model_code_main					nvarchar(50)

select	@code_sys_job = code
		,@row_to_process = row_to_process
		,@last_id_from_job = last_id
		,@is_active = is_active
from	dbo.sys_job_tasklist
where	sp_name = 'xsp_job_interface_in_ifinams_asset_update_ongrn' ; -- sesuai dengan nama sp ini

if (@is_active = '1')
begin
	--get approval request
	declare curr_asset cursor for
	select		id 
				,code
	from		dbo.efam_interface_asset_update_ongrn
	where		job_status in
	(
		'HOLD', 'FAILED'
	)
	order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_asset ;

	fetch next from curr_asset
	into @id_interface 
		 ,@asset_code

	while @@fetch_status = 0
	begin
		begin try
			set @is_success = '0' ;

			begin transaction ;

			if (@number_rows = 0)
			begin
				set @from_id = @id_interface ;
			end ;

			begin

				select	@unit_from			= asset_from
				from	dbo.asset
				where	code = @asset_code

				update dbo.asset
				set		status = 'HOLD'
				where	code = @asset_code

				-- jika unit from nya Buy maka generate maintenance schedule
				if(@unit_from =  'BUY')
				begin
					select	@model_code_main	= model_code
					from	dbo.asset_vehicle
					where	asset_code			= @asset_code ;

					exec dbo.xsp_schedule_maintenance_asset_generate_master @p_code				= @asset_code                  
																			,@p_model_code		= @model_code_main       
																			,@p_cre_by			= @mod_by 
																			,@p_cre_date		= @mod_date
																			,@p_cre_ip_address	= @mod_ip_address
																			,@p_mod_by			= @mod_by
																			,@p_mod_date		= @mod_date
																			,@p_mod_ip_address	= @mod_ip_address ;				
				end

				-- Data dari PROC langsung di proceed dan post
				exec dbo.xsp_asset_proceed @p_code				= @asset_code
										   ,@p_mod_date			= @mod_date
										   ,@p_mod_by			= @mod_by
										   ,@p_mod_ip_address	= @mod_ip_address

				select	@cover_note				= cover_note
						,@cover_note_date		= cover_note_date
						,@cover_exp_date		= cover_exp_date
						,@cover_file_name		= file_name
						,@cover_file_path		= file_path
				from	dbo.efam_interface_asset
				where	code = @asset_code

				exec dbo.xsp_asset_post @p_code					= @asset_code
										,@p_cover_note			= @cover_note
										,@p_cover_note_date		= @cover_note_date
										,@p_cover_exp_date		= @cover_exp_date
										,@p_cover_file_name		= @cover_file_name
										,@p_cover_file_path		= @cover_file_path
										,@p_mod_date			= @mod_date
										,@p_mod_by				= @mod_by
										,@p_mod_ip_address		= @mod_ip_address
			end

			set @number_rows = +1 ;
			set @last_id = @id_interface ;

			update	dbo.efam_interface_asset_update_ongrn --cek poin
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

			update	dbo.efam_interface_asset_update_ongrn --cek poin
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
			 ,@asset_code
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
