--created by, Rian at 24/05/2023 

create PROCEDURE xsp_application_survey_document_getrow
(
	@p_aplication_survey_code	nvarchar(50)
	,@p_id						bigint
)
AS
begin
	select	id
		   ,application_survey_code
		   ,location
		   ,remark
		   ,file_name
		   ,paths
	from	dbo.application_survey_document
	where	application_survey_code = @p_aplication_survey_code
			and id					= @p_id ;
END
