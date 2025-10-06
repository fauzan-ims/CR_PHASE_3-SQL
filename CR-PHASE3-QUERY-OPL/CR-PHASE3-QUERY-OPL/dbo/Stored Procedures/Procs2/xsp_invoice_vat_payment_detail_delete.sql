CREATE PROCEDURE dbo.xsp_invoice_vat_payment_detail_delete
(
	@p_id			   bigint
	,@p_vat_code	   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg		 nvarchar(max)
			,@invoice_no nvarchar(50)
			,@total		 decimal(18,2) ;

	begin try
		--ambil invoice no dari vat payment detail
		select	@invoice_no = invoice_no
		from	dbo.invoice_vat_payment_detail
		where	id = @p_id ;

		--update data di tabel invoice
		update	dbo.invoice
		set		payment_ppn_code	= null
				,payment_ppn_date	= null
				--
				,@p_mod_date		= @p_mod_date
				,@p_mod_by			= @p_mod_by
				,@p_mod_ip_address	= @p_mod_ip_address
		where	invoice_no			= @invoice_no ;

		--delete data di tabel vat payment detail
		delete invoice_vat_payment_detail
		where	id = @p_id 
		and		tax_payment_code = @p_vat_code;

		--select sum ppn amount dari vat payment detail
		select @total = sum(ppn_amount)
		from dbo.invoice_vat_payment_detail
		where tax_payment_code = @p_vat_code

		--update data invoice vat payment
		update	dbo.invoice_vat_payment
		set		total_ppn_amount = isnull(@total, 0)
		where	code = @p_vat_code

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
