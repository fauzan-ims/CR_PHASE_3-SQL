/*
exec xsp_job_interface_in_ams_approval_request
*/
CREATE PROCEDURE dbo.xsp_job_interface_in_ams_approval_request
AS

	DECLARE @msg			     NVARCHAR(MAX)
			,@row_to_process		INT
			,@last_id_from_job		BIGINT
			,@id_interface			BIGINT 
			,@code_sys_job			NVARCHAR(50)
			,@is_active				NVARCHAR(1) 
			,@last_id				BIGINT	= 0 
			,@number_rows			INT		= 0 
			,@reff_no				NVARCHAR(50)
			,@approval_status		NVARCHAR(250)
			,@approval_code			NVARCHAR(50)
			,@request_status		NVARCHAR(250)
			,@mod_date				DATETIME		= GETDATE()
			,@mod_by				NVARCHAR(15)	= 'job'
			,@mod_ip_address		NVARCHAR(15)	= '127.0.0.1' 
			,@from_id				BIGINT			= 0
			,@current_mod_date		DATETIME ;

	select	@code_sys_job		= code
			,@row_to_process	= row_to_process
			,@last_id_from_job	= last_id
			,@is_active			= is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_in_ams_approval_request' -- sesuai dengan nama sp ini
	
	if (@is_active = '1')
	begin
		--get approval request
		declare curr_interface_approval_request cursor for
		select		id
					,code
					,approval_status
					,approval_category_code
					,request_status
		from		dbo.ams_interface_approval_request
		where		settle_date is null
					and request_status = 'POST'
					and isnull(approval_status, '') <> ''
					and job_status in ('HOLD','FAILED')
		order by	id asc offset 0 rows fetch next @row_to_process rows only ;

		open curr_interface_approval_request
		fetch next from curr_interface_approval_request 
		into  @id_interface	  
			  ,@reff_no		  
			  ,@approval_status 
			  ,@approval_code	  
			  ,@request_status ;
		
		while @@fetch_status = 0
		begin
			begin try
				begin transaction

					if (@number_rows = 0)
					begin
						set @from_id = @id_interface
					end

					if (@approval_status = 'APPROVE')
					begin
						exec dbo.xsp_ams_interface_approval_request_approve @p_code					= @reff_no
																			,@p_approval_status		= @approval_status
																			,@p_approval_code		= @approval_code
																			,@p_request_status		= @request_status
																			,@p_mod_date			= @mod_date		
																			,@p_mod_by				= @mod_by		
																			,@p_mod_ip_address		= @mod_ip_address
						
					end
					else if (@approval_status = 'RETURN')
					begin
						exec dbo.xsp_ams_interface_approval_request_return @p_code					= @reff_no
																		   ,@p_approval_status		= @approval_status
																		   ,@p_approval_code		= @approval_code
																		   ,@p_request_status		= @request_status
																		   ,@p_mod_date				= @mod_date		
																		   ,@p_mod_by				= @mod_by		
																		   ,@p_mod_ip_address		= @mod_ip_address
					end
					else if (@approval_status = 'REJECT')
					begin
						exec dbo.xsp_ams_interface_approval_request_reject @p_code					= @reff_no
																		   ,@p_approval_status		= @approval_status
																		   ,@p_approval_code		= @approval_code
																		   ,@p_request_status		= @request_status
																		   ,@p_mod_date				= @mod_date		
																		   ,@p_mod_by				= @mod_by		
																		   ,@p_mod_ip_address		= @mod_ip_address
					end
				
				
					set @number_rows =+ 1 ;
					set @last_id = @id_interface ;

					--cek poin
					update	dbo.ams_interface_approval_request
					set		settle_date		= getdate()
							,job_status		= 'POST'
							--
							,mod_date		= @mod_date		
							,mod_by			= @mod_by		
							,mod_ip_address	= @mod_ip_address
					where	code			= @reff_no

				commit transaction
			end try
			begin catch

				rollback transaction 
				set @msg = error_message();

				--cek poin
				update	dbo.ams_interface_approval_request 
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

				---- clear cursor when error
				--close curr_interface_approval_request ;
				--deallocate curr_interface_approval_request ;
			
				---- stop looping
				--break

			end catch   
	
			fetch next from curr_interface_approval_request
			into  @id_interface	  
				  ,@reff_no		  
				  ,@approval_status 
				  ,@approval_code	  
				  ,@request_status ;

		end ;
		
		begin -- close cursor
			if cursor_status('global', 'curr_interface_approval_request') >= -1
			begin
				if cursor_status('global', 'curr_interface_approval_request') > -1
				begin
					close curr_interface_approval_request ;
				end ;

				deallocate curr_interface_approval_request ;
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


