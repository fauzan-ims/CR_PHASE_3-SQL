/*
exec xsp_job_interface_in_ifinams_cashier_received_request
*/
-- Louis Rabu, 08 Februari 2023 13.54.42 -- 
CREATE PROCEDURE dbo.xsp_job_interface_in_ifinams_cashier_received_request
as

	declare @msg					   nvarchar(max)	
			,@row_to_process		   int
			,@id_interface		       bigint 
			,@code					   nvarchar(50)
			,@code_sys_job			   nvarchar(50)
			,@last_id				   bigint		= 0 
			,@last_id_from_job		   bigint 		
			,@number_rows			   int			= 0 
			,@process_reff_name		   nvarchar(250) 
			,@process_date             datetime
		    ,@process_reff_no          nvarchar(50)
			,@is_active				   nvarchar(1)
			,@from_id				   bigint		= 0
			,@current_mod_date		   datetime
			,@request_status		   nvarchar(10)
			,@mod_date			       datetime		= getdate()
			,@mod_by			       nvarchar(15)	= 'job'
			,@mod_ip_address	       nvarchar(15)	= '127.0.0.1' ;

	select	@code_sys_job		= code
			,@last_id_from_job	= last_id
			,@row_to_process	= row_to_process
			,@is_active			= is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_in_ifinams_cashier_received_request' -- sesuai dengan nama sp ini

	if (@is_active = '1')
	begin
		declare curr_ifinamscrr cursor for
			select 		id
						,code
						,request_status
			from		dbo.ams_interface_cashier_received_request
			where		request_status in ('PAID','CANCEL')
						and settle_date is null
						and job_status in ('HOLD','FAILED')
			order by	id asc offset 0 rows fetch next @row_to_process rows only ;

		open curr_ifinamscrr
		fetch next from curr_ifinamscrr 
		into @id_interface
			 ,@code
			 ,@request_status
	
		while @@fetch_status = 0
		begin
			begin try
				begin transaction

				if (@number_rows = 0)
				begin
					set @from_id = @id_interface
				end 

				if @request_status = 'PAID'
				begin
					exec dbo.xsp_ams_interface_cashier_received_request_paid @p_code				= @code 
																			 --
																			 ,@p_cre_date			= @mod_date		
																			 ,@p_cre_by				= @mod_by		
																			 ,@p_cre_ip_address		= @mod_ip_address
																			 ,@p_mod_date			= @mod_date		
																			 ,@p_mod_by				= @mod_by		
																			 ,@p_mod_ip_address		= @mod_ip_address
				end
				else
				begin
					exec dbo.xsp_ams_interface_cashier_received_request_cancel @p_code				= @code
					                                                           ,@p_cre_date			= @mod_date		
																			   ,@p_cre_by			= @mod_by		
																			   ,@p_cre_ip_address	= @mod_ip_address
																			   ,@p_mod_date			= @mod_date		
																			   ,@p_mod_by			= @mod_by		
																			   ,@p_mod_ip_address	= @mod_ip_address
					
				end
						
				set @number_rows =+ 1
				set @last_id = @id_interface 

				update dbo.ams_interface_cashier_received_request
				set    settle_date = @mod_date
				       ,job_status = 'POST'
					   ,failed_remarks = ''
				where  id		   = @id_interface
			
				commit transaction
			end try
			begin catch

				rollback transaction 

				set @msg = error_message();
				
				update	dbo.ams_interface_cashier_received_request  --cek poin
				set		job_status = 'FAILED'
						,failed_remarks = @msg
				where	id = @id_interface --cek poin

				/*insert into dbo.sys_job_tasklist_log*/
				set	@current_mod_date = getdate();
				exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code		= @code_sys_job
																,@p_status				= N'Error'
																,@p_start_date			= @mod_date
																,@p_end_date			= @current_mod_date --cek poin
																,@p_log_description		= @msg
																,@p_run_by				= 'job'
																,@p_from_id				= @from_id  --cek poin
																,@p_to_id				= @id_interface --cek poin
																,@p_number_of_rows		= @number_rows --cek poin
																,@p_cre_date			= @current_mod_date--cek poin
																,@p_cre_by				= N'job'
																,@p_cre_ip_address		= N'127.0.0.1'
																,@p_mod_date			= @current_mod_date--cek poin
																,@p_mod_by				= N'job'
																,@p_mod_ip_address		= N'127.0.0.1'  ;

				
			end catch   
	
			fetch next from curr_ifinamscrr
			into @id_interface
				 ,@code
				 ,@request_status

		end ;
		
		begin -- close cursor
			if cursor_status('global', 'curr_ifinamscrr') >= -1
			begin
				if cursor_status('global', 'curr_ifinamscrr') > -1
				begin
					close curr_ifinamscrr ;
				end ;

				deallocate curr_ifinamscrr ;
			end ;
		end ;

		if (@last_id > 0)--cek poin
		begin
			update dbo.sys_job_tasklist 
			set last_id = @last_id 
			where code = @code_sys_job
		
			/*insert into dbo.sys_job_tasklist_log*/
			set	@current_mod_date = getdate();
			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
													, @p_status				= 'Success'
													, @p_start_date			= @mod_date
													, @p_end_date			= @current_mod_date --cek poin
													, @p_log_description	= ''
													, @p_run_by				= 'job'
													, @p_from_id			= @from_id --cek poin
													, @p_to_id				= @last_id --cek poin
													, @p_number_of_rows		= @number_rows --cek poin
													, @p_cre_date			= @current_mod_date --cek poin
													, @p_cre_by				= 'job'
													, @p_cre_ip_address		= '127.0.0.1'
													, @p_mod_date			= @current_mod_date --cek poin
													, @p_mod_by				= 'job'
													, @p_mod_ip_address		= '127.0.0.1'
					    
		end
	end
