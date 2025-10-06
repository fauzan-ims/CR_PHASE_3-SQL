--created by, Rian at 12/05/2023	

CREATE procedure xsp_master_budget_maintenance_group_getrow
(
	@p_code						nvarchar(50)
	,@p_budget_maintenance_code nvarchar(50)
)
as
begin
	select	code
			,budget_maintenance_code
			,group_code
			,group_description
			,probability_pct
	from	dbo.master_budget_maintenance_group
	where	budget_maintenance_code = @p_budget_maintenance_code
			and code				= @p_code ;
end ;
