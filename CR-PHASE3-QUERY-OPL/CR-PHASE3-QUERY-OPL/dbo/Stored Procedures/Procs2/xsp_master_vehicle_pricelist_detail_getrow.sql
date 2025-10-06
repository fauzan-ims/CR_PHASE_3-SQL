---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[xsp_master_vehicle_pricelist_detail_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,vehicle_pricelist_code
			,branch_code
			,branch_name
			,currency_code
			,effective_date
			,asset_value
			,dp_pct
			,dp_amount
			,financing_amount
			,case
				 when cast(effective_date as date) < dbo.xfn_get_system_date() then '0'
				 else '1'
			 end 'editable'
	from	master_vehicle_pricelist_detail
	where	id = @p_id ;
end ;


