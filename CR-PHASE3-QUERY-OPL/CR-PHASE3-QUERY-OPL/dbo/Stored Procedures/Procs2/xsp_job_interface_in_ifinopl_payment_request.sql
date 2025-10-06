CREATE procedure dbo.xsp_job_interface_in_ifinopl_payment_request
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
	
	begin try

		select	@code_sys_job		= code
				,@row_to_process	= row_to_process
				,@last_id_from_job	= last_id
				,@is_active			= is_active
		from	dbo.sys_job_tasklist
		where	sp_name = 'xsp_job_interface_in_ifinopl_payment_request' -- sesuai dengan nama sp ini

		if (@is_active = '1')
		begin
			--get payment request
			declare curr_interface_vat_payment cursor for

			select id
				  ,code
				  ,payment_source_no
				  ,payment_source
				  ,payment_status
				  ,process_date
				  ,process_reff_no
				  ,process_reff_name
			from dbo.opl_interface_payment_request
			where	payment_status in ('PAID', 'CANCEL')
			and		settle_date is null
			and		job_status in ('HOLD', 'FAILED')
			order by	id asc offset 0 rows fetch next @row_to_process rows only ;

			open curr_interface_vat_payment
			fetch next from curr_interface_vat_payment 
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
								if(@payment_source = 'VAT OUT FOR OPERATING LEASE')
								begin
									exec dbo.xsp_vat_payment_paid @p_code				= @payment_source_no
																  ,@p_process_reff_no	= @process_reff_no
																  ,@p_mod_date			= @mod_date
																  ,@p_mod_by			= @mod_by
																  ,@p_mod_ip_address	= @mod_ip_address
								end
								else if (@payment_source = 'WITHHOLDING FOR OPERATING LEASE')
								begin
									exec dbo.xsp_pph_payment_paid @p_code				= @payment_source_no
																  ,@p_process_reff_no	= @process_reff_no
																  ,@p_mod_date			= @mod_date
																  ,@p_mod_by			= @mod_by
																  ,@p_mod_ip_address	= @mod_ip_address
								end
							
						end
						else
						begin
								if (@payment_source = 'VAT OUT FOR OPERATING LEASE')
								begin
									--update vat_payment jadi HOLD
									update	dbo.invoice_vat_payment
									set		status				= 'HOLD'
											--
											,cre_date			= @mod_date
											,cre_by				= @mod_by
											,cre_ip_address		= @mod_ip_address
											,mod_date			= @mod_date
											,mod_by				= @mod_by
											,mod_ip_address		= @mod_ip_address
									where code = @payment_source_no
								end
								else if (@payment_source = 'WITHHOLDING FOR OPERATING LEASE')
								begin
									--update withholding jadi HOLD
									update	dbo.invoice_pph_payment
									set		status				= 'HOLD'
											--
											,cre_date			= @mod_date
											,cre_by				= @mod_by
											,cre_ip_address		= @mod_ip_address
											,mod_date			= @mod_date
											,mod_by				= @mod_by
											,mod_ip_address		= @mod_ip_address
									where code = @payment_source_no
								end	
						end			
			
						update dbo.opl_interface_payment_request
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
					update	dbo.opl_interface_payment_request 
					set		job_status		= 'FAILED'
							,settle_date	= @mod_date
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
					close curr_interface_vat_payment ;
					deallocate curr_interface_vat_payment ;
			
					-- stop looping
					break

				end catch   
	
				fetch next from curr_interface_vat_payment
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
				if cursor_status('global', 'curr_interface_vat_payment') >= -1
				begin
					if cursor_status('global', 'curr_interface_vat_payment') > -1
					begin
						close curr_interface_vat_payment ;
					end ;

					deallocate curr_interface_vat_payment ;
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
	Begin catch
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
