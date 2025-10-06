CREATE PROCEDURE dbo.xsp_invoice_update_new_date
(
	@p_invoice_no					nvarchar(50)
	,@p_new_invoice_date			datetime
	--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg		   nvarchar(max)
			,@invoice_date datetime ;

	select	@invoice_date = invoice_date
	from	invoice
	where	invoice_no = @p_invoice_no ;

	if @p_new_invoice_date < @invoice_date
		begin
	
			set @msg = 'New invoice date must be greater or equal to invoice date';
	
			raiserror(@msg, 16, -1) ;
	
		end   

	begin try

		update	invoice
		set		new_invoice_date		= @p_new_invoice_date
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	invoice_no				= @p_invoice_no ;

	end try
	Begin catch
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
