/*
	created : Nia, 1 April 2021
*/
CREATE PROCEDURE dbo.xsp_job_interface_in_ifinfin_payment_request
as
declare @msg			   nvarchar(max)
		,@row_to_process   int
		,@last_id_from_job bigint
		,@id_interface	   bigint
		,@code_sys_job	   nvarchar(50)
		,@code_interface   nvarchar(50)
		,@is_active		   nvarchar(1)
		,@last_id		   bigint		= 0
		,@number_rows	   int			= 0
		,@current_mod_date datetime
		,@mod_date		   datetime		= getdate()
		,@mod_by		   nvarchar(15) = 'job'
		,@mod_ip_address   nvarchar(15) = '127.0.0.1'
		,@from_id		   bigint		= 0 ;

select	@code_sys_job = code
		,@row_to_process = row_to_process
		,@last_id_from_job = last_id
		,@is_active = is_active
from	dbo.sys_job_tasklist
where	sp_name = 'xsp_job_interface_in_ifinfin_payment_request' ; -- sesuai dengan nama sp ini

if (@is_active = '1')
begin
	--get cashier received request
	declare curr_interfacepaymentrequest cursor for
	select		id
				,code
	from		dbo.fin_interface_payment_request
	where		payment_status = 'HOLD'
				and job_status in
	(
		'HOLD', 'FAILED'
	)
	order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_interfacepaymentrequest ;

	fetch next from curr_interfacepaymentrequest
	into @id_interface
		 ,@code_interface ;

	while @@fetch_status = 0
	begin
		begin try
			begin transaction ;

			if (@number_rows = 0)
			begin
				set @from_id = @id_interface ;
			end ;

			insert into dbo.payment_request
			(
			    code,
			    branch_code,
			    branch_name,
			    payment_branch_code,
			    payment_branch_name,
			    payment_source,
			    payment_request_date,
			    payment_source_no,
			    payment_status,
			    payment_currency_code,
			    payment_amount,
				payment_to,
			    payment_remarks,
			    to_bank_name,
			    to_bank_account_name,
			    to_bank_account_no,
			    payment_transaction_code,
			    tax_payer_reff_code,
			    tax_type,
			    tax_file_no,
				tax_file_name,
			    cre_date,
			    cre_by,
			    cre_ip_address,
			    mod_date,
			    mod_by,
			    mod_ip_address
			)
			select	code
					,branch_code
					,branch_name
					,payment_branch_code
					,payment_branch_name
					,payment_source
					,payment_request_date
					,payment_source_no
					,payment_status
					,payment_currency_code
					,payment_amount
					,payment_to
					,payment_remarks
					,to_bank_name
					,to_bank_account_name
					,to_bank_account_no
					,null
					,tax_payer_reff_code
			        ,tax_type
			        ,tax_file_no
					,tax_file_name
					,@mod_date
					,@mod_by
					,@mod_ip_address
					,@mod_date
					,@mod_by
					,@mod_ip_address
			from	dbo.fin_interface_payment_request
			where	id = @id_interface ;

			insert into dbo.payment_request_detail
			(
				payment_request_code
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
				,exch_rate
				,orig_amount
				,division_code
				,division_name
				,department_code
				,department_name
				,remarks
				,is_taxable
				,ext_pph_type
				,ext_vendor_code
				,ext_vendor_name
				,ext_vendor_npwp
				,ext_vendor_address
				,ext_vendor_type
				,ext_income_type
				,ext_income_bruto_amount
				,ext_tax_rate_pct
				,ext_pph_amount
				,ext_description
				,ext_tax_number
				,ext_sale_type
				,ext_tax_date
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	fiprd.payment_request_code
					,fiprd.branch_code
					,fiprd.branch_name
					,fiprd.gl_link_code
					,fiprd.agreement_no
					,fiprd.facility_code
					,fiprd.facility_name
					,fiprd.purpose_loan_code
					,fiprd.purpose_loan_name
					,fiprd.purpose_loan_detail_code
					,fiprd.purpose_loan_detail_name
					,fiprd.orig_currency_code
					,fiprd.exch_rate
					,fiprd.orig_amount
					,fiprd.division_code
					,fiprd.division_name
					,fiprd.department_code
					,fiprd.department_name
					,remarks
					,fiprd.is_taxable
					,ext_pph_type
					,ext_vendor_code
					,ext_vendor_name
					,ext_vendor_npwp
					,ext_vendor_address
					--,'CORPORATE'
					,case	when fiprd.ext_income_type like '%21' then 'PERSONAL' --Raffyanda 2024/01/03 agar vendor type nya masuk sesuai income type
							when fiprd.ext_income_type like '%23' then 'CORPORATE'
					end
					,ext_income_type
					,ext_income_bruto_amount
					,ext_tax_rate_pct
					,ext_pph_amount
					,ext_description
					,ext_tax_number
					,ext_sale_type
					,fiprd.ext_tax_date
					,@mod_date
					,@mod_by
					,@mod_ip_address
					,@mod_date
					,@mod_by
					,@mod_ip_address
			from	dbo.fin_interface_payment_request_detail fiprd
			where	fiprd.payment_request_code = @code_interface ;

			update	dbo.fin_interface_payment_request
			set		job_status = 'POST'
			where	id = @id_interface ;

			set @number_rows = +1 ;
			set @last_id = @id_interface ;

			commit transaction ;
		end try
		begin catch
			rollback transaction ;

			set @msg = error_message() ;
			set @current_mod_date = getdate() ;
			select @msg
			update	dbo.fin_interface_payment_request --cek poin
			set		job_status = 'FAILED'
					,failed_remarks = @msg
			where	id = @id_interface ;

			/*insert into dbo.sys_job_tasklist_log*/
			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code = @code_sys_job
													 ,@p_status = N'Error'
													 ,@p_start_date = @mod_date
													 ,@p_end_date = @current_mod_date --cek poin
													 ,@p_log_description = @msg
													 ,@p_run_by = 'job'
													 ,@p_from_id = @from_id --cek poin
													 ,@p_to_id = @id_interface --cek poin
													 ,@p_number_of_rows = @number_rows --cek poin
													 ,@p_cre_date = @current_mod_date --cek poin
													 ,@p_cre_by = N'job'
													 ,@p_cre_ip_address = N'127.0.0.1'
													 ,@p_mod_date = @current_mod_date --cek poin
													 ,@p_mod_by = N'job'
													 ,@p_mod_ip_address = N'127.0.0.1' ;
		end catch ;

		fetch next from curr_interfacepaymentrequest
		into @id_interface
			 ,@code_interface ;
	end ;

	begin -- close cursor
		if cursor_status('global', 'curr_interfacepaymentrequest') >= -1
		begin
			if cursor_status('global', 'curr_interfacepaymentrequest') > -1
			begin
				close curr_interfacepaymentrequest ;
			end ;

			deallocate curr_interfacepaymentrequest ;
		end ;
	end ;

	if (@last_id > 0) --cek poin
	begin
		set @current_mod_date = getdate() ;

		update	dbo.sys_job_tasklist
		set		last_id = @last_id
		where	code = @code_sys_job ;

		/*insert into dbo.sys_job_tasklist_log*/
		exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code = @code_sys_job
												 ,@p_status = 'Success'
												 ,@p_start_date = @mod_date
												 ,@p_end_date = @current_mod_date --cek poin
												 ,@p_log_description = ''
												 ,@p_run_by = 'job'
												 ,@p_from_id = @from_id --cek poin
												 ,@p_to_id = @last_id --cek poin
												 ,@p_number_of_rows = @number_rows --cek poin
												 ,@p_cre_date = @current_mod_date --cek poin
												 ,@p_cre_by = 'job'
												 ,@p_cre_ip_address = '127.0.0.1'
												 ,@p_mod_date = @current_mod_date --cek poin
												 ,@p_mod_by = 'job'
												 ,@p_mod_ip_address = '127.0.0.1' ;
	end ;
end ;
