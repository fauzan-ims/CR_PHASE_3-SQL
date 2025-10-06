
CREATE procedure [dbo].[xsp_application_recomendation_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,application_no
			,recomendation_result
			,recomendation_date
			,employee_code
			,employee_name
			,employee_position_name
			,level_status
			,remarks
	from	application_recomendation
	where	id = @p_id ;
end ;

