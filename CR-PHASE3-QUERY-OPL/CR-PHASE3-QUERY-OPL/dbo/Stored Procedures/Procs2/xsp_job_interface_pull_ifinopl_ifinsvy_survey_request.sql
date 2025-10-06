/*
exec xsp_job_interface_pull_ifinopl_ifinsvy_survey_request
*/
CREATE PROCEDURE dbo.xsp_job_interface_pull_ifinopl_ifinsvy_survey_request
as
	declare @msg					nvarchar(max)
			,@row_to_process		int
			,@last_id_from_job		bigint
			,@last_id				bigint		  = 0
			,@code_sys_job			nvarchar(50)
			,@number_rows			int			  = 0
			,@is_active				nvarchar(1)
			,@id_interface			bigint
			,@code_interface		nvarchar(50)
			,@process_reff_no		nvarchar(50)
			,@process_reff_name		nvarchar(250)
			,@process_date			datetime
			,@mod_date				datetime	  = getdate()
			,@mod_by				nvarchar(15)  = 'job'
			,@mod_ip_address		nvarchar(15)  = '127.0.0.1'
			,@reff_code				nvarchar(50)
			,@survey_result_date	datetime
			,@survey_result_value	nvarchar(250)
			,@survey_result_remarks nvarchar(4000)
			,@survey_result_status	nvarchar(10)
			,@current_mod_date		datetime
			,@from_id				bigint		  = 0 ;

	select	@row_to_process		= row_to_process
			,@last_id_from_job	= last_id
			,@code_sys_job	    = code
			,@is_active = is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_pull_ifinopl_ifinsvy_survey_request' -- sesuai dengan nama sp ini
	
if(@is_active <> '0')
begin
	--get cashier received request
	declare curr_survey_request cursor for

		select 		fcrr.id
					,fcrr.code
					,fcrr.process_date
					,fcrr.process_reff_no
					,fcrr.process_reff_name
					,fcrr.survey_result_date
					,fcrr.survey_result_value
					,fcrr.survey_result_remarks
					,fcrr.status
					,pcrr.reff_code
		from		ifinsvy.dbo.svy_interface_survey_request fcrr
					inner join dbo.opl_interface_survey_request pcrr on (pcrr.code = fcrr.code)
		where		fcrr.status in  ('POST', 'CANCEL')
					and pcrr.status = 'HOLD'
		order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_survey_request
			
	fetch next from curr_survey_request 
	into @id_interface
		 ,@code_interface
		 ,@process_date
		 ,@process_reff_no
		 ,@process_reff_name
		 ,@survey_result_date	
		 ,@survey_result_value	
		 ,@survey_result_remarks
		 ,@survey_result_status 
		 ,@reff_code
		
	while @@fetch_status = 0
	begin
		begin try
			begin transaction

			if (@number_rows = 0)
			begin
				set @from_id = @id_interface ;
			end ;

			update	dbo.opl_interface_survey_request
			set		status					= @survey_result_status
					,process_date			= @process_date
					,process_reff_no		= @process_reff_no
					,process_reff_name		= @process_reff_name
					,survey_result_date		= @survey_result_date	
					,survey_result_value	= @survey_result_value	
					,survey_result_remarks	= @survey_result_remarks 
					,mod_date				= @mod_date
					,mod_by					= @mod_by
					,mod_ip_address			= @mod_ip_address
			where	code					= @code_interface
			
			set @number_rows =+ 1 ;
			set @last_id = @id_interface ;

			commit transaction
		end try
		begin catch
			rollback transaction 

			 --cek poin
			set @msg = error_message() ;
			/*insert into dbo.sys_job_tasklist_log*/
			set @current_mod_date = getdate() ;
			
			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
													 ,@p_status				= N'Error'
													 ,@p_start_date			= @mod_date
													 ,@p_end_date			= @current_mod_date
													 ,@p_log_description	= @msg
													 ,@p_run_by				= @mod_by
													 ,@p_from_id			= @from_id 
													 ,@p_to_id				= @id_interface
													 ,@p_number_of_rows		= @number_rows
													 ,@p_cre_date			= @current_mod_date 
													 ,@p_cre_by				= @mod_by
													 ,@p_cre_ip_address		= @mod_ip_address
													 ,@p_mod_date			= @current_mod_date 
													 ,@p_mod_by				= @mod_by
													 ,@p_mod_ip_address		= @mod_ip_address  ;
			
			-- clear cursor when error
			close curr_survey_request ;
			deallocate curr_survey_request ;
			
			-- stop looping
			break ;
		end catch ;  
	
		fetch next from curr_survey_request
		into	@id_interface
				,@code_interface
				,@process_date
				,@process_reff_no
				,@process_reff_name
			    ,@survey_result_date	
			    ,@survey_result_value	
			    ,@survey_result_remarks
				,@survey_result_status 
				,@reff_code

	end ;
		
	begin -- close cursor
		if cursor_status('global', 'curr_survey_request') >= -1
		begin
			if cursor_status('global', 'curr_survey_request') > -1
			begin
				close curr_survey_request ;
			end ;

			deallocate curr_survey_request ;
		end ;
	end ;

	--cek poin
	if (@last_id > 0)
	begin
		update	dbo.sys_job_tasklist
		set		last_id = @last_id
		where	code = @code_sys_job ;

		/*insert into dbo.sys_job_tasklist_log*/
		set @current_mod_date = getdate() ;
		
		exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
												 ,@p_status				= 'Success'
												 ,@p_start_date			= @mod_date
												 ,@p_end_date			= @current_mod_date
												 ,@p_log_description	= ''
												 ,@p_run_by				= @mod_by
												 ,@p_from_id			= @from_id
												 ,@p_to_id				= @last_id
												 ,@p_number_of_rows		= @number_rows
												 ,@p_cre_date			= @current_mod_date
												 ,@p_cre_by				= @mod_by
												 ,@p_cre_ip_address		= @mod_ip_address
												 ,@p_mod_date			= @current_mod_date
												 ,@p_mod_by				= @mod_by
												 ,@p_mod_ip_address		= @mod_ip_address
	end ;
end
