--created by, Rian at 24/05/2023 

CREATE PROCEDURE dbo.xsp_application_survey_bank_getrow
(
	@p_application_survey_code	nvarchar(50)
)
as
begin
	select	id
		   ,application_survey_code
		   ,bank_code
		   ,bank_account_no
		   ,bank_account_name
	from	dbo.application_survey_bank
	where	application_survey_code = @p_application_survey_code
end
