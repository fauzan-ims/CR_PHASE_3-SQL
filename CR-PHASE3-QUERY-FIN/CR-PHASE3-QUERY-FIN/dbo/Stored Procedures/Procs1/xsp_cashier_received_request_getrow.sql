
create procedure xsp_cashier_received_request_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,branch_code
			,branch_name
			,request_status
			,request_currency_code
			,request_date
			,request_amount
			,request_remarks
			,agreement_no
			,doc_ref_code
			,doc_ref_name
	from	cashier_received_request
	where	code = @p_code ;
end ;
