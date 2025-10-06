CREATE PROCEDURE dbo.xsp_warning_letter_delivery_getrow_for_invoice_detail_backup_25092025
(
	@p_code nvarchar(50)
)
as
begin
    select		d.invoice_external_no 'invoice_no',
				d.invoice_type 'invoice_type',
				convert(varchar(30), max(e.billing_date), 103) 'billing_date',
				convert(varchar(30), max(e.due_date), 103) 'billing_due_date',
				sum(d.total_billing_amount) 'os_invoice_amount',
				sum(d.total_ppn_amount) 'total_ppn_amount',
				sum(d.total_pph_amount) 'total_pph_amount',
				convert(varchar(30), max(f.obligation_day), 103) 'ovd_days',
				max(d.invoice_status) 'invoice_status',
				convert(varchar(30), max(a.payment_promise_date), 103) 'promise_date',
				max(d.invoice_due_date) 'invoice_due_date'
    from		dbo.agreement_main a
				inner join dbo.agreement_asset b on b.agreement_no = a.agreement_no
				inner join dbo.invoice_detail c on c.asset_no = b.asset_no
				inner join dbo.invoice d on d.invoice_no = c.invoice_no
				inner join dbo.agreement_asset_amortization e on e.asset_no = c.asset_no
				inner join dbo.agreement_obligation f on f.asset_no = c.asset_no
    where		d.invoice_no = replace(@p_code, '/', '.')
    group by	d.invoice_external_no,
				d.invoice_type;
end;
