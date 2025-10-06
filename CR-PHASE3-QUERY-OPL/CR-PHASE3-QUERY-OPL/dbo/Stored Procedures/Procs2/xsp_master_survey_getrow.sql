
create procedure [dbo].[xsp_master_survey_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,survey_name
			,reff_survey_category_code
			,reff_survey_category_name
			,is_active
	from	master_survey
	where	code = @p_code ;
end ;
