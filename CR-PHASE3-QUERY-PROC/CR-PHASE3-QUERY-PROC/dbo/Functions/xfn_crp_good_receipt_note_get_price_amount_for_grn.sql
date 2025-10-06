-- User Defined Function

CREATE FUNCTION dbo.xfn_crp_good_receipt_note_get_price_amount_for_grn
(
	@p_id	INT
)RETURNS DECIMAL(18, 2)
AS
BEGIN
	
	DECLARE @return_amount			DECIMAL(18,2)
			,@price_amount			DECIMAL(18, 2)


		SELECT @price_amount = (price_amount - grnd.DISCOUNT_AMOUNT) --* receive_quantity
		FROM dbo.good_receipt_note_detail grnd
		INNER JOIN ifinbam.dbo.master_item mi ON mi.code = grnd.item_code
		WHERE id = @p_id
		--and mi.item_group_code <> 'MOBLS'

	SET @return_amount = isnull(@price_amount,0)

	return @return_amount
end
