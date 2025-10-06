
CREATE procedure [dbo].[xsp_master_rules_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,description
			,type
			,function_name
			,is_fn_override
			,fn_override_name
			,is_active
	from	master_rules
	where	code = @p_code ;
end ;
