
CREATE FUNCTION dbo.xfn_invoice_detail_get_pph_amount_this_year
(
	@p_id bigint
)
returns decimal(18, 2)
as
BEGIN
	declare @pph_amount decimal(18, 2) ;

	-- hari 2023/09/07 - perubahan cara ambil pph jika pkp maka ada isinya


	IF EXISTS-- raffy 2025/06/11 jika ada credit note, maka pph diambil dari credit note 
	(
		SELECT	1
		FROM	dbo.credit_note cn 
		INNER JOIN dbo.credit_note_detail cnd ON cnd.credit_note_code = cn.code
		WHERE	cnd.invoice_detail_id = @p_id
				AND cn.status = 'post'
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
		OUTER APPLY
		(
			SELECT		TOP 1
						aip.payment_date
			FROM		dbo.agreement_invoice_payment aip
			WHERE		aip.invoice_no			 = cn.invoice_no
						AND aip.transaction_type = 'CASHIER'
			ORDER BY	aip.cre_date DESC
		) aip
		WHERE	cnd.invoice_detail_id = @p_id
				and cn.status = 'POST'
				and year(aip.payment_date) = year(dbo.xfn_get_system_date()) ;

	end
	else
    begin
		select	@pph_amount = case iv.settlement_type
								  when 'pkp' then pph_amount
								  else 0
							  end
		from	dbo.invoice_detail ivd
				inner join dbo.invoice_pph iv on (iv.invoice_no = ivd.invoice_no)
				inner join dbo.invoice inv on (inv.invoice_no = iv.invoice_no)
				outer apply
		(
			select		top 1
						aip.payment_date
			from		dbo.agreement_invoice_payment aip
			where		aip.invoice_no			 = ivd.invoice_no
						and aip.transaction_type = 'CASHIER'
			order by	aip.cre_date desc
		) aip
		where	ivd.id					   = @p_id
				--and year(inv.new_invoice_date) = year(dbo.xfn_get_system_date()) ;
				and year(aip.payment_date) = year(dbo.xfn_get_system_date()) ;
		end
	return isnull(@pph_amount, 0) ;
end ;
