/*
	created : Nia, 23 Sept 2021
*/
CREATE PROCEDURE dbo.xsp_job_interface_in_ifinfin_deposit_allocation
as

	declare @msg			        nvarchar(max)
			,@id_interface	        bigint --cursor
			,@row_to_process        int
			,@code_sys_job	        nvarchar(50)
			,@last_id		        bigint		= 0
			,@last_id_from_job      bigint 
			,@number_rows	        int		= 0
			,@row_count		        int        = 0
			,@is_active			    nvarchar(1)
			,@current_mod_date	    datetime
			,@mod_date		        datetime = getdate()
			,@mod_by		        nvarchar(50) = 'Job'
		    ,@mod_ip_address        nvarchar(50) = '127.0.0.1'
			,@from_id			    bigint			= 0
			,@deposit_gl_link_code	nvarchar(50)
			,@deposit_type			nvarchar(15)
			,@code					nvarchar(50); 
							     
		select	@row_to_process     = row_to_process
				,@last_id_from_job	= last_id
				,@code_sys_job	    = code
				,@is_active			= is_active
		from	dbo.sys_job_tasklist
		where	sp_name = 'xsp_job_interface_in_ifinfin_deposit_allocation'

		if (@is_active = '1')
		begin
			declare curr_depositallocation cursor for

				select 	id
						,deposit_type
						,code
				from	dbo.fin_interface_deposit_allocation
				where	job_status in ('HOLD','FAILED')
				order by id asc offset 0 rows fetch next @row_to_process rows only;

			open curr_depositallocation	
			fetch next from curr_depositallocation 
			into @id_interface
				 ,@deposit_type
				 ,@code
		
			while @@fetch_status = 0
			begin
				begin try
					begin transaction 
						if (@number_rows = 0)
						begin
							set @from_id = @id_interface
						end

						if(@deposit_type = 'INSTALLMENT')
						begin
							select	@deposit_gl_link_code = gl_link_code 
							from	dbo.master_transaction
							where	code = 'DPINST'
						end  
						else if(@deposit_type = 'INSURANCE')
						begin
							select	@deposit_gl_link_code = gl_link_code 
							from	dbo.master_transaction
							where	code = 'DPINSI'
						end  
						else
						begin
							select	@deposit_gl_link_code = gl_link_code 
							from	dbo.master_transaction
							where	code = 'DPOTH'
						end 

						insert into dbo.deposit_allocation
						(
							code
							,branch_code
							,branch_name
							,allocation_status
							,allocation_trx_date
							,allocation_value_date
							,allocation_orig_amount
							,allocation_currency_code
							,allocation_exch_rate
							,allocation_base_amount
							,allocationt_remarks
							,agreement_no
							,deposit_code
							,deposit_type
							,deposit_amount
							,deposit_gl_link_code
							,is_received_request
							,reversal_code
							,reversal_date
							,cre_date
							,cre_by
							,cre_ip_address
							,mod_date
							,mod_by
							,mod_ip_address
						)
						select	code
								,branch_code
								,branch_name
								,status
								,trx_date
								,trx_date
								,orig_amount
								,currency_code
								,exch_rate
								,base_amount
								,remark
								,agreement_no
								,deposit_code
								,deposit_type
								,deposit_amount
								,@deposit_gl_link_code
								,'0'
								,null
								,null
								,@mod_date
								,@mod_by		
								,@mod_ip_address 
								,@mod_date		
								,@mod_by		
								,@mod_ip_address  
						from  dbo.fin_interface_deposit_allocation
						where id = @id_interface

						insert into dbo.DEPOSIT_ALLOCATION_DETAIL
						(
						    DEPOSIT_ALLOCATION_CODE,
						    TRANSACTION_CODE,
						    RECEIVED_REQUEST_CODE,
						    IS_PAID,
						    INNITIAL_AMOUNT,
						    ORIG_AMOUNT,
						    ORIG_CURRENCY_CODE,
						    EXCH_RATE,
						    BASE_AMOUNT,
						    INSTALLMENT_NO,
						    REMARKS,
						    CRE_DATE,
						    CRE_BY,
						    CRE_IP_ADDRESS,
						    MOD_DATE,
						    MOD_BY,
						    MOD_IP_ADDRESS
						)
						SELECT FIN_INTERFACE_DEPOSIT_ALLOCATION_CODE
                               ,TRANSACTION_CODE
							   ,null       
							   ,'0'                        
							   ,INNITIAL_AMOUNT
                               ,ORIG_AMOUNT
                               ,ORIG_CURRENCY_CODE
                               ,EXCH_RATE
                               ,BASE_AMOUNT
                               ,INSTALLMENT_NO
                               ,REMARK
                               ,@mod_date
							   ,@mod_by		
							   ,@mod_ip_address 
							   ,@mod_date		
							   ,@mod_by		
							   ,@mod_ip_address 
						from dbo.FIN_INTERFACE_DEPOSIT_ALLOCATION_DETAIL
						where FIN_INTERFACE_DEPOSIT_ALLOCATION_CODE = @code

						set @number_rows =+ 1
						set @last_id = @id_interface ;

						update	dbo.fin_interface_deposit_allocation  --cek poin
						set		job_status = 'POST'
								,FAILED_REMARK = ''
						where	id = @id_interface	

					commit transaction 
				end try
				begin catch
			
					rollback transaction 
			
					set @msg = error_message();
					set @current_mod_date = getdate();

					update	dbo.fin_interface_deposit_allocation  --cek poin
					set		job_status = 'FAILED'
							,failed_remark = @msg
					where	id = @id_interface --cek poin	

					/*insert into dbo.sys_job_tasklist_log*/
					exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
															 ,@p_status				= N'Error'
															 ,@p_start_date			= @mod_date
															 ,@p_end_date			= @current_mod_date --cek poin
															 ,@p_log_description	= @msg
															 ,@p_run_by				= 'job'
															 ,@p_from_id			= @from_id  --cek poin
															 ,@p_to_id				= @id_interface --cek poin
															 ,@p_number_of_rows		= @number_rows --cek poin
															 ,@p_cre_date			= @current_mod_date--cek poin
															 ,@p_cre_by				= N'job'
															 ,@p_cre_ip_address		= N'127.0.0.1'
															 ,@p_mod_date			= @current_mod_date--cek poin
															 ,@p_mod_by				= N'job'
															 ,@p_mod_ip_address		= N'127.0.0.1'  ;

				end catch   
	
				fetch next from curr_depositallocation
				into @id_interface
					 ,@deposit_type
					 ,@code
			end

			begin -- close cursor
				if cursor_status('global', 'curr_depositallocation') >= -1
				begin
					if cursor_status('global', 'curr_depositallocation') > -1
					begin
						close curr_depositallocation ;
					end ;

					deallocate curr_depositallocation ;
				end ;
			end ;

	
		if (@last_id > 0)--cek poin
		begin
			set @current_mod_date = getdate();
			update dbo.sys_job_tasklist 
			set last_id = @last_id 
			where code = @code_sys_job
		
			/*insert into dbo.sys_job_tasklist_log*/
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
