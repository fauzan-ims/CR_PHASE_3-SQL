CREATE PROCEDURE dbo.xsp_warning_letter_delivery_getrow_for_invoice_detail
(
	@p_code nvarchar(50)
)
as
begin

	select	inv.invoice_external_no		'invoice_no'
			,inv.invoice_type
			,case when inv.invoice_status = 'post' then (case when cast(inv.invoice_due_date as date) < cast(dbo.xfn_get_system_date() as date) then datediff(day, inv.invoice_due_date, dbo.xfn_get_system_date()) else 0 end)
				when inv.invoice_status = 'paid' then (case when cast(inv.invoice_due_date as date) < cast(agp.payment_date as date) then datediff(day, inv.invoice_due_date, agp.payment_date) else 0 end)
				else 0 end									'ovd_days' 
			,format(inv.invoice_date, 'yyyy/MM/dd')			'billing_date'
			,format(inv.new_invoice_date, 'yyyy/MM/dd')		'billing_mode_date'
			,format(inv.invoice_due_date, 'yyyy/MM/dd')		'billing_due_date'
			,inv.total_amount								'total_billing_amount'
			,inv.total_ppn_amount							'total_ppn_amount'
			,inv.total_pph_amount							'total_pph_amount'
			,inv.invoice_name								'remark'
			,0												'partial_billing_amount'
			,0												'partial_ppn_amount'
			,0												'partial_pph_amount'
			,0												'overdue_installment_amount'
			,agp.payment_date								'last_partial_payment'
	from	dbo.invoice inv
			outer apply (	select	top 1 agp.payment_date 'payment_date'
							from	dbo.invoice_detail invd
									inner join dbo.agreement_invoice ainv on ainv.agreement_no = invd.agreement_no and ainv.asset_no = invd.asset_no and ainv.billing_no = invd.billing_no and ainv.invoice_no = invd.invoice_no 
									left join dbo.agreement_invoice_payment agp on agp.agreement_invoice_code = ainv.code
							where	invd.invoice_no = inv.invoice_no
							and		agp.payment_amount > 0
							order by agp.cre_date desc
						) agp
	where	inv.invoice_no = replace(@p_code, '/', '.')
	
end;
