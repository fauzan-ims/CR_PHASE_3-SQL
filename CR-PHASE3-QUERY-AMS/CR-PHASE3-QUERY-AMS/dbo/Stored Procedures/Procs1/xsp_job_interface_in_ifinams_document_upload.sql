CREATE PROCEDURE [dbo].[xsp_job_interface_in_ifinams_document_upload]
as
declare @msg			   nvarchar(max)
		,@row_to_process   int
		,@id_interface	   bigint
		,@code_sys_job	   nvarchar(50)
		,@last_id		   bigint		= 0
		,@number_rows	   int			= 0
		,@is_active		   nvarchar(1)
		,@mod_date		   datetime		= getdate()
		,@mod_by		   nvarchar(15) = 'job'
		,@mod_ip_address   nvarchar(15) = '127.0.0.1'
		,@from_id		   bigint		= 0
		,@current_mod_date datetime ;

begin try
	select	@code_sys_job = code
			,@row_to_process = row_to_process
			,@is_active = is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_in_ifinams_document_upload' ; -- sesuai dengan nama sp ini    

	if (@is_active <> '0')
	begin
		--get cashier received request    
		declare curr_handover_asset cursor for
		select		id
		from		dbo.ams_interface_sys_document_upload
		where		job_status in
		(
			'HOLD', 'FAILED'
		)
		order by	id asc offset 0 rows fetch next @row_to_process rows only ;

		open curr_handover_asset ;

		fetch next from curr_handover_asset
		into @id_interface ;

		while @@fetch_status = 0
		begin
			begin try
				begin transaction ;

				if (@number_rows = 0)
				begin
					set @from_id = @id_interface ;
				end ;

				insert into dbo.sys_document_upload
				(
					reff_no
					,reff_name
					,reff_trx_code
					,file_name
					,doc_file
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select	reff_no
						,reff_name
						,reff_trx_code
						,file_name
						,doc_file
						,cre_date
						,cre_by
						,cre_ip_address
						,mod_date
						,mod_by
						,mod_ip_address
				from	dbo.ams_interface_sys_document_upload
				where	id = @id_interface ;


				--insert into dbo.asset_document
				--(
				--	asset_code
				--	,document_code
				--	,document_no
				--	,description
				--	,file_name
				--	,file_path
				--	--
				--	,cre_date
				--	,cre_by
				--	,cre_ip_address
				--	,mod_date
				--	,mod_by
				--	,mod_ip_address
				--)
				--select reff_trx_code
				--	  ,''
				--	  ,''
				--	  ,reff_trx_code
				--	  ,file_name
				--	  ,doc_file
				--	  --
				--	  ,cre_date
				--	  ,cre_by
				--	  ,cre_ip_address
				--	  ,mod_date
				--	  ,mod_by
				--	  ,mod_ip_address 
				--from dbo.ams_interface_sys_document_upload
				--where id = @id_interface

				set @number_rows = +1 ;
				set @last_id = @id_interface ;

				update	dbo.ams_interface_sys_document_upload --cek poin    
				set		job_status = 'POST'
				where	id = @id_interface ;

				commit transaction ;
			end try
			begin catch
				rollback transaction ;

				set @msg = error_message() ;

				update	dbo.ams_interface_handover_asset --cek poin    
				set		job_status = 'FAILED'
						,failed_remarks = @msg
				where	id = @id_interface ;

				print @msg ;

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
	end ;
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
		if (
			   error_message() like '%V;%'
			   or	error_message() like '%E;%'
		   )
		begin
			set @msg = error_message() ;
		end ;
		else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;
	end ;

	raiserror(@msg, 16, -1) ;

	return ;
end catch ;
