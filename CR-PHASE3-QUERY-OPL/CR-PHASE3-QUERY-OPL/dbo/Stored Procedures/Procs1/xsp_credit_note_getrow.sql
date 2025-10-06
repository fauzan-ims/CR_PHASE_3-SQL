CREATE PROCEDURE dbo.xsp_credit_note_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,inv.invoice_external_no
			,cn.branch_code
			,cn.branch_name
			,date
			--,status
			,case cn.status	
				when 'DONE' then 'POST'
				ELSE cn.status
			end 'status'
			,remark
			,cn.invoice_no
			,cn.currency_code
			,billing_amount
			,discount_amount
			,ppn_pct
			,ppn_amount
			,pph_pct
			,pph_amount
			,cn.total_amount
			,credit_amount
			,new_faktur_no
			,new_ppn_amount
			,new_pph_amount
			,new_total_amount
			,inv.invoice_name
	from	credit_note cn
	inner join dbo.invoice inv with(nolock) on (inv.invoice_no = cn.invoice_no)
	where	code = @p_code ;
end ;
