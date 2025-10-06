CREATE procedure [dbo].[xsp_application_rules_result_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,application_no
			,rules_code
			,rules_result
			--,is_deviation
	from	application_rules_result
	where	id = @p_id ;
end ;

