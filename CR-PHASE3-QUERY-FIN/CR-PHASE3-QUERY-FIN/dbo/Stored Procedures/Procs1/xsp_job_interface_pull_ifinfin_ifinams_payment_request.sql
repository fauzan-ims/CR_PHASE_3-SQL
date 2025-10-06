/*
exec xsp_job_interface_pull_ifinfin_ifinams_payment_request
*/
CREATE PROCEDURE dbo.xsp_job_interface_pull_ifinfin_ifinams_payment_request
as

	declare @msg			    nvarchar(max)
			,@row_to_process    int
			,@id_interface		bigint 
			,@last_id_from_job  bigint 
		    ,@last_id			bigint = 0
		    ,@code_sys_job	    nvarchar(50)
			,@code_interface	nvarchar(50)
			,@number_rows		int				= 0
			,@is_active			nvarchar(1)
			,@mod_date			datetime		= getdate()
			,@mod_by			nvarchar(15)	= 'job'
			,@mod_ip_address	nvarchar(15)	= '127.0.0.1' 
			,@current_mod_date	datetime
			,@from_id			bigint			= 0; 

	select	@row_to_process		= row_to_process
			,@last_id_from_job	= last_id
		    ,@code_sys_job	    = code
			,@is_active			= is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_pull_ifinfin_ifinams_payment_request' -- sesuai dengan nama sp ini
		
	if (@is_active = '1')
	begin
		--get payment request module ifinfun
		declare curr_ifinfinifinamspaymentrequest cursor for

			select 		id
						,code
			from		ifinams.dbo.efam_interface_payment_request
			where		id > @last_id_from_job
			order by	id asc offset 0 rows fetch next @row_to_process rows only ;

		open curr_ifinfinifinamspaymentrequest
		fetch next from curr_ifinfinifinamspaymentrequest 
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

				insert into dbo.fin_interface_payment_request
				(
					code
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
					,to_bank_account_name
					,to_bank_name
					,to_bank_account_no
					,process_date
					,process_reff_no
					,process_reff_name
					,tax_payer_reff_code
					,tax_type
					,tax_file_no
					,tax_file_name
					,manual_upload_status
					,manual_upload_remarks
					,job_status
					,failed_remarks	
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
						,payment_branch_code
						,payment_branch_name
						,payment_source
						,payment_request_date
						,payment_source_no
						,payment_status
						,payment_currency_code
						,payment_amount
						,''
						,payment_remarks
						,to_bank_account_name
						,to_bank_name
						,to_bank_account_no
						,process_date
						,process_reff_no
						,process_reff_name
						,tax_payer_reff_code
						,tax_type
						,tax_file_no
						,tax_file_name
						,null
						,null
						,'HOLD'
						,''
						,@mod_date
						,@mod_by
						,@mod_ip_address
						,@mod_date
						,@mod_by
						,@mod_ip_address
				from	ifinams.dbo.efam_interface_payment_request
				where	id = @id_interface ;


				insert into dbo.fin_interface_payment_request_detail
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
				select	payment_request_code
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
						,is_taxable
						,ext_pph_type
						,ext_vendor_code
						,ext_vendor_name
						,ext_vendor_npwp
						,ext_vendor_address
						,ext_income_type
						,ext_income_bruto_amount
						,ext_tax_rate_pct
						,ext_pph_amount
						,ext_description
						,ext_tax_number
						,ext_sale_type
						,ext_tax_date
						,@mod_date
						,@mod_by
						,@mod_ip_address
						,@mod_date
						,@mod_by
						,@mod_ip_address
				from	ifinams.dbo.efam_interface_payment_request_detail
				where	payment_request_code = @code_interface ;

				set @number_rows =+ 1
				set @last_id = @id_interface ;

				commit transaction
			end try
			begin catch

				rollback transaction 
				
				set @msg = error_message();

				update dbo.fin_interface_payment_request
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

				--clear cursor when erro
				close curr_ifinfinifinamspaymentrequest
				deallocate curr_ifinfinifinamspaymentrequest

				--stop looping
				break ;
			end catch ;   
	
			fetch next from curr_ifinfinifinamspaymentrequest
			into @id_interface
				 ,@code_interface

		end ;
		
		begin -- close cursor
			if cursor_status('global', 'curr_ifinfinifinamspaymentrequest') >= -1
			begin
				if cursor_status('global', 'curr_ifinfinifinamspaymentrequest') > -1
				begin
					close curr_ifinfinifinamspaymentrequest ;
				end ;

				deallocate curr_ifinfinifinamspaymentrequest ;
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
