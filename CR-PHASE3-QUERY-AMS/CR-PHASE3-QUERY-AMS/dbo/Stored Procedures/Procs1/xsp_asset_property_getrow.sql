CREATE PROCEDURE dbo.xsp_asset_property_getrow
(
	@p_asset_code nvarchar(50)
)
as
begin
	select	asset_code
			,imb_no
			,certificate_no
			,land_size
			,building_size
			,status_of_ruko 
			,sgc.description 'general_subcode_desc'
			,number_of_ruko_and_floor
			,total_square
			,vat
			,no_lease_agreement
			,date_of_lease_agreement
			,land_and_building_tax
			,security_deposit
			,owner
			,remark
	from	asset_property ap
			left join dbo.sys_general_subcode sgc on (ap.status_of_ruko = sgc.code)
	where	asset_code = @p_asset_code ;
end ;
