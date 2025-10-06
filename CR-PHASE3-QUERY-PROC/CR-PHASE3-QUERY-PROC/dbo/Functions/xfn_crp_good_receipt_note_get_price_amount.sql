CREATE FUNCTION dbo.xfn_crp_good_receipt_note_get_price_amount
(
	@p_id	int
)returns decimal(18, 2)
as
begin
	
	declare @return_amount			decimal(18,2)
			,@price_amount			decimal(18, 2)


		select @price_amount = (price_amount - grnd.DISCOUNT_AMOUNT) --* receive_quantity
		FROM dbo.good_receipt_note_detail grnd
		INNER JOIN ifinbam.dbo.master_item mi ON mi.code = grnd.item_code
		WHERE id = @p_id
		--and mi.item_group_code <> 'MOBLS'

	SET @return_amount = isnull(@price_amount,0)

	return @return_amount
end
