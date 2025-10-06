CREATE PROCEDURE dbo.xsp_invoice_pph_payment_update
(
	@p_code						nvarchar(50)
	,@p_branch_code				nvarchar(50)
	,@p_branch_name				nvarchar(250)
	,@p_status					nvarchar(10)
	,@p_date					datetime
	,@p_remark					nvarchar(4000)
	,@p_total_pph_amount		decimal(18, 2)
	--,@p_process_date			datetime
	--,@p_process_reff_no			nvarchar(50)
	--,@p_process_reff_name		nvarchar(250)
	,@p_currency_code			nvarchar(3)
	,@p_tax_bank_name			nvarchar(50)
	,@p_tax_bank_account_name	nvarchar(50)
	,@p_tax_bank_account_no		nvarchar(50)
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	invoice_pph_payment
		set		branch_code				= @p_branch_code
				,branch_name			= @p_branch_name
				,status					= @p_status
				,date					= @p_date
				,remark					= @p_remark
				,total_pph_amount		= @p_total_pph_amount
				--,process_date			= @p_process_date
				--,process_reff_no		= @p_process_reff_no
				--,process_reff_name		= @p_process_reff_name
				,currency_code			= @p_currency_code
				,tax_bank_name			= @p_tax_bank_name
				,tax_bank_account_name	= @p_tax_bank_account_name
				,tax_bank_account_no	= @p_tax_bank_account_no
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code = @p_code ;
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
