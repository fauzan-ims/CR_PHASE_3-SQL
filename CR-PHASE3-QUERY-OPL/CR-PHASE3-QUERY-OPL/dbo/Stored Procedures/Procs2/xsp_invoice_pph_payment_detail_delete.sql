CREATE procedure dbo.xsp_invoice_pph_payment_detail_delete
(
	@p_id			   bigint
	,@p_code		   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg		 nvarchar(max)
			,@invoice_no nvarchar(50)
			,@total		 decimal(18, 2) ;

	begin try

		--select invoice no dari tabel pph payment detail
		select	@invoice_no = invoice_no
		from	dbo.invoice_pph_payment_detail
		where	id = @p_id ;

		--update data di tabel invoice
		update	dbo.invoice
		set		payment_pph_code	= null
				,payment_pph_date	= null 
		where	invoice_no			= @invoice_no;

		--delete data di tabel pph payment detail
		delete invoice_pph_payment_detail
		where	id = @p_id ;

		--select sum pph amount dari vat payment detail
		select @total = sum(pph_amount)
		from dbo.invoice_pph_payment_detail
		where tax_payment_code = @p_code

		--update data invoice vat payment
		update	dbo.invoice_pph_payment
		set		total_pph_amount = isnull(@total, 0)
		where	code = @p_code

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
