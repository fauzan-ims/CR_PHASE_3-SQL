
CREATE procedure [dbo].[xsp_master_survey_dimension_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,survey_code
			,reff_dimension_code
			,reff_dimension_name
			,dimension_code
	from	master_survey_dimension
	where	id = @p_id ;
end ;
