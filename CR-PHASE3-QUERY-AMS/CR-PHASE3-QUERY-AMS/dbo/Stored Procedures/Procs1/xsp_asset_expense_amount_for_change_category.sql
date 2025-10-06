CREATE PROCEDURE dbo.xsp_asset_expense_amount_for_change_category
(
	@p_company_code nvarchar(50)
	,@p_code		nvarchar(50)
	,@p_asset_no	nvarchar(50)
)
as
begin
	declare	@last_depre	datetime
	
	select	@last_depre = max(depreciation_date)
	from	dbo.asset_depreciation
	where	asset_code = @p_asset_no
	and		year(depreciation_date) = year(dbo.xfn_get_system_date())
	and		status = 'POST'

	select	sum(depreciation_amount)
	from	dbo.asset_depreciation_schedule_commercial
	where	asset_code = @p_asset_no
	and		year(depreciation_date) = year(@last_depre)
	and		month(depreciation_date) <= month(@last_depre)

end ;
