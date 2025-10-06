
CREATE procedure dbo.xsp_asset_get_previous_depre_amount_for_current_year
(
	@p_company_code nvarchar(50)
	,@p_code		nvarchar(50)
	,@p_asset_no	nvarchar(50)
)
as
begin
	declare	@last_depre	datetime = dbo.xfn_get_system_date()

	select	sum(depreciation_commercial_amount)
	from	dbo.asset_depreciation
	where	asset_code = @p_asset_no
	and		year(depreciation_date) = year(@last_depre)
	and		status = 'POST'
end ;
