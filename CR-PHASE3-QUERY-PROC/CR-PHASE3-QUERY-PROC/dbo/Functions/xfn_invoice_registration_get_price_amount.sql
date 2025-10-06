
-- User Defined Function

CREATE FUNCTION [dbo].[xfn_invoice_registration_get_price_amount]
(
	@p_id	bigint
    ,@p_po_object_id	bigint = 0
)returns decimal(18, 2)
as
begin

	declare @return_amount			decimal(18,2)
			,@price_amount			decimal(18, 2)

			,@grn_id				bigint

	select	@grn_id	= grn_detail_id
			--@price_amount = (purchase_amount - discount)-- * quantity
	from	dbo.ap_invoice_registration_detail
	where	id = @p_id

	--12082025: sepria, CR Priority. ini dengan nilai = di GRN
	select	@price_amount =  isnull(price_amount,0) - isnull(discount_amount,0)
	from	dbo.good_receipt_note_detail
	where	id = @grn_id

	set @return_amount = isnull(@price_amount,0)

	return @return_amount
end
