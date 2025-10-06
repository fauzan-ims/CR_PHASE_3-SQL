--created by, Rian at 24/05/2023 

CREATE PROCEDURE dbo.xsp_application_survey_bank_detail_getrow
(
	@p_application_survey_bank_id	bigint
	,@p_id							bigint
)
AS
begin
	select	id
		   ,application_survey_bank_id
		   ,company
		   ,monthly_amount
		   ,average
	from	dbo.application_survey_bank_detail
	where	application_survey_bank_id = @p_application_survey_bank_id
			and id					   = @p_id ;
END
