create PROCEDURE dbo.xsp_ifinproc_interface_payment_request_insert
(
	@p_code					  nvarchar(50) output
	,@p_branch_code			  nvarchar(50)
	,@p_branch_name			  nvarchar(250)
	,@p_payment_source		  nvarchar(50)
	,@p_payment_request_date  datetime
	,@p_payment_source_no	  nvarchar(50)
	,@p_payment_currency_code nvarchar(3)
	,@p_payment_status		  nvarchar(10)
	,@p_payment_amount		  decimal(18, 2)
	,@p_payment_to			  nvarchar(250)
	,@p_payment_remarks		  nvarchar(4000)
	,@p_to_bank_account_name  nvarchar(250)
	,@p_to_bank_name		  nvarchar(250)
	,@p_to_bank_account_no	  nvarchar(50)
	,@p_process_date		  datetime
	,@p_process_reff_no		  nvarchar(50)
	,@p_process_reff_name	  nvarchar(250)
	,@p_tax_payer_reff_code   nvarchar(50)
	,@p_tax_type			  nvarchar(10) 
	,@p_tax_file_no			  nvarchar(50)
	,@p_tax_file_name		  nvarchar(250)
	,@p_settle_date			  datetime
	,@p_job_status			  nvarchar(10)
	,@p_failed_remarks		  nvarchar(4000)

	--						  
	,@p_cre_date			  datetime
	,@p_cre_by				  nvarchar(15)
	,@p_cre_ip_address		  nvarchar(15)
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max)
			,@year	nvarchar(2)
			,@month nvarchar(2) ;

	begin try

		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		declare @p_unique_code nvarchar(50) ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_code output
													,@p_branch_code = @p_branch_code
													,@p_sys_document_code = N''
													,@p_custom_prefix = 'IPR'
													,@p_year = @year
													,@p_month = @month
													,@p_table_name = 'IFINPROC_INTERFACE_PAYMENT_REQUEST'
													,@p_run_number_length = 6
													,@p_delimiter = '.'
													,@p_run_number_only = N'0' ;


		insert into dbo.ifinproc_interface_payment_request
		(
			code
			,branch_code
			,branch_name
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
			,settle_date
			,tax_file_name
			,job_status
			,failed_remarks
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_code
			,@p_branch_code
			,@p_branch_name
			,@p_payment_source
			,@p_payment_request_date
			,@p_payment_source_no
			,@p_payment_status
			,@p_payment_currency_code
			,@p_payment_amount
			,@p_payment_to
			,@p_payment_remarks
			,@p_to_bank_account_name
			,@p_to_bank_name
			,@p_to_bank_account_no
			,@p_process_date
			,@p_process_reff_no
			,@p_process_reff_name
			,@p_tax_payer_reff_code
			,@p_tax_type
			,@p_tax_file_no
			,@p_tax_file_name
			,@p_settle_date
			,@p_job_status
			,@p_failed_remarks
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

