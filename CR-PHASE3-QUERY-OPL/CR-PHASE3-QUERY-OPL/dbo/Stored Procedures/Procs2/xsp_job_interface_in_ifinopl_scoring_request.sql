/*
exec xsp_job_interface_in_ifinopl_scoring_request
*/
CREATE PROCEDURE dbo.xsp_job_interface_in_ifinopl_scoring_request
as

	declare @msg					   nvarchar(max)
			,@row_to_process		   int
			,@last_id_from_job		   bigint
			,@id_interface			   bigint
			,@code_sys_job			   nvarchar(50)
			,@is_active				   nvarchar(1)
			,@last_id				   bigint		 = 0
			,@number_rows			   int			 = 0
			,@reff_code				   nvarchar(50)
			,@code_interface		   nvarchar(50)
			,@scoring_result_date	   datetime
			,@scoring_result_value	   nvarchar(250)
			,@scoring_result_grade	   nvarchar(50)
			,@scoring_result_remarks   nvarchar(4000)
			,@scoring_result_status	   nvarchar(10)
			,@mod_date				   datetime		 = getdate()
			,@mod_by				   nvarchar(15)	 = 'job'
			,@mod_ip_address		   nvarchar(15)	 = '127.0.0.1'
			,@from_id				   bigint		 = 0
			,@current_mod_date		   datetime ;

	select	@code_sys_job		= code
			,@row_to_process	= row_to_process
			,@last_id_from_job	= last_id
			,@is_active			= is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_in_ifinopl_scoring_request' -- sesuai dengan nama sp ini

	if (@is_active = '1')
	begin
		--get cashier received request
		declare curr_interface_scoring_request cursor for
		
			select		id
						,scoring_result_date
						,scoring_result_value
						,scoring_result_grade
						,scoring_result_remarks
						,status
						,reff_code
						,code
			from		dbo.opl_interface_scoring_request
			where		settle_date is null
						and status in ('POST', 'CANCEL')
						and job_status in ('HOLD','FAILED')
			order by	id asc offset 0 rows fetch next @row_to_process rows only ;

		open curr_interface_scoring_request
		fetch next from curr_interface_scoring_request 
		into @id_interface
			 ,@scoring_result_date
			 ,@scoring_result_value
			 ,@scoring_result_grade
			 ,@scoring_result_remarks
			 ,@scoring_result_status
			 ,@reff_code
			 ,@code_interface ;
		
		while @@fetch_status = 0
		begin
			begin try
				begin transaction

					if (@number_rows = 0)
					begin
						set @from_id = @id_interface
					end
				
					if exists (select 1 from dbo.application_scoring_request where code = @reff_code)
					begin
						update	dbo.application_scoring_request
						set		scoring_result_date		= @scoring_result_date
								,scoring_result_value	= @scoring_result_value
								,scoring_result_grade	= @scoring_result_grade
								,scoring_result_remarks	= @scoring_result_remarks
								,scoring_status			= @scoring_result_status
								,mod_date				= @mod_date
								,mod_by					= @mod_by
								,mod_ip_address			= @mod_ip_address
						where	code					= @reff_code ;
					end 

					set @number_rows =+ 1 ;
						set @last_id = @id_interface ;
				
					update	dbo.opl_interface_scoring_request
					set		settle_date		= getdate()
							,job_status		= 'POST'
							--
							,mod_date		= @mod_date
							,mod_by			= @mod_by
							,mod_ip_address	= @mod_ip_address
					where	code			= @code_interface

				commit transaction
			end try
			begin catch

				rollback transaction 
				set @msg = error_message();

				--cek poin
				update	dbo.opl_interface_scoring_request 
				set		job_status = 'FAILED'
						,failed_remarks = @msg
				where	id = @id_interface 
				
				/*insert into dbo.sys_job_tasklist_log*/
				set @current_mod_date = getdate();
				exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code		= @code_sys_job
															,@p_status				= N'Error'
															,@p_start_date			= @mod_date
															,@p_end_date			= @current_mod_date
															,@p_log_description		= @msg
															,@p_run_by				= @mod_by
															,@p_from_id				= @from_id  
															,@p_to_id				= @id_interface 
															,@p_number_of_rows		= @number_rows 
															,@p_cre_date			= @current_mod_date
															,@p_cre_by				= @mod_by		
															,@p_cre_ip_address		= @mod_ip_address
															,@p_mod_date			= @current_mod_date
															,@p_mod_by				= @mod_by		
															,@p_mod_ip_address		= @mod_ip_address  ;

				-- clear cursor when error
				close curr_interface_scoring_request ;
				deallocate curr_interface_scoring_request ;
			
				-- stop looping
				break

			end catch   
	
			fetch next from curr_interface_scoring_request
			into @id_interface
					,@scoring_result_date
					,@scoring_result_value
					,@scoring_result_grade
					,@scoring_result_remarks
					,@scoring_result_status
					,@reff_code
					,@code_interface ;

		end ;
		
		begin -- close cursor
			if cursor_status('global', 'curr_interface_scoring_request') >= -1
			begin
				if cursor_status('global', 'curr_interface_scoring_request') > -1
				begin
					close curr_interface_scoring_request ;
				end ;

				deallocate curr_interface_scoring_request ;
			end ;
		end ;
		
		--cek poin
		if (@last_id > 0)
		begin
			update dbo.sys_job_tasklist 
			set last_id = @last_id 
			where code = @code_sys_job
		
			/*insert into dbo.sys_job_tasklist_log*/
			set @current_mod_date = getdate();
			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
													,@p_status				= 'Success'
													,@p_start_date			= @mod_date
													,@p_end_date			= @current_mod_date 
													,@p_log_description		= ''
													,@p_run_by				= @mod_by
													,@p_from_id				= @from_id 
													,@p_to_id				= @last_id 
													,@p_number_of_rows		= @number_rows 
													,@p_cre_date			= @mod_date		
													,@p_cre_by				= @mod_by		
													,@p_cre_ip_address		= @mod_ip_address
													,@p_mod_date			= @mod_date		
													,@p_mod_by				= @mod_by		
													,@p_mod_ip_address		= @mod_ip_address
					    
		end
	end
