CREATE FUNCTION dbo.xfn_credit_note_get_ppn
(
	@p_id BIGINT
)
RETURNS INT
AS
BEGIN
	DECLARE @total_amount			 DECIMAL(18, 2)
			,@is_journal_ppn_wapu	 NVARCHAR(1)
	 
	SELECT	@is_journal_ppn_wapu = aa.is_journal_ppn_wapu
	FROM	dbo.invoice aa
			INNER JOIN dbo.invoice_detail id ON (id.invoice_no = aa.invoice_no)
	WHERE	id = @p_id ;

	IF (@is_journal_ppn_wapu = '0')
	BEGIN 
		SELECT	@total_amount = invd.ppn_amount - cnd.new_ppn_amount
		FROM	dbo.credit_note_detail cnd
				INNER JOIN dbo.credit_note cn ON (cn.code = cnd.credit_note_code)
					INNER JOIN dbo.invoice_detail invd ON (invd.id = cnd.invoice_detail_id)
		WHERE	invoice_detail_id		 = @p_id
				AND cn.status			 = 'ON PROCESS'
				--AND cnd.new_total_amount > 0 ;
				and cnd.adjustment_amount > 0 ;
	END
	else
	begin
		set @total_amount = 0 ;
	end ;

	if (@total_amount < 0)--(+) raffy 2025/05/23 jika hasil dari kalkulasi, terdapat minus. maka seharusnya ada nilai yang salah antara invoice atau di credit note nya
	begin
		set @total_amount = 0
	end

	return isnull(@total_amount, 0) ;
end ;
