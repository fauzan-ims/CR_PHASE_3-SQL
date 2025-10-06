--created by, Rian at 05/06/2023 

CREATE procedure xsp_master_budget_insurance_rate_detail_getrow
(
	@p_budget_insurance_rate_code	nvarchar(50)
	,@p_id							bigint
)
as
begin
	select	id
			,budget_insurance_rate_code
			,sum_insured_from
			,sum_insured_to
			,region_code
			,region_description
			,rate_1
			,rate_2
			,rate_3
			,rate_4
	from	dbo.master_budget_insurance_rate_detail
	where	budget_insurance_rate_code = @p_budget_insurance_rate_code
			and id					   = @p_id ;
end
