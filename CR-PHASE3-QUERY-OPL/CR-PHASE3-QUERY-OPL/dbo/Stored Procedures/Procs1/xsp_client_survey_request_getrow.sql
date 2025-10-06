CREATE procedure [dbo].[xsp_client_survey_request_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,client_code
			,survey_status
			,survey_date
			,survey_fee_amount
			,survey_remarks
			,survey_result_date
			,survey_result_remarks
			,survey_fee_amount
			,survey_object
			,currency_code
	from	client_survey_request
	where	code = @p_code ;
end ;

