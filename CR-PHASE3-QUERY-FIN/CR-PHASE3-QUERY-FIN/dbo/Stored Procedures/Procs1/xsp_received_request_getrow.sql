CREATE procedure dbo.xsp_received_request_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,branch_code
			,branch_name
			,received_source
			,received_request_date
			,received_source_no
			,received_status
			,received_amount
			,received_remarks
			,received_transaction_code
	from	received_request
	where	code = @p_code ;
end ;
