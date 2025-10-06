CREATE PROCEDURE dbo.xsp_invoice_pph_update
(
	@p_id					    bigint
	,@p_payment_reff_no		    nvarchar(50) = ''
	,@p_payment_reff_date	    nvarchar(50) = null
		--					    
	,@p_mod_date			    datetime
	,@p_mod_by				    nvarchar(15)
	,@p_mod_ip_address		    nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if(@p_payment_reff_date > dbo.xfn_get_system_date())
		begin
			set @msg = 'Payment Reff Date Must be Less Than System Date.';
			raiserror(@msg, 16, 1) ;
		end
	 
		update	invoice_pph
		set		payment_reff_no		= @p_payment_reff_no
				,payment_reff_date	= @p_payment_reff_date
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id	= @p_id

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
end
