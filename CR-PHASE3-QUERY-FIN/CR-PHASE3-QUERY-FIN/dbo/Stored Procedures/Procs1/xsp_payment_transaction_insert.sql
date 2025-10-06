CREATE PROCEDURE dbo.xsp_payment_transaction_insert
(
	@p_code						   nvarchar(50) output
	,@p_branch_code				   nvarchar(50)
	,@p_branch_name				   nvarchar(250)
	,@p_payment_status			   nvarchar(10)
	,@p_payment_transaction_date   datetime
	,@p_payment_value_date		   datetime
	,@p_payment_orig_amount		   decimal(18, 2)
	,@p_payment_orig_currency_code nvarchar(3)
	,@p_payment_exch_rate		   decimal(18, 6)
	,@p_payment_base_amount		   decimal(18, 2)
	,@p_payment_type			   nvarchar(10)
	,@p_payment_remarks			   nvarchar(4000)
	,@p_branch_bank_code		   nvarchar(50)
	,@p_branch_bank_name		   nvarchar(250)
	,@p_branch_bank_account_no	   nvarchar(250)
	,@p_bank_gl_link_code		   nvarchar(50)
	,@p_pdc_code				   nvarchar(50)
	,@p_pdc_no					   nvarchar(50)
	,@p_to_bank_name			   nvarchar(250)   = null
	,@p_to_bank_account_name	   nvarchar(250)   = null
	,@p_to_bank_account_no		   nvarchar(50)	   = null
	,@p_is_reconcile			   nvarchar(1)
	,@p_reconcile_date			   datetime		   = null
	,@p_reversal_code			   nvarchar(50)	   = null
	,@p_reversal_date			   datetime		   = null
	--
	,@p_cre_date				   datetime
	,@p_cre_by					   nvarchar(15)
	,@p_cre_ip_address			   nvarchar(15)
	,@p_mod_date				   datetime
	,@p_mod_by					   nvarchar(15)
	,@p_mod_ip_address			   nvarchar(15)
)
as
begin
	declare @year	nvarchar(4)
			,@month nvarchar(2)
			,@msg	nvarchar(max)
			,@code	nvarchar(50) ;

	if @p_is_reconcile = 'T'
		set @p_is_reconcile = '1' ;
	else
		set @p_is_reconcile = '0' ;

	begin try
		if (@p_payment_value_date > dbo.xfn_get_system_date()) 
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Value Date','System Date');
			raiserror(@msg ,16,-1)
		end

		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code				= @code output
														,@p_branch_code			= ''
														,@p_sys_document_code	= N''
														,@p_custom_prefix		= 'IFPC'
														,@p_year				= @year
														,@p_month				= ''
														,@p_table_name			= 'PAYMENT_TRANSACTION'
														,@p_run_number_length	= 4
														,@p_delimiter			= ''
														,@p_run_number_only		= N'0' ;
		set @p_code = @code;
		insert into payment_transaction
		(
			code
			,branch_code
			,branch_name
			,payment_status
			,payment_transaction_date
			,payment_value_date
			,payment_orig_amount
			,payment_orig_currency_code
			,payment_exch_rate
			,payment_base_amount
			,payment_type
			,payment_remarks
			,branch_bank_code
			,branch_bank_name
			,bank_gl_link_code
			,branch_bank_account_no
			,pdc_code
			,pdc_no
			,to_bank_name
			,to_bank_account_name
			,to_bank_account_no
			,is_reconcile
			,reconcile_date
			,reversal_code
			,reversal_date
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
			,@p_payment_status
			,@p_payment_transaction_date
			,@p_payment_value_date
			,@p_payment_orig_amount
			,@p_payment_orig_currency_code
			,@p_payment_exch_rate
			,@p_payment_base_amount
			,@p_payment_type
			,@p_payment_remarks
			,@p_branch_bank_code
			,@p_branch_bank_name
			,@p_bank_gl_link_code
			,@p_branch_bank_account_no
			,@p_pdc_code
			,@p_pdc_no
			,@p_to_bank_name
			,@p_to_bank_account_name
			,@p_to_bank_account_no
			,@p_is_reconcile
			,@p_reconcile_date
			,@p_reversal_code
			,@p_reversal_date
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
