
CREATE procedure xsp_asset_get_difference_accum_depre_for_change_category
(
	@p_company_code nvarchar(50)
	,@p_code		nvarchar(50)
	,@p_asset_no	nvarchar(50)
)
as
begin
	declare	@last_depre	datetime
			,@prev_depre	decimal(18,2)

	select	@last_depre = max(depreciation_date)
			--,@prev_depre = sum(depreciation_commercial_amount)
	from	dbo.asset_depreciation
	where	asset_code = @p_asset_no
	and		year(depreciation_date) = year(dbo.xfn_get_system_date())
	and		status = 'POST'
		
	select	@prev_depre = sum(depreciation_amount)
	from	dbo.asset_depreciation_schedule_commercial
	where	asset_code = @p_asset_no
	and		depreciation_date <= @last_depre
	and		transaction_code <> ''

	-- new schedule
	select	sum(depreciation_amount) - @prev_depre
	from	dbo.asset_depreciation_schedule_commercial
	where	asset_code = @p_asset_no
	and		depreciation_date <= @last_depre
	and		transaction_code = ''
end ;
