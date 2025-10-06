/*
	created : Fadlan, 14 April 2021
*/

CREATE PROCEDURE dbo.xsp_job_interface_pull_ifinfin_ifincore_agreement_main
as

	declare @msg				nvarchar(max)
			,@id_interface		bigint --cursor
			,@row_to_process	int
			,@last_id		    bigint	= 0
			,@last_id_from_job  bigint 
			,@code_sys_job	    nvarchar(50)
			,@number_rows	    int		= 0
			,@row_count		    int     = 0
			,@is_active			nvarchar(1)
			,@mod_date		    datetime	 = getdate()
			,@mod_by		    nvarchar(50) = 'Admin'
			,@mode_address      nvarchar(50) = '127.0.0'
			,@current_mod_date	datetime
			,@from_id			bigint			= 0;  

	select	@row_to_process     = row_to_process
		    ,@last_id_from_job	= last_id
		    ,@code_sys_job	    = code
			,@is_active			= is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_pull_ifinfin_ifincore_agreement_main' 

	if (@is_active = '1')
	begin
		--module core interface agreement agreement main out
		declare cur_fincoreagreementmain cursor for

			select 	id
			from ifincore.dbo.core_interface_agreement_main_out
			where id > @last_id_from_job
			order by id asc offset 0 rows
			fetch next @row_to_process rows only;

		open cur_fincoreagreementmain		
		fetch next from cur_fincoreagreementmain 
		into @id_interface
		
		while @@fetch_status = 0
		begin
			begin try
				begin transaction
					if (@number_rows = 0)
					begin
						set @from_id = @id_interface
					end

					--get data from module core
					insert into dbo.fin_interface_agreement_main
					(
						agreement_no
						,agreement_external_no
						,branch_code
						,branch_name
						,agreement_date
						,agreement_status
						,agreement_sub_status
						,currency_code
						,facility_code
						,facility_name
						,purpose_loan_code
						,purpose_loan_name
						,purpose_loan_detail_code
						,purpose_loan_detail_name
						,termination_date
						,termination_status
						,client_code
						,client_name
						,asset_description
						,collateral_description
						,last_paid_installment_no
						,overdue_period
						,is_remedial
						,is_wo
						,installment_amount
						,installment_due_date
						,overdue_days
						,factoring_type
						,reff_1
						,reff_2
						,reff_3
						,reff_4
						,reff_5
						,reff_6
						,reff_7
						,reff_8
						,reff_9
						,reff_10
						--
						,cre_date
						,cre_by
						,cre_ip_address
						,mod_date
						,mod_by
						,mod_ip_address
					)
					select	amo.agreement_no
							,amo.agreement_external_no
							,amo.branch_code
							,amo.branch_name
							,amo.agreement_date
							,amo.agreement_status
							,amo.agreement_status
							,amo.currency_code
							,amo.facility_code
							,amo.facility_name
							,amo.purpose_loan_code
							,amo.purpose_loan_name
							,amo.purpose_loan_detail_code
							,amo.purpose_loan_detail_name
							,amo.termination_date
							,amo.termination_status
							,amo.client_no
							,amo.client_name
							,amo.asset_description
							,amo.collateral_description
							,'0'
							,amo.overdue_period
							,'0' --is_remedial
							,'0' --is_wo
							,tco.installment_amount
							,tco.first_due_date
							,amo.overdue_days
							,amo.factoring_type
							,amo.reff_1
							,amo.reff_2
							,amo.reff_3
							,amo.reff_4
							,amo.reff_5
							,amo.reff_6
							,amo.reff_7
							,amo.reff_8
							,amo.reff_9
							,amo.reff_10
							--
							,@mod_date
							,@mod_by
							,@mode_address
							,@mod_date
							,@mod_by
							,@mode_address
					from	ifincore.dbo.core_interface_agreement_main_out amo
							inner join ifincore.dbo.core_interface_agreement_tc_out tco on (tco.agreement_no = amo.agreement_no)
					where	amo.id = @id_interface ;

					set @number_rows =+ 1
					set @last_id = @id_interface ;
						
				commit transaction
			end try
			begin catch
				
					rollback transaction 

					set @msg = error_message();

					update dbo.fin_interface_agreement_main
					set		job_status		= 'FAILED'
							,failed_remarks	= @msg
					where	id				= @id_interface

					set @current_mod_date = getdate();
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

					--clear cursor when error
					close cur_fincoreagreementmain
					deallocate cur_fincoreagreementmain

					--stop looping
					break ;
				end catch ;

			fetch next from cur_fincoreagreementmain 
			into @id_interface
		end

		begin -- close cursor
			if cursor_status('global', 'cur_fincoreagreementmain') >= -1
			begin
				if cursor_status('global', 'cur_fincoreagreementmain') > -1
				begin
					close cur_fincoreagreementmain ;
				end ;

				deallocate cur_fincoreagreementmain ;
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
