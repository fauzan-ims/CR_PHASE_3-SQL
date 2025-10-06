--created by, rian at 05/06/2023 

CREATE procedure xsp_master_budget_insurance_rate_getrow
(
	@p_code		nvarchar(50)
)
as
begin
	select	code
			,exp_date
			,vehicle_type_code
			,vehicle_type_description
			,coverage_code
			,coverage_description
			,is_active
	from	dbo.master_budget_insurance_rate
	where	code = @p_code ;
end
