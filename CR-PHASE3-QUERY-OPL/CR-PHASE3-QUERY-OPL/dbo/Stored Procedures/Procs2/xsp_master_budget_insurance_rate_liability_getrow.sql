--created by, Rian at /06/2023 

CREATE PROCEDURE dbo.xsp_master_budget_insurance_rate_liability_getrow
(
	@p_code		nvarchar(50)
)
as
begin
	select	code
			,type
			,coverage_code
			,coverage_description
			,coverage_amount
			,rate_of_limit
			,exp_date
			,is_active
	from	dbo.master_budget_insurance_rate_liability
	where	code = @p_code ;
end
