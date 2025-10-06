CREATE FUNCTION dbo.xfn_get_get_liability_amount
(
	@p_coverage_code nvarchar(50)
	,@p_date		 datetime
	,@p_depre_amount decimal(18, 2)
)
returns decimal(18, 2)
as
begin
	declare @total_budget_amount decimal(18, 2) = 0 ;

	begin
		select	top 1 @total_budget_amount = (coverage_amount * (rate_of_limit / 100))
		from	dbo.master_budget_insurance_rate_liability
		where	code = @p_coverage_code
				and exp_date  >= @p_date 
				and is_active = '1'
	end ;

	return @total_budget_amount ;
end ;

