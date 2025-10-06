--created by, Rian at 24/05/2023 

CREATE PROCEDURE xsp_application_survey_plan_getrow
(
	@p_application_survey_code	nvarchar(50)
	,@p_id						bigint
)
AS
BEGIN
	select	id
		   ,application_survey_code
		   ,description
		   ,ni_amount
		   ,total_ni_amount
	from	dbo.application_survey_plan
	where	application_survey_code = @p_application_survey_code
			and ID					= @p_id ;
END
