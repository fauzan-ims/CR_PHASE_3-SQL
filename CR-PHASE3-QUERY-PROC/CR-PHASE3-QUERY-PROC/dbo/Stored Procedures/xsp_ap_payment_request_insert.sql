CREATE PROCEDURE [dbo].[xsp_ap_payment_request_insert]
(
	@p_code					 nvarchar(50) output
	,@p_company_code		 nvarchar(50)
	,@p_invoice_date		 datetime
	,@p_currency_code		 nvarchar(50)
	,@p_supplier_code		 nvarchar(50)
	,@p_supplier_name		 nvarchar(50)
	,@p_invoice_amount		 decimal(18, 2)
	,@p_ppn					 decimal(18, 2)
	,@p_pph					 decimal(18, 2)
	,@p_fee					 decimal(18, 2)
	,@p_discount			 decimal(18, 2)
	,@p_due_date			 datetime
	,@p_purchase_order_code		nvarchar(50)
	,@p_tax_invoice_date	 datetime
	,@p_branch_code			 nvarchar(50)
	,@p_branch_name			 nvarchar(250)
	,@p_to_bank_code		 nvarchar(50)
	,@p_to_bank_account_name nvarchar(250)
	,@p_to_bank_account_no	 nvarchar(250)
	,@p_to_bank_name		 nvarchar(250)
	,@p_payment_by			 nvarchar(25)
	,@p_status				 nvarchar(25)
	,@p_remark				 nvarchar(4000)
	,@p_date_flag			 datetime
	--
	,@p_cre_date			 datetime
	,@p_cre_by				 nvarchar(15)
	,@p_cre_ip_address		 nvarchar(15)
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
)
as
begin
	declare @msg	nvarchar(max)
			,@year	nvarchar(2)
			,@month nvarchar(2)
			,@code	nvarchar(50) ;

	begin try
		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			= @code output
													,@p_branch_code			= @p_company_code
													,@p_sys_document_code	= N''
													,@p_custom_prefix		= 'APR'
													,@p_year				= @year
													,@p_month				= @month
													,@p_table_name			= 'AP_PAYMENT_REQUEST'
													,@p_run_number_length	= 6
													,@p_delimiter			= '.'
													,@p_run_number_only		= N'0' ;

		insert into ap_payment_request
		(
			code
			,company_code
			,invoice_date
			,currency_code
			,supplier_code
			,supplier_name
			,invoice_amount
			,ppn
			,pph
			,fee
			,discount
			,due_date
			,purchase_order_code
			,tax_invoice_date
			,branch_code
			,branch_name
			,to_bank_code
			,to_bank_account_name
			,to_bank_account_no
			,to_bank_name
			,payment_by
			,status
			,remark
			,date_flag
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@code
			,@p_company_code
			,@p_invoice_date
			,@p_currency_code
			,@p_supplier_code
			,@p_supplier_name
			,@p_invoice_amount
			,@p_ppn
			,@p_pph
			,@p_fee
			,@p_discount
			,@p_due_date
			,@p_purchase_order_code
			,@p_tax_invoice_date
			,@p_branch_code
			,@p_branch_name
			,@p_to_bank_code
			,@p_to_bank_account_name
			,@p_to_bank_account_no
			,@p_to_bank_name
			,@p_payment_by
			,@p_status
			,@p_remark
			,@p_date_flag
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_code = @code ;
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
end ;

