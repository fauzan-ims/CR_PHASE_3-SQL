CREATE PROCEDURE [dbo].[xsp_job_interface_pull_ifinams_ifinproc_document_upload]
AS
DECLARE @msg			   NVARCHAR(MAX)
		,@row_to_process   INT
		,@last_id_from_job BIGINT
		,@last_id		   BIGINT		= 0
		,@code_sys_job	   NVARCHAR(50)
		,@number_rows	   INT			= 0
		,@is_active		   NVARCHAR(1)
		,@id_interface	   BIGINT
		,@mod_date		   DATETIME		= GETDATE()
		,@mod_by		   NVARCHAR(15) = 'job'
		,@mod_ip_address   NVARCHAR(15) = '127.0.0.1' 
		,@current_mod_date	DATETIME
		,@from_id			BIGINT			= 0
		
	-- sesuai dengan nama sp ini
	SELECT	@row_to_process		= row_to_process
			,@last_id_from_job	= last_id
			,@code_sys_job		= code
			,@is_active			= is_active
	FROM	dbo.sys_job_tasklist
	WHERE	sp_name = 'xsp_job_interface_pull_ifinams_ifinproc_document_upload' ;

	IF(@is_active <> '0')
	BEGIN
	--get cashier received request
	DECLARE curr_handover_asset CURSOR FOR
	SELECT		id
	FROM		ifinproc.dbo.proc_interface_sys_document_upload
	WHERE		id > @last_id_from_job
				--and job_status = 'HOLD'
	ORDER BY	id ASC OFFSET 0 ROWS FETCH NEXT @row_to_process ROWS ONLY ;

	open curr_handover_asset ;

	fetch next from curr_handover_asset
	into @id_interface ;

	while @@fetch_status = 0
	begin
		begin try
			begin transaction 

			if (@number_rows = 0)
			begin
				set @from_id = @id_interface
			end

			insert into dbo.ams_interface_sys_document_upload
			(
				reff_no
				,reff_name
				,reff_trx_code
				,file_name
				,doc_file
				,job_status
				,failed_remark
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			SELECT reff_no
				  ,reff_name
				  ,reff_trx_code
				  ,file_name
				  ,cast(doc_file as varbinary(max)) 
				  ,'HOLD'
				  ,''
				  --
				  ,@mod_date
				  ,@mod_by
				  ,@mod_ip_address
				  ,@mod_date
				  ,@mod_by
				  ,@mod_ip_address
			FROM ifinproc.dbo.proc_interface_sys_document_upload
			WHERE	id = @id_interface ;

			set @number_rows = +1 ;
			set @last_id = @id_interface ;

			commit transaction ;
		end try
		begin catch
			rollback transaction ;

			set @msg = error_message();

			update dbo.ams_interface_sys_document_upload
			set		job_status		= 'FAILED'
					,failed_remark	= @msg
			where	id				= @id_interface

			/*insert into dbo.sys_job_tasklist_log*/
			set @current_mod_date = getdate();
			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code		= @code_sys_job
														,@p_status				= 'Error'
														,@p_start_date			= @mod_date
														,@p_end_date			= @current_mod_date --cek poin
														,@p_log_description		= @msg
														,@p_run_by				= @mod_by
														,@p_from_id				= @from_id  --cek poin
														,@p_to_id				= @id_interface --cek poin
														,@p_number_of_rows		= @number_rows --cek poin
														,@p_cre_date			= @current_mod_date--cek poin
														,@p_cre_by				= @mod_by
														,@p_cre_ip_address		= @mod_ip_address
														,@p_mod_date			= @current_mod_date--cek poin
														,@p_mod_by				= @mod_by
														,@p_mod_ip_address		= @mod_ip_address  ;


			-- clear cursor when error
			close curr_handover_asset ;
			deallocate curr_handover_asset ;

			-- stop looping
			break ;
		end catch ;

		fetch next from curr_handover_asset
		into @id_interface ;
	end ;

	begin -- close cursor
		if cursor_status('global', 'curr_handover_asset') >= -1
		begin
			if cursor_status('global', 'curr_handover_asset') > -1
			begin
				close curr_handover_asset ;
			end ;

			deallocate curr_handover_asset ;
		end ;
	end ;

	if (@last_id > 0)
	begin
		update dbo.sys_job_tasklist 
		set last_id = @last_id 
		where code = @code_sys_job

		/*insert into dbo.sys_job_tasklist_log*/
		set @current_mod_date = getdate();
		exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
												, @p_status				= 'Success'
												, @p_start_date			= @mod_date
												, @p_end_date			= @current_mod_date --cek poin
												, @p_log_description	= ''
												, @p_run_by				= @mod_by
												, @p_from_id			= @last_id --cek poin
												, @p_to_id				= @last_id --cek poin
												, @p_number_of_rows		= @number_rows --cek poin
												, @p_cre_date			= @current_mod_date --cek poin
												, @p_cre_by				= @mod_by
												, @p_cre_ip_address		= @mod_ip_address
												, @p_mod_date			= @current_mod_date --cek poin
												, @p_mod_by				= @mod_by
												, @p_mod_ip_address		= @mod_ip_address
					    
	end
end
