--created by, Rian at 18/03/2023 

CREATE procedure xsp_agreement_asset_interest_income_update
(
	@p_agreement_no			nvarchar(50)
	,@p_asset_no			nvarchar(50)
	,@p_instalment_no		int
	,@p_invoice_no			nvarchar(50)
	,@p_branch_code			nvarchar(50)
	,@p_branch_name			nvarchar(250)
	,@p_transaction_date	datetime
	,@p_income_amount		decimal(18, 2)
	,@p_reff_no				nvarchar(50)
	,@p_reff_name			nvarchar(250)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
AS
BEGIN
	declare	@msg	nvarchar(max)
	begin try
		update	dbo.agreement_asset_interest_income
		set		agreement_no		= @p_agreement_no
				,asset_no			= @p_asset_no
				,installment_no		= @p_instalment_no
				,invoice_no			= @p_invoice_no
				,branch_code		= @p_branch_code
				,branch_name		= @p_branch_name
				,transaction_date	= @p_transaction_date
				,income_amount		= @p_income_amount
				,reff_no			= @p_reff_no
				,reff_name			= @p_reff_name
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	agreement_no		= @p_agreement_no



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
END
