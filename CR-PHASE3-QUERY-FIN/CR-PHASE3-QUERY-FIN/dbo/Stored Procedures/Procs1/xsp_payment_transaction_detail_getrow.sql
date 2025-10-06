CREATE PROCEDURE dbo.xsp_payment_transaction_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,ptd.payment_transaction_code
			,payment_request_code
			,orig_curr_code
			,orig_amount
			,exch_rate
			,base_amount
			,pr.tax_type 'tax_file_type'
			,tax_file_no
			,tax_amount
			,pr.payment_branch_name
			,pr.payment_remarks
			,pt.payment_status
	from	payment_transaction_detail ptd
			inner join dbo.payment_request pr on (pr.code = ptd.payment_request_code)
			inner join dbo.payment_transaction pt on (pt.code = ptd.payment_transaction_code)
	where	id = @p_id ;
end ;
