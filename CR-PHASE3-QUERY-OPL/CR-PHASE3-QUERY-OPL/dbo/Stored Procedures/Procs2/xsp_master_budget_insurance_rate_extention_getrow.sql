--created by, Rian at 05/06/2023 

CREATE PROCEDURE dbo.xsp_master_budget_insurance_rate_extention_getrow
(
	@p_code		nvarchar(50)
)
as
begin
	select	code
			,coverage_code
			,coverage_description
			,exp_date
			,tlo
			,compre
			,region_code
			,region_description
			,is_active
	from	dbo.master_budget_insurance_rate_extention
	where	code = @p_code ;
end
