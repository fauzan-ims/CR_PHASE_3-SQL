CREATE PROCEDURE dbo.xsp_payment_voucher_update
(
	@p_code						   nvarchar(50)
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
	,@p_branch_gl_link_code		   nvarchar(50)
	,@p_pdc_code				   nvarchar(50) = null
	,@p_pdc_no					   nvarchar(50) = null
	,@p_to_bank_name			   nvarchar(250) = null
	,@p_to_bank_account_name	   nvarchar(250) = null
	,@p_to_bank_account_no		   nvarchar(50) = null
	--
	,@p_mod_date				   datetime
	,@p_mod_by					   nvarchar(15)
	,@p_mod_ip_address			   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if (@p_pdc_code = '')
	begin
	    set @p_pdc_code = null
	end

	if (@p_pdc_no = '')
	begin
	    set @p_pdc_no = null
	end

	begin try

		if (@p_payment_value_date > dbo.xfn_get_system_date()) 
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Value Date','System Date');
			raiserror(@msg ,16,-1)
		end

		update	payment_voucher
		set		branch_code					= @p_branch_code
				,branch_name				= @p_branch_name
				,payment_status				= @p_payment_status
				,payment_transaction_date	= @p_payment_transaction_date
				,payment_value_date			= @p_payment_value_date
				,payment_orig_amount		= @p_payment_orig_amount
				,payment_orig_currency_code = @p_payment_orig_currency_code
				,payment_exch_rate			= @p_payment_exch_rate
				,payment_base_amount		= @p_payment_base_amount
				,payment_type				= @p_payment_type
				,payment_remarks			= @p_payment_remarks
				,branch_bank_code			= @p_branch_bank_code
				,branch_bank_name			= @p_branch_bank_name
				,branch_gl_link_code		= @p_branch_gl_link_code
				,pdc_code					= @p_pdc_code
				,pdc_no						= @p_pdc_no
				,to_bank_name				= @p_to_bank_name
				,to_bank_account_name		= @p_to_bank_account_name
				,to_bank_account_no			= @p_to_bank_account_no
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	code						= @p_code ;
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
