--created by, Rian at 23/02/2023 

create procedure xsp_invoice_vat_payment_cancel
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg		 nvarchar(max)
			,@invoice_no nvarchar(50) ;

	begin try
		--declare cursor dari invoice vat payment detail untuk looping invoice no nya
		declare c_vat_payment_detail cursor for
		select	invoice_no
		from	dbo.invoice_vat_payment_detail
		where	tax_payment_code = @p_code ;

		--open cursor
		open c_vat_payment_detail ;

		--fetch cursor
		fetch c_vat_payment_detail
		into @invoice_no ;

		while @@fetch_status = 0
		begin
			update	dbo.invoice
			set		payment_ppn_code	= null
					,payment_ppn_date	= null
			where	invoice_no = @invoice_no ;

			--fetch cursor lagi
			fetch c_vat_payment_detail
			into @invoice_no ;
		end ;

		-- close and deallocate cursor
		close c_vat_payment_detail ;

		--update tabel vat payment
		update	dbo.invoice_vat_payment
		set		status = 'cancel'
		where	code = @p_code

		deallocate c_vat_payment_detail ;
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
