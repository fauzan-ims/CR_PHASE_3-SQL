/*
exec xsp_job_interface_in_ifinams_payment_request
*/
-- Louis Selasa, 14 Februari 2023 17.33.31 -- 
CREATE PROCEDURE dbo.xsp_job_interface_in_ifinams_payment_request
as
	declare @msg			     nvarchar(max)
			,@row_to_process		int
			,@last_id_from_job		bigint
			,@id_interface			bigint
			,@code					nvarchar(50)
			,@code_sys_job			nvarchar(50)
			,@is_active				nvarchar(1) 
			,@last_id				bigint	= 0 
			,@number_rows			int		= 0 
			,@reff_code				nvarchar(50)
			,@code_interface		nvarchar(50)
			,@application_no		nvarchar(50)
			,@payment_source_no		nvarchar(50) 
			,@payment_source		nvarchar(50) 
			,@process_date          datetime
			,@payment_status		nvarchar(10)
			,@process_reff_no       nvarchar(50)
			,@process_reff_name     nvarchar(250)
			,@mod_date				datetime		= getdate()
			,@mod_by				nvarchar(15)	= 'job'
			,@mod_ip_address		nvarchar(15)	= '127.0.0.1'
			,@from_id				bigint			= 0
			,@current_mod_date		datetime ;

	select	@code_sys_job		= code
			,@row_to_process	= row_to_process
			,@last_id_from_job	= last_id
			,@is_active			= is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_in_ifinams_payment_request' -- sesuai dengan nama sp ini

	if (@is_active = '1')
	begin
		--get payment request
		declare curr_interface_payment_request cursor for

		select id
			  ,code
			  ,payment_source_no
			  ,payment_source
			  ,payment_status
			  ,process_date
			  ,process_reff_no
			  ,process_reff_name
		from dbo.efam_interface_payment_request
		where	payment_status in ('PAID', 'CANCEL')
		and		settle_date is null
		and		job_status in ('HOLD', 'FAILED')
		order by	id asc offset 0 rows fetch next @row_to_process rows only ;

		open curr_interface_payment_request
		fetch next from curr_interface_payment_request 
		into @id_interface
			,@code
			,@payment_source_no
			,@payment_source
			,@payment_status
			,@process_date
			,@process_reff_no
			,@process_reff_name
		
		while @@fetch_status = 0
		begin
			begin try
				begin transaction
					if (@number_rows = 0)
					begin
						set @from_id = @id_interface
					end
					if @payment_status = 'PAID'
					begin    
							exec dbo.xsp_ams_interface_payment_request_paid @p_code				= @code
																			,@p_process_reff_no	= @process_reff_no	 
																			,@p_process_date	= @process_date	
																			,@p_cre_date		= @mod_date
																			,@p_cre_by			= @mod_by
																			,@p_cre_ip_address	= @mod_ip_address
																			,@p_mod_date		= @mod_date
																			,@p_mod_by			= @mod_by
																			,@p_mod_ip_address	= @mod_ip_address
							
							
					end
					else
					begin
							exec dbo.xsp_ams_interface_payment_request_cancel @p_code				= @code
																			  ,@p_cre_date			= @mod_date
																			  ,@p_cre_by			= @mod_by
																			  ,@p_cre_ip_address	= @mod_ip_address
																			  ,@p_mod_date			= @mod_date
																			  ,@p_mod_by			= @mod_by
																			  ,@p_mod_ip_address	= @mod_ip_address
							
					end			
			
					update dbo.efam_interface_payment_request
					set	job_status	 = 'POST'
						,settle_date = @mod_date
					where  id		 = @id_interface
					
					set @number_rows =+ 1
					set @last_id = @id_interface ;

				commit transaction
			end try
			begin catch

				rollback transaction 
				set @msg = error_message(); 
				--cek poin
				update	dbo.efam_interface_payment_request 
				set		job_status		= 'FAILED' 
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
				close curr_interface_payment_request ;
				deallocate curr_interface_payment_request ;
			
				-- stop looping
				break

			end catch   
	
			fetch next from curr_interface_payment_request
			into @id_interface
				,@code
				,@payment_source_no
				,@payment_source
				,@payment_status
				,@process_date
				,@process_reff_no
				,@process_reff_name

		end ;
		
		begin -- close cursor
			if cursor_status('global', 'curr_interface_payment_request') >= -1
			begin
				if cursor_status('global', 'curr_interface_payment_request') > -1
				begin
					close curr_interface_payment_request ;
				end ;

				deallocate curr_interface_payment_request ;
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
