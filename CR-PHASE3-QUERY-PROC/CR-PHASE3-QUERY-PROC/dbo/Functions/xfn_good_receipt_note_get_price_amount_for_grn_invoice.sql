
-- User Defined Function

-- User Defined Function

-- User Defined Function

CREATE FUNCTION [dbo].[xfn_good_receipt_note_get_price_amount_for_grn_invoice]
(
	@p_id	INT
)RETURNS DECIMAL(18, 2)
AS
BEGIN

	DECLARE @return_amount			DECIMAL(18,2)
			,@price_amount			DECIMAL(18, 2)


		SELECT	@price_amount = (grnd.PRICE_AMOUNT - grnd.DISCOUNT_AMOUNT) --* receive_quantity
		FROM	dbo.AP_INVOICE_REGISTRATION_DETAIL apd
				INNER JOIN dbo.good_receipt_note_detail grnd ON apd.GRN_CODE COLLATE SQL_Latin1_General_CP1_CI_AS = grnd.GOOD_RECEIPT_NOTE_CODE COLLATE SQL_Latin1_General_CP1_CI_AS AND apd.ITEM_CODE COLLATE SQL_Latin1_General_CP1_CI_AS = grnd.ITEM_CODE COLLATE SQL_Latin1_General_CP1_CI_AS
		WHERE	apd.ID = @p_id

	SET @return_amount = isnull(@price_amount,0)

	return @return_amount
end
