
CREATE procedure [dbo].[xsp_endorsement_request_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,branch_code
			,branch_name
			,policy_code
			,endorsement_request_status
			,endorsement_request_date
			,endorsement_request_type
			,endorsement_code
			,request_reff_no
			,request_reff_name
	from	endorsement_request
	where	code = @p_code ;
end ;

