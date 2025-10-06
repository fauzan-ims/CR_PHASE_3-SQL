
CREATE procedure dbo.xsp_asset_get_difference_accum_amount_non_reval_adjustment
(
	@p_company_code nvarchar(50)
	,@p_code		nvarchar(50)
	,@p_asset_no	nvarchar(50)
)
as
begin
	
	declare	@prev_accum_depre	decimal(18,2)
			,@new_accum_depre	decimal(18,2)
			,@depre_period		nvarchar(6)
			,@prev_nbv			decimal(18,2)

	select	@prev_accum_depre	= adj.old_total_depre_comm
			,@depre_period		= depre_period_comm
	from	dbo.adjustment adj
			inner join dbo.asset ast on adj.asset_code = ast.code
	where	adj.company_code = @p_company_code
	and		adj.code = @p_code

	select	@new_accum_depre = sum(depreciation_amount)
	from	dbo.asset_depreciation_schedule_commercial
	where	asset_code = @p_asset_no
	and		convert(char(6),depreciation_date,112) <= @depre_period
	
	-- Arga 09-Nov-2022 ket : switch formula based on req pak zaka n bu rai (-/+)
	--select isnull(@prev_accum_depre,0) - isnull(@new_accum_depre,0)
	select isnull(@new_accum_depre,0) - isnull(@prev_accum_depre,0)
	
end ;
