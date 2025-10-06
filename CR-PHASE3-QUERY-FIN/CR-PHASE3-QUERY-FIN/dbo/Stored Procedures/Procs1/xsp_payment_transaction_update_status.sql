
CREATE PROCEDURE dbo.xsp_payment_transaction_update_status
(
	@p_code				nvarchar(50)
	,@p_payment_status	nvarchar(10)
	,@p_mod_date		DATETIME
	,@p_mod_by			NVARCHAR(15)
	,@p_mod_ip_address	NVARCHAR(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	dbo.payment_transaction
		set		payment_status	= @p_payment_status
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address
		where	code = @p_code ;
	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = N'V' + N';' + @msg ;
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
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
