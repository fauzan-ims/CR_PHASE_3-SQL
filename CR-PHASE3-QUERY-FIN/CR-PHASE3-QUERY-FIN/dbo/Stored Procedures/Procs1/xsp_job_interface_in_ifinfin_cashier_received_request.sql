/*
exec xsp_job_interface_in_ifinfin_cashier_received_request
*/
CREATE PROCEDURE [dbo].[xsp_job_interface_in_ifinfin_cashier_received_request]
as

	declare @msg							nvarchar(max)
			,@row_to_process				int
			,@last_id_from_job				bigint
			,@id_interface					bigint
			,@code_sys_job					nvarchar(50)
			,@last_id						bigint		   = 0
			,@number_rows					int			   = 0
			,@is_active						nvarchar(1)
			,@current_mod_date				datetime
			,@mod_date						datetime	   = getdate()
			,@mod_by						nvarchar(15)   = 'job'
			,@mod_ip_address				nvarchar(15)   = '127.0.0.1'
			,@from_id						bigint		   = 0
			,@request_amount				decimal(18, 2) = 0
			,@invoice_ppn_amount	 		decimal(18, 2) = 0
			,@invoice_pph_amount	 		decimal(18, 2) = 0
			,@invoice_billing_amount 		decimal(18, 2) = 0
			,@invoice_no					nvarchar(50)
			,@cashier_received_request_code nvarchar(50)

	select	@code_sys_job		= code
			,@row_to_process	= row_to_process
			,@last_id_from_job	= last_id
			,@is_active			= is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_in_ifinfin_cashier_received_request' -- sesuai dengan nama sp ini

	if (@is_active = '1')
	begin
	--get cashier received request
	declare curr_cashier_received_request cursor for

		select 		id
		from		dbo.fin_interface_cashier_received_request
		where		request_status = 'HOLD'
					and job_status in ('HOLD','FAILED')
		order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_cashier_received_request
			
	fetch next from curr_cashier_received_request 
	into @id_interface
		
	while @@fetch_status = 0
	begin
		begin try
			begin transaction
			if (@number_rows = 0)
			begin
				set @from_id = @id_interface
			end

			if exists
			(
				select	1
				from	fin_interface_cashier_received_request
				where	id				 = @id_interface
						and doc_ref_name = 'CREDIT NOTE'
			)
			begin
				select	@request_amount			 = request_amount
						,@invoice_ppn_amount	 = invoice_ppn_amount
						,@invoice_pph_amount	 = invoice_pph_amount
						,@invoice_billing_amount = invoice_billing_amount
						,@invoice_no			 = invoice_no
				from	fin_interface_cashier_received_request
				where	id						 = @id_interface ;

				update	dbo.cashier_received_request
				set		request_amount			= @request_amount
						,invoice_ppn_amount		= @invoice_ppn_amount
						,invoice_pph_amount		= @invoice_pph_amount
						,invoice_billing_amount	= @invoice_billing_amount
						--
						,mod_date				= @mod_date
						,mod_by					= @mod_by
						,mod_ip_address			= @mod_ip_address
				where	invoice_no				= @invoice_no
						and request_status		= 'HOLD'

				select	@cashier_received_request_code = code
				from	dbo.cashier_received_request
				where	invoice_no		   = @invoice_no
						and request_status = 'HOLD' ;

				delete dbo.cashier_received_request_detail
				where	cashier_received_request_code = @cashier_received_request_code ;

				insert into dbo.cashier_received_request_detail
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
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select	@cashier_received_request_code
						,crrd.branch_code
						,crrd.branch_name
						,crrd.gl_link_code
						,crrd.agreement_no
						,crrd.facility_code
						,crrd.facility_name
						,crrd.purpose_loan_code
						,crrd.purpose_loan_name
						,crrd.purpose_loan_detail_code
						,crrd.purpose_loan_detail_name
						,crrd.orig_currency_code
						,crrd.orig_amount
						,crrd.division_code
						,crrd.division_name
						,crrd.department_code
						,crrd.department_name
						,crrd.remarks
						--
						,@mod_date
						,@mod_by
						,@mod_ip_address
						,@mod_date
						,@mod_by
						,@mod_ip_address
				from	dbo.fin_interface_cashier_received_request_detail crrd
						inner join dbo.fin_interface_cashier_received_request crr on (crr.code = crrd.cashier_received_request_code)
				where	crr.id = @id_interface ;

				--raffi 2024-07-12 : penambahan kondisi cancel jika amount 0 tipe credit note 2322228
				if exists
					(
						select  1
						from    dbo.cashier_received_request
						where   invoice_no = @invoice_no
								and request_status = 'HOLD'
								and invoice_billing_amount = 0
								and invoice_ppn_amount = 0
								and invoice_pph_amount = 0
					)
				begin
					update  dbo.cashier_received_request
					set     request_status = 'PAID'
							--
							,mod_date		= @mod_date
							,mod_by			= @mod_by
							,mod_ip_address = @mod_ip_address
					where   invoice_no		= @invoice_no
							and request_status = 'HOLD'
							and invoice_billing_amount = 0
							and invoice_ppn_amount = 0
							and invoice_pph_amount = 0
				END

			end ;
			else
			begin
				insert into dbo.cashier_received_request
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
					,client_no -- Louis Rabu, 25 Juni 2025 10.52.37 -- 
					,client_name -- Louis Rabu, 25 Juni 2025 10.52.37 -- 
					,pdc_code
					,pdc_no
					,doc_ref_code
					,doc_ref_name
					,doc_ref_flag
					,collector_code
					,collector_name
					,pdc_allocation_type
					,branch_bank_code
					,branch_bank_name
					,branch_bank_gl_link_code
					,process_date
					,process_reff_code
					,process_reff_name
					,invoice_no
					,invoice_external_no
					,invoice_date
					,invoice_due_date
					,invoice_billing_amount
					,invoice_ppn_amount
					,invoice_pph_amount
					--
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
						,request_status
						,request_currency_code
						,request_date
						,request_amount
						,request_remarks
						,agreement_no
						,client_no -- Louis Rabu, 25 Juni 2025 10.52.37 -- 
						,client_name -- Louis Rabu, 25 Juni 2025 10.52.37 -- 
						,pdc_code
						,pdc_no
						,doc_ref_code
						,doc_ref_name
						,doc_ref_flag
						,collector_code
						,collector_name
						,pdc_allocation_type
						,branch_bank_code
						,branch_bank_name
						,branch_bank_gl_link_code
						,process_date
						,process_reff_no
						,process_reff_name
						,invoice_no
						,invoice_external_no
						,invoice_date
						,invoice_due_date
						,invoice_billing_amount
						,invoice_ppn_amount
						,invoice_pph_amount
						--
						,@mod_date
						,@mod_by
						,@mod_ip_address
						,@mod_date
						,@mod_by
						,@mod_ip_address
				from	dbo.fin_interface_cashier_received_request
				where	id = @id_interface ;

				insert into dbo.cashier_received_request_detail
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
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select	crrd.cashier_received_request_code
						,crrd.branch_code
						,crrd.branch_name
						,crrd.gl_link_code
						,crrd.agreement_no
						,crrd.facility_code
						,crrd.facility_name
						,crrd.purpose_loan_code
						,crrd.purpose_loan_name
						,crrd.purpose_loan_detail_code
						,crrd.purpose_loan_detail_name
						,crrd.orig_currency_code
						,crrd.orig_amount
						,crrd.division_code
						,crrd.division_name
						,crrd.department_code
						,crrd.department_name
						,crrd.remarks
						--
						,@mod_date
						,@mod_by
						,@mod_ip_address
						,@mod_date
						,@mod_by
						,@mod_ip_address
				from	dbo.fin_interface_cashier_received_request_detail crrd
						inner join dbo.fin_interface_cashier_received_request crr on (crr.code = crrd.cashier_received_request_code)
				where	crr.id = @id_interface ;
			end ;

			update dbo.fin_interface_cashier_received_request
			set    job_status = 'POST'
			where  id		   = @id_interface
			
			set @number_rows =+ 1
			set @last_id = @id_interface ;

			commit transaction
		end try
		begin catch

			rollback transaction 
			
			set @msg = error_message();
			select @msg, @id_interface
			set @current_mod_date = getdate();

			update	dbo.fin_interface_cashier_received_request  --cek poin
			set		job_status = 'FAILED'
					,failed_remarks = @msg
			where	id = @id_interface --cek poin	

			print @msg

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
	
		fetch next from curr_cashier_received_request
		into @id_interface

	end ;
		
	begin -- close cursor
		if cursor_status('global', 'curr_cashier_received_request') >= -1
		begin
			if cursor_status('global', 'curr_cashier_received_request') > -1
			begin
				close curr_cashier_received_request ;
			end ;

			deallocate curr_cashier_received_request ;
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

