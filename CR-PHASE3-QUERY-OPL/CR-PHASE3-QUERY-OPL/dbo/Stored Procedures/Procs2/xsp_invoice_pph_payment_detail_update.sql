CREATE PROCEDURE dbo.xsp_invoice_pph_payment_detail_update
(
	@p_id				 bigint
	,@p_tax_payment_code nvarchar(50)
	,@p_invoice_no		 nvarchar(50)
	,@p_pph_amount		 decimal(18, 2)
	--
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	invoice_pph_payment_detail
		set		tax_payment_code = @p_tax_payment_code
				,invoice_no = @p_invoice_no
				,pph_amount = @p_pph_amount
				--
				,mod_date = @p_mod_date
				,mod_by = @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	id = @p_id ;
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
