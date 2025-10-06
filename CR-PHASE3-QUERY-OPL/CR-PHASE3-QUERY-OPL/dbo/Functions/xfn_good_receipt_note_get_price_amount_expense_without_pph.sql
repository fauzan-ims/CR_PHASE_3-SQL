
-- User Defined Function

CREATE FUNCTION [dbo].[xfn_good_receipt_note_get_price_amount_expense_without_pph]
(
	@p_id	int
	,@p_po_object_id bigint
)returns decimal(18, 2)
as
begin

	declare @return_amount			decimal(18,2)
			,@price_amount			decimal(18, 2)


		select @price_amount = (price_amount - grnd.discount_amount) --* receive_quantity
		from	dbo.good_receipt_note_detail grnd
				inner join ifinbam.dbo.master_item mi on mi.code = grnd.item_code
				inner join dbo.purchase_order_detail_object_info podoi  on podoi.good_receipt_note_detail_id = grnd.id
		where	grnd.id = @p_id
		and		mi.item_group_code = 'EXPS'
		and		isnull(grnd.pph_amount,0) = 0
		and		podoi.id = @p_po_object_id

	set @return_amount = isnull(@price_amount,0)

	return @return_amount
end
