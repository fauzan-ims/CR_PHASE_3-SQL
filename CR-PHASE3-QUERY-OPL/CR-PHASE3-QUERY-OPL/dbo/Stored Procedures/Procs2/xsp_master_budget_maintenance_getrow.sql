--created by, Rian at 12/05/2023

CREATE PROCEDURE dbo.xsp_master_budget_maintenance_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
		   ,unit_code
		   ,unit_description
		   ,year
		   ,inflation
		   ,location
		   ,eff_date
		   ,exp_date
		   ,is_active
		   ,'60' 'default_period' -- (+) Ari 2024-01-29 ket : set default periode for simulation
	from	dbo.master_budget_maintenance
	where	code = @p_code ;
end ;
