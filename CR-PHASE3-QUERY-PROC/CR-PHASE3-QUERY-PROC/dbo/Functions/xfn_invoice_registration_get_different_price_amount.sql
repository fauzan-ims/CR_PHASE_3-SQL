
-- User Defined Function

-- User Defined Function

CREATE FUNCTION [dbo].[xfn_invoice_registration_get_different_price_amount]
(
	@p_id	bigint
)returns decimal(18, 2)
as
begin

	declare @return_amount			decimal(18,2)
			,@price_amount			decimal(18, 2)
			,@amount_invoice		decimal(18, 2)
			,@amount_grn			decimal(18, 2)


		select	@amount_invoice = purchase_amount
		from	dbo.ap_invoice_registration_detail
		where	id = @p_id ;

		select	@amount_grn = grnd.price_amount
		from	dbo.ap_invoice_registration_detail				ard
				inner join dbo.ap_invoice_registration			air on ard.invoice_register_code		   = air.code
				inner join dbo.good_receipt_note_detail			grnd on grnd.good_receipt_note_code		   = ard.grn_code
																		and grnd.receive_quantity		   <> 0
																		and grnd.purchase_order_detail_id  = ard.purchase_order_id
		where	ard.ID = @p_id

		set @return_amount = isnull(@amount_grn,0) - isnull(@amount_invoice,0)

	return @return_amount
end
