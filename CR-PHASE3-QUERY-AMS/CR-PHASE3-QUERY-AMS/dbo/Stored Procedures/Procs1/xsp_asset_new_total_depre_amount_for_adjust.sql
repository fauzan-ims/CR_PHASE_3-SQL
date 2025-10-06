
CREATE procedure dbo.xsp_asset_new_total_depre_amount_for_adjust
(
	@p_company_code nvarchar(50)
	,@p_code		nvarchar(50)
	,@p_asset_no	nvarchar(50)
)
as
begin
	declare	@depre_period nvarchar(6)

	select	@depre_period = convert(char(6),max(depreciation_date),112)
	from	dbo.asset_depreciation
	where	asset_code = @p_asset_no
	and		status = 'POST'
	
	select	sum(depreciation_amount)
	from	dbo.asset_depreciation_schedule_commercial
	where	asset_code = @p_asset_no
	and		convert(char(6),depreciation_date,112) <= @depre_period
	--and		transaction_code <> ''
end ;
