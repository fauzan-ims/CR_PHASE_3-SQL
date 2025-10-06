CREATE PROCEDURE [dbo].[xsp_application_asset_scoring_request_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,asset_no
			,scoring_status
			,scoring_date
			,scoring_remarks
			,scoring_result_date
			,scoring_result_value
			,scoring_result_grade
			,scoring_result_remarks
			,scoring_object
	from	application_asset_scoring_request
	where	code = @p_code ;
end ;

