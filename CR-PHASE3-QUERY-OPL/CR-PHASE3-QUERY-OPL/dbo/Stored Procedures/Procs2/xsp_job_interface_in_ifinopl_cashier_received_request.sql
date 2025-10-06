/*
exec xsp_job_interface_in_ifinopl_cashier_received_request
*/
CREATE PROCEDURE dbo.xsp_job_interface_in_ifinopl_cashier_received_request
as

	declare @msg						nvarchar(max)
			,@row_to_process			int
			,@last_id_from_job			bigint
			,@id_interface				bigint
			,@code_sys_job				nvarchar(50)
			,@is_active					nvarchar(1)
			,@last_id					bigint		 = 0
			,@number_rows				int			 = 0
			,@code_interface			nvarchar(50)
			,@process_reff_no			nvarchar(50)
			,@process_reff_name			nvarchar(250)
			,@process_date				datetime
			,@mod_date					datetime	 = getdate()
			,@mod_by					nvarchar(15) = 'job'
			,@mod_ip_address			nvarchar(15) = '127.0.0.1'
			,@from_id					bigint			= 0
			,@request_status			nvarchar(10)
			,@current_mod_date			datetime
			,@voucher_no				nvarchar(50)
			,@doc_reff_code				nvarchar(50);
	begin try

		select	@code_sys_job		= code
				,@row_to_process	= row_to_process
				,@last_id_from_job	= last_id
				,@is_active			= is_active
		from	dbo.sys_job_tasklist
		where	sp_name = 'xsp_job_interface_in_ifinopl_cashier_received_request' -- sesuai dengan nama sp ini
		
		if (@is_active = '1')
		begin
			--get cashier received request
			declare curr_interface_cashier_received_request cursor for
							
				select 		id								
							,code
							,process_date
							,process_reff_no
							,process_reff_name
							,request_status
							,doc_reff_code
							,voucher_no
				from		dbo.opl_interface_cashier_received_request
				where		settle_date is null
							and (request_status in ('PAID','CANCEL') AND job_status in ('HOLD','FAILED'))
							or (request_status IN ('REVERSAL') and job_status in ('REVERSAL','FAILED'))
				order by	id asc offset 0 rows fetch next @row_to_process rows only ;

			open curr_interface_cashier_received_request
			fetch next from curr_interface_cashier_received_request 
			into @id_interface	
				 ,@code_interface	
				 ,@process_date		
				 ,@process_reff_no	
				 ,@process_reff_name 
				 ,@request_status
				 ,@doc_reff_code
				 ,@voucher_no
		
			while @@fetch_status = 0
			begin
				begin try
					begin transaction

						if (@number_rows = 0)
						begin
							set @from_id = @id_interface
						end
					
						if (@request_status = 'PAID')
						begin	
												
							exec dbo.xsp_opl_interface_cashier_received_request_paid @p_code				= @code_interface
																					,@p_process_date		= @process_date
																					,@p_process_reff_no		= @process_reff_no
																					,@p_process_reff_name	= @process_reff_name
																					,@p_doc_reff_code		= @doc_reff_code
																					,@p_voucher_no			= @voucher_no
																					--
																					,@p_mod_date			= @mod_date
																					,@p_mod_by				= @mod_by
																					,@p_mod_ip_address		= @mod_ip_address
					
						
						end
						else if (@request_status in ('CANCEL', 'REVERSAL'))
						begin
				
							exec dbo.xsp_opl_interface_cashier_received_request_cancel @p_code				  = @code_interface
																					   ,@p_process_date		  = @process_date
																					   ,@p_process_reff_no	  = @process_reff_no
																					   ,@p_process_reff_name  = @process_reff_name
																					   ,@p_doc_reff_code	  = @doc_reff_code
																					   --
																					   ,@p_mod_date			  = @mod_date
																					   ,@p_mod_by			  = @mod_by
																					   ,@p_mod_ip_address	  = @mod_ip_address 
																					   ,@p_request_status			= @request_status
						end
											
						set @number_rows =+ 1 ;
						set @last_id = @id_interface ;

						if (@request_status IN ( 'PAID','CANCEL'))
						begin	
							update	dbo.opl_interface_cashier_received_request
							set		settle_date			= getdate()
									,job_status			= 'POST'
									--
									,mod_date			= @mod_date
									,mod_by				= @mod_by
									,mod_ip_address		= @mod_ip_address
							where	code				= @code_interface
						END
						ELSE
						BEGIN
						    update	dbo.opl_interface_cashier_received_request
							set		settle_date			= NULL
									,job_status			= 'REVERSAL'
									--
									,mod_date			= @mod_date
									,mod_by				= @mod_by
									,mod_ip_address		= @mod_ip_address
							where	code				= @code_interface
						END
						
					commit transaction
				end try
				begin catch

					rollback transaction 
					set @msg = error_message();

					--cek poin
					update	dbo.opl_interface_cashier_received_request 
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
					close curr_interface_cashier_received_request ;
					deallocate curr_interface_cashier_received_request ;
			
					-- stop looping
					break

				end catch   
	
				fetch next from curr_interface_cashier_received_request
				into @id_interface					
					 ,@code_interface	
					 ,@process_date		
					 ,@process_reff_no	
					 ,@process_reff_name 
					 ,@request_status
					 ,@doc_reff_code
					 ,@voucher_no

			end ;
		
			begin -- close cursor
				if cursor_status('global', 'curr_interface_cashier_received_request') >= -1
				begin
					if cursor_status('global', 'curr_interface_cashier_received_request') > -1
					begin
						close curr_interface_cashier_received_request ;
					end ;

					deallocate curr_interface_cashier_received_request ;
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
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ; 
