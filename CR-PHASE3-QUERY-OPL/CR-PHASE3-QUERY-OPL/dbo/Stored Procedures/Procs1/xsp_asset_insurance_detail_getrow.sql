--created by, Rian at 06/06/2023 

CREATE PROCEDURE [dbo].[xsp_asset_insurance_detail_getrow]
(
	@p_asset_no nvarchar(50)
)
as
begin
	select	id
			,asset_no
			,main_coverage_code
			,main_coverage_description
			,region_code
			,region_description
			,main_coverage_premium_amount
			,is_use_tpl
			,tpl_coverage_code
			,tpl_coverage_description
			,tpl_premium_amount
			,is_use_pll
			,pll_coverage_code
			,pll_coverage_description
			,pll_premium_amount
			,is_use_pa_passenger
			,pa_passenger_amount
			,pa_passenger_seat
			,pa_passenger_premium_amount
			,is_use_pa_driver
			,pa_driver_amount
			,pa_driver_premium_amount
			,is_use_srcc
			,srcc_premium_amount
			,is_use_ts
			,ts_premium_amount
			,is_use_flood
			,flood_premium_amount
			,is_use_earthquake
			,earthquake_premium_amount
			,is_commercial_use
			,commercial_premium_amount
			,is_authorize_workshop
			,authorize_workshop_premium_amount
			,is_tbod
			,tbod_premium_amount
			,total_premium_amount
	from	dbo.asset_insurance_detail
	where	asset_no = @p_asset_no ;
end ;
