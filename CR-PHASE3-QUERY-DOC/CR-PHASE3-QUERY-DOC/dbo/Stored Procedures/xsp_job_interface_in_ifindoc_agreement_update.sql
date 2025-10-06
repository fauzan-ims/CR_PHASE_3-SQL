/*
	created : Nia, 15 April 2021
*/

CREATE PROCEDURE dbo.xsp_job_interface_in_ifindoc_agreement_update 
as

	declare @msg						nvarchar(max)=''
			,@id_interface				bigint --cursor
			,@row_to_process			int
			,@last_id					bigint		 = 0
			,@last_id_from_job			bigint 
			,@code_sys_job				nvarchar(50)
			,@number_rows				int			 = 0
			,@agreement_no				nvarchar(50)
			,@agreement_status			nvarchar(10)
			,@agreement_sub_status		nvarchar(20)
			,@termination_date			datetime
			,@termination_status		nvarchar(20)
			,@client_no					nvarchar(50)
			,@client_name				nvarchar(250)
			,@next_due_date				datetime
			,@last_paid_period			int
			,@last_installment_due_date	datetime
			,@overdue_period			int
			,@overdue_days				int
			,@is_wo						nvarchar(1)
			,@is_active					nvarchar(1)
			,@from_id					bigint		 = 0
			,@current_mod_date			datetime
			,@mod_date					datetime	 = getdate()
			,@mod_by					nvarchar(50) = 'Admin'
			,@mode_address				nvarchar(50) = '127.0.0'

	select	@row_to_process     = row_to_process
		    ,@last_id_from_job	= last_id
		    ,@code_sys_job	    = code
			,@is_active			= is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_in_ifindoc_agreement_update' 

	if (@is_active = '1')
	begin
		--module interface agreement update
		declare cur_docagreementupdate cursor for

			select 	id
                    ,agreement_no
					,agreement_status
					,agreement_sub_status
					,termination_date
					,termination_status
					,client_no
					,client_name
					,next_due_date
					,last_paid_period
					,last_installment_due_date
					,overdue_period
					,overdue_days
					,is_wo
			from  dbo.doc_interface_agreement_update
			where job_status in ('HOLD','FAILED')
			order by id asc offset 0 rows
			fetch next @row_to_process rows only;

		open cur_docagreementupdate		
		fetch next from cur_docagreementupdate 
		into @id_interface
			 ,@agreement_no
			 ,@agreement_status
			 ,@agreement_sub_status
			 ,@termination_date
			 ,@termination_status
			 ,@client_no
			 ,@client_name
			 ,@next_due_date
			 ,@last_paid_period
			 ,@last_installment_due_date
			 ,@overdue_period
			 ,@overdue_days
			 ,@is_wo

		while @@fetch_status = 0
		begin
			begin try
				begin transaction
					if (@number_rows = 0)
					begin
						set @from_id = @id_interface
					end

					update dbo.agreement_main
					set agreement_status    		= @agreement_status
						,termination_date			= @termination_date
						,termination_status			= @termination_status
						,client_no					= @client_no
						,client_name				= @client_name
						--,next_due_date				= @next_due_date
						--,last_paid_period			= @last_paid_period
						--,last_installment_due_date	= @last_installment_due_date
						--,overdue_period				= @overdue_period
						--,overdue_days				= @overdue_days
						,cre_date					= @mod_date					
					    ,cre_by						= @mod_by						
					    ,cre_ip_address				= @mode_address					
					    ,mod_date					= @mod_date						
					    ,mod_by						= @mod_by							
					    ,mod_ip_address				= @mode_address					
					where agreement_no				= @agreement_no
										
					set @number_rows =+ 1
					set @last_id = @id_interface ;

					update	dbo.doc_interface_agreement_update  --cek poin
					set		job_status = 'POST'
					where	id = @id_interface
					 
				commit transaction
			end try
			begin catch
				
					rollback transaction 

					set @msg = error_message();
				
					update	dbo.doc_interface_agreement_update  --cek poin
					set		job_status		= 'FAILED'
							,failed_remark = @msg
					where	id = @id_interface --cek poin	

					/*insert into dbo.sys_job_tasklist_log*/
					set @current_mod_date = getdate();
					exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code		= @code_sys_job
																,@p_status				= N'Error'
																,@p_start_date			= @mod_date
																,@p_end_date			= @current_mod_date--cek poin
																,@p_log_description		= @msg
																,@p_run_by				= @mod_by
																,@p_from_id				= @from_id  --cek poin
																,@p_to_id				= @id_interface --cek poin
																,@p_number_of_rows		= @number_rows --cek poin
																,@p_cre_date			= @current_mod_date--cek poin
																,@p_cre_by				= @mod_by
																,@p_cre_ip_address		= @mode_address
																,@p_mod_date			= @current_mod_date--cek poin
																,@p_mod_by				= @mod_by
																,@p_mod_ip_address		= @mode_address  ;

			end catch

			fetch next from cur_docagreementupdate 
			into @id_interface
				 ,@agreement_no
				 ,@agreement_status
				 ,@agreement_sub_status
				 ,@termination_date
				 ,@termination_status
				 ,@client_no
				 ,@client_name
				 ,@next_due_date
				 ,@last_paid_period
				 ,@last_installment_due_date
				 ,@overdue_period
				 ,@overdue_days
				 ,@is_wo
		end

		begin -- close cursor
			if cursor_status('global', 'cur_docagreementupdate') >= -1
			begin
				if cursor_status('global', 'cur_docagreementupdate') > -1
				begin
					close cur_docagreementupdate ;
				end ;

				deallocate cur_docagreementupdate ;
			end ;
		end ;

		if (@last_id > 0)--cek poin
		begin
			update dbo.sys_job_tasklist 
			set last_id = @last_id 
			where code = @code_sys_job
		
			/*insert into dbo.sys_job_tasklist_log*/
			set @current_mod_date = getdate();
			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
													 ,@p_status				= 'Success'
													 ,@p_start_date			= @mod_date
													 ,@p_end_date			= @current_mod_date--cek poin
													 ,@p_log_description	= @msg
													 ,@p_run_by				= @mod_by
													 ,@p_from_id			= @from_id  --cek poin
													 ,@p_to_id				= @id_interface --cek poin
													 ,@p_number_of_rows		= @number_rows --cek poin
													 ,@p_cre_date			= @current_mod_date--cek poin
													 ,@p_cre_by				= @mod_by
													 ,@p_cre_ip_address		= @mode_address
													 ,@p_mod_date			= @current_mod_date--cek poin
													 ,@p_mod_by				= @mod_by
													 ,@p_mod_ip_address		= @mode_address 
					    
		end
	end
