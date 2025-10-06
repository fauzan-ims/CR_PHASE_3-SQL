/*
	created : Nia, 6 April 2021
*/
CREATE PROCEDURE dbo.xsp_job_interface_pull_ifinfin_ifinins_cashier_received_request
as
	declare @msg					nvarchar(max)
			,@row_to_process		int
			,@last_id_from_job		bigint
			,@id_interface			bigint 
			,@code_sys_job			nvarchar(50)
			,@code_interface		nvarchar(50)
			,@last_id				bigint	= 0 
			,@number_rows			int		= 0 
			,@is_active			    nvarchar(1)
			,@mod_date				datetime		= getdate()
			,@mod_by				nvarchar(15)	= 'job'
			,@mod_ip_address		nvarchar(15)	= '127.0.0.1' 
			,@current_mod_date		datetime
			,@from_id				bigint			= 0; 

	select	@code_sys_job		= code
			,@row_to_process	= row_to_process
			,@last_id_from_job	= last_id
			,@is_active			= is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_pull_ifinfin_ifinins_cashier_received_request' -- sesuai dengan nama sp ini

	if (@is_active = '1')
	begin
		--get cashier received request
		declare curr_ifinfinifininscashierreceivedrequest cursor for

			select 		id
						,code
			from		ifinins.dbo.ins_interface_cashier_received_request
			where		id > @last_id_from_job
			order by	id asc offset 0 rows fetch next @row_to_process rows only ;

		open curr_ifinfinifininscashierreceivedrequest	
		fetch next from curr_ifinfinifininscashierreceivedrequest 
		into @id_interface
			 ,@code_interface
		
		while @@fetch_status = 0
		begin
		begin try
			begin transaction
				if (@number_rows = 0)
				begin
					set @from_id = @id_interface
				end

				insert into dbo.fin_interface_cashier_received_request
				(
					code
					,branch_code
					,branch_name
					,request_status
					,request_currency_code
					,request_date
					,request_amount
					,request_remarks
					,agreement_no
					,pdc_code
					,pdc_no
					,doc_ref_code
					,doc_ref_name
					,process_date
					,process_reff_no
					,process_reff_name
					,manual_upload_status
					,manual_upload_remarks
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select	 code
						,branch_code
						,branch_name
						,request_status
						,request_currency_code
						,request_date
						,request_amount
						,request_remarks
						,agreement_no
						,pdc_code
						,pdc_no
						,doc_ref_code
						,doc_ref_name
						,process_date
						,process_reff_no
						,process_reff_name
						,null
						,null
						,@mod_date
						,@mod_by
						,@mod_ip_address
						,@mod_date
						,@mod_by
						,@mod_ip_address 
				from	ifinins.dbo.ins_interface_cashier_received_request
				where	id = @id_interface

				insert into dbo.fin_interface_cashier_received_request_detail
				(
					cashier_received_request_code
					,branch_code
					,branch_name
					,gl_link_code
					,agreement_no
					,facility_code
					,facility_name
					,purpose_loan_code
					,purpose_loan_name
					,purpose_loan_detail_code
					,purpose_loan_detail_name
					,orig_currency_code
					,orig_amount
					,division_code
					,division_name
					,department_code
					,department_name
					,remarks
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select	 iicrrd.cashier_received_request_code
						,iicrrd.branch_code
						,iicrrd.branch_name
						,iicrrd.gl_link_code
						,iicrrd.agreement_no
						,iicrrd.facility_code
						,iicrrd.facility_name
						,iicrrd.purpose_loan_code
						,iicrrd.purpose_loan_name
						,iicrrd.purpose_loan_detail_code
						,iicrrd.purpose_loan_detail_name
						,iicrrd.orig_currency_code
						,iicrrd.orig_amount
						,iicrrd.division_code
						,iicrrd.division_name
						,iicrrd.department_code
						,iicrrd.department_name
						,iicrrd.remarks
						,@mod_date
						,@mod_by
						,@mod_ip_address
						,@mod_date
						,@mod_by
						,@mod_ip_address 
				from	ifinins.dbo.ins_interface_cashier_received_request_detail iicrrd 
				where	iicrrd.cashier_received_request_code = @code_interface

			set @number_rows =+ 1
			set @last_id = @id_interface ;

			commit transaction
		end try
		begin catch

			rollback transaction 
			
			set @msg = error_message();

			update dbo.fin_interface_cashier_received_request
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
			close curr_ifinfinifininscashierreceivedrequest
			deallocate curr_ifinfinifininscashierreceivedrequest

			--stop looping
			break ;
		end catch ;   
	
			fetch next from curr_ifinfinifininscashierreceivedrequest
			into @id_interface
				 ,@code_interface

		end ;
		
		begin -- close cursor
			if cursor_status('global', 'curr_ifinfinifininscashierreceivedrequest') >= -1
			begin
				if cursor_status('global', 'curr_ifinfinifininscashierreceivedrequest') > -1
				begin
					close curr_ifinfinifininscashierreceivedrequest ;
				end ;

				deallocate curr_ifinfinifininscashierreceivedrequest ;
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
