CREATE PROCEDURE dbo.xsp_received_voucher_detail_getrow
(
	@p_id int
)
as
begin
	select	rvd.id
			,rvd.received_voucher_code
			,rvd.branch_code
			,rvd.branch_name
			,rvd.gl_link_code
			,rvd.orig_amount
			,rvd.orig_currency_code
			,rvd.exch_rate
			,rvd.base_amount
			,rvd.division_code
			,rvd.division_name
			,rvd.department_code
			,rvd.department_name
			,rvd.remarks
			,jgl.gl_link_name
			,rv.received_status
			,rv.received_value_date
			,jgl.is_provit_or_cost
			,rvd.doc_reff_no
	from	received_voucher_detail rvd
			inner join dbo.journal_gl_link jgl on (jgl.code = rvd.gl_link_code)
			inner join dbo.received_voucher rv on (rv.code = rvd.received_voucher_code)
	where	rvd.id = @p_id ;
end ;
