CREATE PROCEDURE [dbo].[xsp_deskcoll_invoice_getrow]
(
	@p_id bigint
)
as
begin
	select	REPLACE(a.invoice_no, '.', '/') 'invoice_no'
			,a.invoice_type
			,a.ovd_days
			,a.billing_date
			,a.billing_due_date
			,a.billing_amount
			,b.total_billing_amount
			,b.total_ppn_amount
			,b.total_pph_amount
			,a.remark
			,c.result_name
	from	dbo.deskcoll_invoice   a
			inner join dbo.invoice b on a.invoice_no = b.invoice_no
			left join dbo.master_deskcoll_result c on c.code = a.result_code
	where	a.id = @p_id ;
end ;
