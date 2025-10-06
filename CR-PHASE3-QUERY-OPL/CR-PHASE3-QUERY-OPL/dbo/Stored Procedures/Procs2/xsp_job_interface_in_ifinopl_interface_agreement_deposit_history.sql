/*
exec xsp_job_interface_in_ifinopl_interface_agreement_deposit_history
*/
-- Louis Selasa, 14 Maret 2023 10.53.04 --
CREATE PROCEDURE dbo.xsp_job_interface_in_ifinopl_interface_agreement_deposit_history
as

	declare @msg					    nvarchar(max)
			,@row_to_process		    int
			,@last_id_from_job		    bigint
			,@id_interface			    bigint 
			,@code_sys_job			    nvarchar(50)
			,@deposit_code			    nvarchar(50)
			,@deposit_amount		    decimal(18,2)
			,@is_active				    nvarchar(1) 
			,@last_id				    bigint		 = 0 
			,@number_rows			    int			 = 0 
			,@from_id				    bigint		 = 0
			,@agreement_no			    nvarchar(50)
			,@deposit_type			    nvarchar(15)
			,@currency				    nvarchar(3)
			,@current_mod_date		    datetime
			,@branch_code			    nvarchar(50)
			,@branch_name			    nvarchar(250)
			,@plafond_no				nvarchar(50)
			,@source_reff_name			nvarchar(250)
			,@source_reff_module		nvarchar(250)
			,@mod_date				    datetime	 = getdate()
			,@mod_by				    nvarchar(15) = 'job'
			,@mod_ip_address		    nvarchar(15) = '127.0.0.1' ;

	select	@code_sys_job		= code
			,@row_to_process	= row_to_process
			,@last_id_from_job	= last_id
			,@is_active			= is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_in_ifinopl_interface_agreement_deposit_history' -- sesuai dengan nama sp ini

	if (@is_active = '1')
	begin
		--get cashier received request
		declare curr_agreement_deposit_main cursor for

			select 		id
			from		dbo.opl_interface_agreement_deposit_history
			where		job_status in ('HOLD','FAILED')
			order by	id asc offset 0 rows fetch next @row_to_process rows only ;

		open curr_agreement_deposit_main
			
		fetch next from curr_agreement_deposit_main 
		into	@id_interface
		
		while @@fetch_status = 0
		begin
			begin try
				begin transaction

				if (@number_rows = 0)
				begin
					set @from_id = @id_interface
				end

				select  @deposit_code		 = agreement_deposit_code
						,@deposit_amount	 = orig_amount
						,@agreement_no		 = isnull(agreement_no,'')
						,@deposit_type		 = deposit_type
						,@currency			 = orig_currency_code
						,@branch_code		 = branch_code
						,@branch_name		 = branch_name
						,@plafond_no		 = isnull(plafond_no,'')
						,@source_reff_name	 = source_reff_name
						,@source_reff_module = source_reff_module
				from dbo.opl_interface_agreement_deposit_history
				where id = @id_interface
		
				if exists (select 1 from dbo.agreement_deposit_main where code = @deposit_code)
				begin		
					update	dbo.agreement_deposit_main
					set		deposit_amount	= deposit_amount + @deposit_amount
							,mod_date		= @mod_date
							,mod_by			= @mod_by
							,mod_ip_address	= @mod_ip_address
					where	code			= @deposit_code

				end
				else if exists
				(
					select	1
					from	dbo.agreement_deposit_main
					where	agreement_no			  = @agreement_no
							and deposit_type		  = @deposit_type
							and deposit_currency_code = @currency
				)
				begin 
			
					update	dbo.agreement_deposit_main
					set		deposit_amount	= deposit_amount + @deposit_amount
							,mod_date		= @mod_date
							,mod_by			= @mod_by
							,mod_ip_address	= @mod_ip_address
					where agreement_no              = @agreement_no 
							and deposit_type          = @deposit_type 
							and deposit_currency_code = @currency

					select @deposit_code = code 
					from dbo.agreement_deposit_main
					where agreement_no              = @agreement_no 
							and deposit_type          = @deposit_type 
							and deposit_currency_code = @currency
				end
				else
				begin
						--exec agreement_deposit_main, code output
					exec dbo.xsp_agreement_deposit_main_insert @p_code					  = @deposit_code output
																,@p_branch_code			  = @branch_code
																,@p_branch_name			  = @branch_name
																,@p_agreement_no		  = @agreement_no
																,@p_deposit_type		  = @deposit_type
																,@p_deposit_currency_code = @currency
																,@p_deposit_amount		  = @deposit_amount
																,@p_cre_date			  = @mod_date
																,@p_cre_by				  = @mod_by
																,@p_cre_ip_address		  = @mod_ip_address
																,@p_mod_date			  = @mod_date
																,@p_mod_by				  = @mod_by
																,@p_mod_ip_address		  = @mod_ip_address
					
				end

				insert into dbo.agreement_deposit_history
				(
					branch_code
					,branch_name
					,agreement_deposit_code
					,agreement_no
					,deposit_type
					,transaction_date
					,orig_amount
					,orig_currency_code
					,exch_rate
					,base_amount
					,source_reff_module
					,source_reff_code
					,source_reff_name
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select	branch_code
						,branch_name
						,@deposit_code
						,agreement_no
						,deposit_type
						,transaction_date
						,orig_amount
						,orig_currency_code
						,exch_rate
						,base_amount
						,source_reff_module
						,source_reff_code
						,source_reff_name
						--
						,@mod_date
						,@mod_by
						,@mod_ip_address
						,@mod_date
						,@mod_by
						,@mod_ip_address
				from	dbo.opl_interface_agreement_deposit_history
				where	id = @id_interface ;

				-- Louis Senin, 05 Februari 2024 11.21.04 -- penambahan fungsing untuk hitung ulang agreement information
				begin 
					exec dbo.xsp_agreement_information_update @p_agreement_no		= @agreement_no
															  ,@p_mod_date			= @mod_date
															  ,@p_mod_by			= @mod_by
															  ,@p_mod_ip_address	= @mod_ip_address ; 
				end
				
				set @number_rows =+ 1
				set @last_id = @id_interface ;

				update	dbo.OPL_INTERFACE_AGREEMENT_DEPOSIT_HISTORY  --cek poin
				set		JOB_STATUS = 'POST'
						,FAILED_REMARK = ''
				where	id = @id_interface	
				
				commit transaction
			end try
			begin catch

				rollback transaction 
			
				set @msg = error_message();
				set @msg = isnull(@msg,'')
				
				update	dbo.opl_interface_agreement_deposit_history  --cek poin
				set		job_status = 'FAILED'
						,failed_remark = ISNULL(@msg,'')
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
															,@p_cre_ip_address		= @mod_ip_address
															,@p_mod_date			= @current_mod_date--cek poin
															,@p_mod_by				= @mod_by
															,@p_mod_ip_address		= @mod_ip_address  ;

			end catch   
	
			fetch next from curr_agreement_deposit_main
			into	@id_interface

		end ;
		
		begin -- close cursor
			if cursor_status('global', 'curr_agreement_deposit_main') >= -1
			begin
				if cursor_status('global', 'curr_agreement_deposit_main') > -1
				begin
					close curr_agreement_deposit_main ;
				end ;

				deallocate curr_agreement_deposit_main ;
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
													 ,@p_log_description	= ''
													 ,@p_run_by				= @mod_by
													 ,@p_from_id			= @from_id  --cek poin
													 ,@p_to_id				= @id_interface --cek poin
													 ,@p_number_of_rows		= @number_rows --cek poin
													 ,@p_cre_date			= @current_mod_date--cek poin
													 ,@p_cre_by				= @mod_by
													 ,@p_cre_ip_address		= @mod_ip_address
													 ,@p_mod_date			= @current_mod_date--cek poin
													 ,@p_mod_by				= @mod_by
													 ,@p_mod_ip_address		= @mod_ip_address 
					    
		end
	end
