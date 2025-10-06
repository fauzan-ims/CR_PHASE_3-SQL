CREATE procedure dbo.xsp_get_premium_rate_extention_amount
(
	@p_coverage_code   nvarchar(50)
	,@p_region_code	   nvarchar(50)	 = ''
	,@p_type		   nvarchar(50)
	,@p_date		   datetime
	,@p_unit_amount	   decimal(18, 2)
	,@p_depre_amount   decimal(18, 2)
	,@p_calculate_type nvarchar(50)	 = 'DEPRE'
	,@p_total_budget_amount decimal(18, 2) output
)
as
begin
declare @total_budget_amount decimal(18, 2)
	begin
		if (@p_calculate_type = 'DEPRE')
		begin
			if (@p_type = 'TLO')
			begin
				select	@total_budget_amount = (@p_unit_amount * tlo * @p_depre_amount) / 100
				from	dbo.master_budget_insurance_rate_extention
				where	coverage_code				= @p_coverage_code
						and isnull(region_code, '') = @p_region_code
						and exp_date				>= @p_date 
						and is_active				= '1'
			end ;
			else
			begin
			select	*
				from	dbo.master_budget_insurance_rate_extention
				where	coverage_code				= @p_coverage_code
						--and isnull(region_code, '') = @p_region_code
						--and exp_date				>= @p_date 
						--and is_active				= '1'

				select	@total_budget_amount = (@p_unit_amount * compre * @p_depre_amount) / 100
				from	dbo.master_budget_insurance_rate_extention
				where	coverage_code				= @p_coverage_code
						and isnull(region_code, '') = @p_region_code
						and exp_date				>= @p_date 
						and is_active				= '1'
			end ;
		end ;
		else
		begin
			if (@p_type = 'TLO')
			begin
				select	@total_budget_amount = (@p_unit_amount * tlo)
				from	dbo.master_budget_insurance_rate_extention
				where	coverage_code				= @p_coverage_code
						and isnull(region_code, '') = @p_region_code
						and exp_date				>= @p_date 
						and is_active				= '1'
			end ;
			else
			begin
				select	@total_budget_amount = (@p_unit_amount * compre)
				from	dbo.master_budget_insurance_rate_extention
				where	coverage_code				= @p_coverage_code
						and isnull(region_code, '') = @p_region_code
						and exp_date				>= @p_date 
						and is_active				= '1'
			end ;
		end ;
	end ;

	set @p_total_budget_amount = @total_budget_amount ;
end ;

