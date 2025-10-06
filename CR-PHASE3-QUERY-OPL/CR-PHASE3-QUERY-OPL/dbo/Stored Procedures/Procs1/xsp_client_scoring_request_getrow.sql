CREATE PROCEDURE [dbo].[xsp_client_scoring_request_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,client_code
			,scoring_status
			,scoring_date
			,scoring_remarks
			,scoring_result_date
			,scoring_result_value
			,scoring_result_remarks
			,scoring_object
	from	client_scoring_request
	where	code = @p_code ;
end ;

