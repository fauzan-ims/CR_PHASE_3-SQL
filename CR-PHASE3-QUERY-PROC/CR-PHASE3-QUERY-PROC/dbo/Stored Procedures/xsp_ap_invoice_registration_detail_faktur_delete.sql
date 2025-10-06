CREATE PROCEDURE [dbo].[xsp_ap_invoice_registration_detail_faktur_delete]
(
	@p_id bigint
)
as
begin
	declare @msg				nvarchar(max)
			,@grn_detail_id		int
			,@ppn				decimal(18, 2)
			,@pph				decimal(18, 2)
			,@price_amount		decimal(18, 2)
			,@total_amount		decimal(18, 2)
			,@id_invoice_detail int
			,@data_detail		int
			,@total_amount_head	decimal(18,2)
			,@discount_head		decimal(18,2)
			,@ppn_head			decimal(18, 2)
			,@pph_head			decimal(18, 2)
			,@invoice_code		nvarchar(50)

	begin try
		select	@grn_detail_id		= b.grn_detail_id
				,@id_invoice_detail = b.id
				,@invoice_code		= b.invoice_register_code
		from	dbo.ap_invoice_registration_detail_faktur	  a
				inner join dbo.ap_invoice_registration_detail b on a.invoice_registration_detail_id = b.id
		where	a.id = @p_id ;

		delete	dbo.ap_invoice_registration_detail_faktur
		where	id = @p_id ;

		select	@data_detail = count(1)
		from	dbo.ap_invoice_registration_detail_faktur
		where	invoice_registration_detail_id = @id_invoice_detail ;

		if (@data_detail = 0)
		begin
			exec dbo.xsp_ap_invoice_registration_detail_delete @p_id = @id_invoice_detail
		end ;
		else
		begin
			select	@ppn		   = ppn_amount
					,@pph		   = pph_amount
					,@price_amount = price_amount
					,@total_amount = isnull(total_amount, 0)
			from	dbo.good_receipt_note_detail
			where	id = @grn_detail_id ;

			update	dbo.ap_invoice_registration_detail
			set		purchase_amount = @price_amount
					,ppn = @ppn
					,pph = @pph
					,total_amount = @total_amount
					,qty_invoice = @data_detail
			where	id = @id_invoice_detail ;
		end ;

		select	@total_amount_head = isnull(sum(total_amount), 0)
				,@discount_head	   = isnull(sum(discount), 0)
				,@ppn_head		   = isnull(sum(ppn), 0)
				,@pph_head		   = isnull(sum(pph), 0)
		from	dbo.ap_invoice_registration_detail
		where	invoice_register_code = @invoice_code ;

		update	dbo.ap_invoice_registration
		set		invoice_amount	= @total_amount_head
				,ppn			= @ppn_head
				,pph			= @pph_head
				,discount		= @discount_head
		where	code			= @invoice_code ;
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
