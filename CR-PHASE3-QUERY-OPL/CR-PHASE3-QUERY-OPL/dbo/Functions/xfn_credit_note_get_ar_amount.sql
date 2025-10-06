CREATE FUNCTION dbo.xfn_credit_note_get_ar_amount
 (
 	@p_id BIGINT
 )
 RETURNS DECIMAL(18, 2)
 AS
 BEGIN
 	DECLARE @total_amount			 DECIMAL(18, 2)
 			,@first_payment_type	 NVARCHAR(3) ;
 
 	SELECT	@first_payment_type = aa.first_payment_type 
 	FROM	dbo.agreement_asset aa
 			INNER JOIN dbo.invoice_detail id ON (id.asset_no = aa.asset_no)
 	WHERE	id = @p_id ;
 
	--untuk mendapatkan PENDAPATAN
 	IF (@first_payment_type = 'ARR')
 	BEGIN 
		SELECT	@total_amount = ISNULL(invd.BILLING_AMOUNT,0) - ISNULL(cnd.new_rental_amount, 0)
		FROM	dbo.credit_note_detail cnd
				INNER JOIN dbo.credit_note cn ON (cn.code = cnd.credit_note_code)
				INNER JOIN dbo.invoice_detail invd ON (invd.id = cnd.invoice_detail_id)
		WHERE	invoice_detail_id		 = @p_id
				AND cn.status			 = 'ON PROCESS'
				--and cnd.new_total_amount > 0 ;
				and cnd.adjustment_amount > 0 ;
 	end ;
 	else
 	begin
 		set @total_amount = 0 ;
 	end ;
 
 	return isnull(@total_amount, 0) ;
 end ;
