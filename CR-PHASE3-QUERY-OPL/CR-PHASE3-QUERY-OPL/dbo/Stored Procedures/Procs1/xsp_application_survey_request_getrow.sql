CREATE PROCEDURE [dbo].[xsp_application_survey_request_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,code 'application_survey_code'
			,application_no
			,survey_status
			,survey_date
			,survey_fee_amount
			,survey_remarks
			,survey_result_date
			,survey_result_value
			,survey_result_remarks
			,survey_object
			,currency_code
			--(+) Saparudin : 02-08-2021
			,contact_person_area_phone_no
			,contact_person_phone_no
			,contact_person_name
			,address
	from	application_survey_request
	where	code = @p_code ;
end ;

