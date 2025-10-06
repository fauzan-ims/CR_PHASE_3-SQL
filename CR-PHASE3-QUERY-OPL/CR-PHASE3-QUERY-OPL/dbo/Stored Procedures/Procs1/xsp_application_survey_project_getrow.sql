--ccreated by, Rian at 24/05/2023 

CREATE PROCEDURE xsp_application_survey_project_getrow
(
	@p_application_survey_code	nvarchar(50)
	,@p_id						bigint
)
AS
begin
	select	id
		   ,application_survey_code
		   ,project_name
		   ,project_owner
		   ,main_kontraktor
		   ,sub_kontraktor
		   ,sub_sub_kontraktor
		   ,main_kompetitor
		   ,sub_kompetitor
		   ,sub_sub_kompetitor
	from	dbo.application_survey_project
	where	application_survey_code = @p_application_survey_code
			and id					= @p_id ;
END
