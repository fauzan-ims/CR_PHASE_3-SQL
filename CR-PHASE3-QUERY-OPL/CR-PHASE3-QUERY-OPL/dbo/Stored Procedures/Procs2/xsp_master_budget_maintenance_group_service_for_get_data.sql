--created by, Rian at 15/05/2023 

CREATE procedure xsp_master_budget_maintenance_group_service_for_get_data
(
	@p_budget_maintenance_code nvarchar(50)
)
as
begin
	select	service_code
	from	dbo.master_budget_maintenance_group_service
	where	budget_maintenance_code = @p_budget_maintenance_code ;
end ;
