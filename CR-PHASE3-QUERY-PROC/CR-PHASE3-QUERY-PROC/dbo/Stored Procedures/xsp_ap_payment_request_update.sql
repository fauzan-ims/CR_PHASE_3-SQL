CREATE PROCEDURE dbo.xsp_ap_payment_request_update
(
	@p_code					 nvarchar(50)
	,@p_company_code		 nvarchar(50)	= ''
	,@p_invoice_date		 datetime
	,@p_currency_code		 nvarchar(50)
	,@p_supplier_code		 nvarchar(50) 
	,@p_invoice_amount		 decimal(18, 2)
	,@p_ppn					 decimal(18, 2)
	,@p_pph					 decimal(18, 2)
	,@p_fee					 decimal(18, 2)
	,@p_discount			 decimal(18, 2)
	,@p_due_date			 datetime
	,@p_tax_invoice_date	 datetime
	--,@p_branch_code			 nvarchar(50)
	--,@p_branch_name			 nvarchar(250)
	,@p_to_bank_code		 nvarchar(50)	= ''
	,@p_to_bank_account_name nvarchar(250)	= ''
	,@p_to_bank_account_no	 nvarchar(250)	= ''
	,@p_payment_by			 nvarchar(25)	= ''
	,@p_status				 nvarchar(25)
	,@p_remark				 nvarchar(4000)
	--
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	select	@p_company_code		   = company_code
	from	dbo.ap_payment_request
	where	code = @p_code ;

	begin try
		update	ap_payment_request
		set		remark					= @p_remark
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code					= @p_code ;
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
