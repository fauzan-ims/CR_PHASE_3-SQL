--created by, Rian at 15/05/2023 

CREATE PROCEDURE dbo.xsp_master_budget_maintenance_group_for_get_date
(
	@p_budget_maintenance_code nvarchar(50)
)
as
begin
	select	group_code
	from	dbo.master_budget_maintenance_group
	where	budget_maintenance_code = @p_budget_maintenance_code ;
end ;
