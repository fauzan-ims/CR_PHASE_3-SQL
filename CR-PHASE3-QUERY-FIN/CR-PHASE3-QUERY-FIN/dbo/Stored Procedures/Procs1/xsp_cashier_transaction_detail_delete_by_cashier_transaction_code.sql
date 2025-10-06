CREATE PROCEDURE dbo.xsp_cashier_transaction_detail_delete_by_cashier_transaction_code
(
	@p_cashier_transaction_code nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		delete cashier_transaction_detail
		where	cashier_transaction_code = @p_cashier_transaction_code
				and isnull(received_request_code, '') not in
					(
						select	code
						from	dbo.cashier_received_request
						where	process_reff_code = @p_cashier_transaction_code
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
