CREATE PROCEDURE dbo.xsp_cashier_transaction_invoice_delete_auto_allocate
(
	@p_cashier_transaction_code			 nvarchar(50)
	--
	,@p_cre_date						 datetime
	,@p_cre_by							 nvarchar(15)
	,@p_cre_ip_address					 nvarchar(15)
	,@p_mod_date						 datetime
	,@p_mod_by							 nvarchar(15)
	,@p_mod_ip_address					 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
	    delete	cashier_transaction_invoice
		where	cashier_transaction_code = @p_cashier_transaction_code ;

	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
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
