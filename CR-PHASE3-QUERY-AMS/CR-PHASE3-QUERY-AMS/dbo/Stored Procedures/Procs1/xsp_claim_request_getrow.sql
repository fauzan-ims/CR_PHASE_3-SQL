
CREATE procedure [dbo].[xsp_claim_request_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,branch_code
			,branch_name
			,policy_code
			,request_status
			,request_date
			,claim_code
	from	claim_request
	where	code = @p_code ;
end ;

