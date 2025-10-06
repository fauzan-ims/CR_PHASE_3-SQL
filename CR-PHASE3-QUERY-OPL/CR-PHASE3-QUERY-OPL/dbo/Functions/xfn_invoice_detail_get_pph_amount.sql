
CREATE FUNCTION dbo.xfn_invoice_detail_get_pph_amount
(
    @p_id bigint
)
returns decimal(18, 2)
AS
begin
    declare @pph_amount decimal(18, 2);
	-- hari 2023/09/07 - perubahan cara ambil pph jika pkp maka ada isinya
	
	
	if exists-- raffy 2025/06/11 jika ada credit note, maka pph diambil dari credit note 
	(
		select	1
		from	dbo.credit_note cn 
		inner join dbo.credit_note_detail cnd on cnd.credit_note_code = cn.code
		where	cnd.invoice_detail_id = @p_id
				and cn.status = 'post'
	)
	BEGIN
		SELECT	@pph_amount = CASE iv.settlement_type
		                         WHEN 'pkp' THEN
		                             cnd.new_pph_amount
		                         ELSE
		                             0
		                     END
		FROM	dbo.credit_note cn 
		INNER JOIN dbo.credit_note_detail cnd ON cnd.credit_note_code = cn.code
		INNER JOIN dbo.invoice_pph iv ON iv.invoice_no = cn.invoice_no
		WHERE	cnd.invoice_detail_id = @p_id
				AND cn.status = 'POST'

	END
	ELSE
    BEGIN
		SELECT @pph_amount = CASE iv.settlement_type
		                         WHEN 'pkp' THEN
		                             pph_amount
		                         ELSE
		                             0
		                     end
		from dbo.invoice_detail ivd
		    inner join dbo.invoice_pph iv
		        on iv.invoice_no = ivd.invoice_no
		where ivd.id = @p_id;
	end
    return isnull(@pph_amount, 0);
end;
