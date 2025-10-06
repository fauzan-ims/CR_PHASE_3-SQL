--created by, Rian at 12/05/2023 

CREATE procedure xsp_master_budget_maintenance_group_service_getrow
(
	@p_id						bigint
	,@p_budget_maintenance_code nvarchar(15)
)
as
begin
	select	id
		   ,budget_maintenance_code
		   ,budget_maintenance_group_code
		   ,group_code
		   ,service_code
		   ,service_description
		   ,unit_qty
		   ,unit_cost
		   ,labor_cost
		   ,replacement_cycle
		   ,replacement_type
		   ,total_cost
	from	dbo.master_budget_maintenance_group_service
	where	budget_maintenance_code = @p_budget_maintenance_code
			and id					= @p_id ;
end ;
