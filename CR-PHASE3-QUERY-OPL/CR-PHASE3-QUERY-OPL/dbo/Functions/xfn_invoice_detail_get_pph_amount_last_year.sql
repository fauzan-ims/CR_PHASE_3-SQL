

CREATE FUNCTION dbo.xfn_invoice_detail_get_pph_amount_last_year
(
	@p_id bigint
)
returns decimal(18, 2)
as
begin
	declare @pph_amount decimal(18, 2) ;

	-- hari 2023/09/07 - perubahan cara ambil pph jika pkp maka ada isinya
	if exists-- raffy 2025/06/11 jika ada credit note, maka pph diambil dari credit note 
	(
		select	1
		from	dbo.credit_note cn 
		inner join dbo.credit_note_detail cnd on cnd.credit_note_code = cn.code
		where	cnd.invoice_detail_id = @p_id
				and cn.status = 'post'
	)
	begin
		select	@pph_amount = case iv.settlement_type
		                         when 'pkp' then
		                             cnd.new_pph_amount
		                         else
		                             0
		                     END
		from	dbo.credit_note cn 
		inner join dbo.credit_note_detail cnd on cnd.credit_note_code = cn.code
		inner join dbo.invoice_pph iv on iv.invoice_no = cn.invoice_no
		outer apply
		(
			select		top 1
						aip.payment_date
			from		dbo.agreement_invoice_payment aip
			where		aip.invoice_no			 = cn.invoice_no
						and aip.transaction_type = 'CASHIER'
			order by	aip.cre_date desc
		) aip
		where	cnd.invoice_detail_id = @p_id
				and cn.status = 'POST'
				and year(aip.payment_date) < year(dbo.xfn_get_system_date()) ;

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
				and year(aip.payment_date) < year(dbo.xfn_get_system_date()) ;
		end
			

	return isnull(@pph_amount, 0) ;
end ;
