CREATE PROCEDURE dbo.xsp_asset_expense_amount_for_change_item
(
	@p_company_code nvarchar(50)
	,@p_code		nvarchar(50)
	,@p_asset_no	nvarchar(50)
)
as
begin
	declare	@last_depre	datetime = dbo.xfn_get_system_date()
	
	-- Arga 09-Nov-2022 ket : new formula based on request pak zaka (+)
	select	sum(depreciation_commercial_amount)
	from	dbo.asset_depreciation
	where	asset_code = @p_asset_no
	and		year(depreciation_date) = year(@last_depre)
	and		status = 'POST'
end ;
