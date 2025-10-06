
-- User Defined Function

CREATE FUNCTION [dbo].[xfn_invoice_registration_get_price_amount_grn]
(
	@p_id	bigint
)returns decimal(18, 2)
as
begin

	declare @return_amount			decimal(18,2)
			,@amount_grn			decimal(18,2)

	select	@amount_grn		= grnd.price_amount - grnd.discount_amount
	from	dbo.ap_invoice_registration_detail				invd
			inner join dbo.good_receipt_note_detail			grnd on grnd.id = invd.grn_detail_id 
			inner join dbo.good_receipt_note				grn on (grn.code							  = grnd.good_receipt_note_code)
	where	invd.id = @p_id
	and		grnd.receive_quantity	<> 0

	set @return_amount = isnull(@amount_grn,0)

	return @return_amount
end
