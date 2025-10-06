CREATE FUNCTION dbo.xfn_new_good_receipt_note_get_price_amount_for_grn
(
	@p_id	INT
)RETURNS DECIMAL(18, 2)
AS
BEGIN
	
	DECLARE @return_amount			DECIMAL(18,2)
			,@price_amount			DECIMAL(18, 2)


		SELECT @price_amount = (aird.purchase_amount - aird.discount) --* aird.quantity
		FROM dbo.ap_invoice_registration_detail aird
		INNER JOIN ifinbam.dbo.master_item mi ON mi.code collate latin1_general_ci_as = aird.item_code
		WHERE id = @p_id
		--and mi.item_group_code <> 'MOBLS'

	SET @return_amount = isnull(@price_amount,0)

	return @return_amount
end
