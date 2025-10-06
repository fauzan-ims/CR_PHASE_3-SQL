CREATE PROCEDURE dbo.xsp_asset_get_depreciation_amount
(
	@p_company_code nvarchar(50)
	,@p_code		nvarchar(50)
	,@p_asset_no	nvarchar(50)
)
as
begin
	

	select	sum(depreciation_amount)
	from	dbo.asset_depreciation_schedule_commercial
	where	asset_code = @p_asset_no 
	and		transaction_code <> ''


end ;
