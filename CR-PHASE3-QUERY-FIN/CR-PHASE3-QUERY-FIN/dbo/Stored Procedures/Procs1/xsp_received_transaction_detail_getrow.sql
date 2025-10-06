CREATE PROCEDURE dbo.xsp_received_transaction_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,received_request_code
			,orig_curr_code
			,orig_amount
			,exch_rate
			,base_amount
			,rt.received_status
			,rr.received_remarks
			,rr.branch_name
	from	received_transaction_detail rtd
			inner join dbo.received_transaction rt on (rt.code = rtd.received_transaction_code)
			inner join dbo.received_request rr on (rr.code = rtd.received_request_code)
	where	id = @p_id ;
end ;
