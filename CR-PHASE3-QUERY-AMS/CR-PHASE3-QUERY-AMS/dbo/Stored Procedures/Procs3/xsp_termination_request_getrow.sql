
CREATE procedure [dbo].[xsp_termination_request_getrow]
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
			,request_reff_no
			,request_reff_name
			,termination_code
	from	termination_request
	where	code = @p_code ;
end ;

