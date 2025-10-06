CREATE PROCEDURE dbo.xsp_payment_voucher_detail_getrow
(
	@p_id int
)
as
begin
	select	pvd.id
			,pvd.payment_voucher_code
			,pvd.branch_code
			,pvd.branch_name
			,pvd.gl_link_code
			,jgl.gl_link_name
			,pvd.orig_amount
			,pvd.orig_currency_code
			,pvd.exch_rate
			,pvd.base_amount
			,pvd.division_code
			,pvd.division_name
			,pvd.department_code
			,pvd.department_name
			,pvd.remarks
			,pv.payment_status
			,pv.payment_transaction_date
			,pvd.doc_reff_no -- (+) Ari 2023-12-02
			,jgl.is_provit_or_cost
	from	payment_voucher_detail pvd 
			inner join dbo.journal_gl_link jgl on (jgl.code = pvd.gl_link_code)
			inner join dbo.payment_voucher pv on (pv.code = pvd.payment_voucher_code)
	where	pvd.id = @p_id ;
end ;
