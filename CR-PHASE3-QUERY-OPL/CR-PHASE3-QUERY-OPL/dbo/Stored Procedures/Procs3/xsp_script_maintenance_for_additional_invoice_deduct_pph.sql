CREATE PROCEDURE dbo.xsp_script_maintenance_for_additional_invoice_deduct_pph
	@invoice_no		NVARCHAR(50)	= ''
	,@is_pph		NVARCHAR(1)		= '1' -- isi 1 jika potong pph, isi 0 jika tidak
	,@pph_pct		DECIMAL(9,6)	= '2' -- isi dengan nominal persen potongan PPH, contoh = 2 untuk 2 persen
	--
	,@p_mtn_remark	nvarchar(4000)	= ''
	,@p_mtn_cre_by	nvarchar(250)	= ''

AS
BEGIN

begin try
begin transaction ;

DECLARE @msg NVARCHAR(250)
 
IF EXISTS (SELECT 1 FROM dbo.INVOICE WHERE INVOICE_NO = REPLACE(@invoice_no,'/','.') AND INVOICE_STATUS <> 'POST')
BEGIN
    RAISERROR('tidak bisa dicancel karena status invoice bukan Post',16,1)
	RETURN
END

--IF EXISTS (SELECT 1 FROM dbo.AGREEMENT_ASSET_AMORTIZATION WHERE INVOICE_NO = REPLACE(@invoice_no,'/','.'))
--BEGIN
--    RAISERROR('tidak bisa dicancel karena ini invoice rental',16,1)
--	RETURN
--END

DELETE dbo.INVOICE_PPH WHERE INVOICE_NO = @invoice_no

IF(@is_pph = '1')
BEGIN

		UPDATE dbo.INVOICE_DETAIL
		SET		PPH_PCT			= @pph_pct
				,PPH_AMOUNT		 =round(((BILLING_AMOUNT - 0) * 1 * @pph_pct / 100),0)-- dbo.fn_get_floor(BILLING_AMOUNT * (@pph_pct/100), 1)--ceiling(BILLING_AMOUNT * (@pph_pct/100))
				,TOTAL_AMOUNT	= BILLING_AMOUNT + PPN_AMOUNT - round(((BILLING_AMOUNT - 0) * 1 * @pph_pct / 100),0) --dbo.fn_get_floor(BILLING_AMOUNT * (@pph_pct/100), 1)--ceiling(BILLING_AMOUNT * (@pph_pct/100))
				,MOD_DATE		= GETDATE()
				,MOD_BY			= @p_mtn_cre_by
				,MOD_IP_ADDRESS = 'UPDATE PPH'
		WHERE INVOICE_NO = REPLACE(@invoice_no,'/','.')

		UPDATE dbo.INVOICE
		SET		TOTAL_PPH_AMOUNT	= invd.tot_pph_amount
				,TOTAL_AMOUNT		= invd.tot_Amount
				,IS_INVOICE_DEDUCT_PPH = '1'--diupdate jadi 0 dulu, biar masuk ke sp xsp_mtn_invoice_pph, jadi 1
				,MOD_DATE		= GETDATE()
				,MOD_BY			= @p_mtn_cre_by
				,MOD_IP_ADDRESS = 'UPDATE PPH'
		FROM dbo.INVOICE inv
		OUTER APPLY (	SELECT  SUM(invd.PPH_AMOUNT)  'tot_pph_amount'
								,SUM(invd.TOTAL_AMOUNT) 'tot_Amount'
						FROM	dbo.INVOICE_DETAIL invd
						WHERE	invd.INVOICE_NO = inv.invoice_no
					) invd
		WHERE INVOICE_NO = REPLACE(@invoice_no,'/','.')
END

SET @invoice_no  =  REPLACE(@invoice_no,'/','.')
SET @p_mtn_remark = 'Revisi Tax Scheme PPH - ' + @p_mtn_remark

IF EXISTS
(
	SELECT 1
	FROM IFINFIN.dbo.CASHIER_RECEIVED_REQUEST
	WHERE DOC_REF_CODE = @invoice_no
	AND REQUEST_STATUS = 'HOLD'
)
BEGIN

SELECT 'MASUK'

EXEC dbo.xsp_mtn_invoice_pph @p_invoice_no = @invoice_no,            -- nvarchar(50)
                             @p_is_invoice_deduct_pph = @is_pph, -- nvarchar(1)
                             @p_mtn_remark = @p_mtn_remark,            -- nvarchar(4000)
                             @p_mtn_cre_by = @p_mtn_cre_by             -- nvarchar(250)

END
UPDATE	dbo.AGREEMENT_INVOICE_PPH
SET		PPH_AMOUNT		= invd.PPH_AMOUNT
		,MOD_DATE		= GETDATE()
		,MOD_BY			= @p_mtn_cre_by
		,MOD_IP_ADDRESS = 'UPDATE PPH'
FROM	dbo.AGREEMENT_INVOICE_PPH aph
INNER JOIN dbo.INVOICE_DETAIL invd ON invd.AGREEMENT_NO = aph.AGREEMENT_NO AND invd.ASSET_NO = aph.ASSET_NO AND invd.BILLING_NO = aph.BILLING_NO AND invd.INVOICE_NO = aph.INVOICE_NO
WHERE invd.INVOICE_NO = @invoice_no

SELECT 'invoice', * FROM dbo.INVOICE WHERE INVOICE_NO = @invoice_no
SELECT 'invoice_detail', * FROM dbo.INVOICE_DETAIL WHERE INVOICE_NO = @invoice_no
SELECT 'AGREEMENT_INVOICE_PPH',* FROM dbo.AGREEMENT_INVOICE_PPH WHERE INVOICE_NO = @invoice_no
SELECT 'INVOICE_PPH',* FROM dbo.INVOICE_PPH WHERE INVOICE_NO = @invoice_no

	if @@error = 0
	begin
		select 'SUCCESS'
		commit transaction ; 
	end ;
	else
	begin
		select 'GAGAL PROCESS : ' + @msg
		rollback transaction ;
	end

end try
begin catch
	select 'GAGAL PROCESS : ' + @msg
	rollback transaction ;
end catch ;

END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_script_maintenance_for_additional_invoice_deduct_pph] TO [DSF\eddy.rakhman]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_script_maintenance_for_additional_invoice_deduct_pph] TO [eddy.r]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_script_maintenance_for_additional_invoice_deduct_pph] TO [ims-raffyanda]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_script_maintenance_for_additional_invoice_deduct_pph] TO [eddy.rakhman]
    AS [dbo];

