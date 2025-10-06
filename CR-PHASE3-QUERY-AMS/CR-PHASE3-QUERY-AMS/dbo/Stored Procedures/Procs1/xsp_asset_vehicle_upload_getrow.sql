CREATE procedure dbo.xsp_asset_vehicle_upload_getrow
(
	@p_fa_upload_id bigint
)
as
begin
	select	fa_upload_id
			,file_name
			,upload_no
			,asset_code
			,merk_code
			,merk_name
			,type_code
			,type_name
			,model_code
			,plat_no
			,chassis_no
			,engine_no
			,bpkb_no
			,colour
			,cylinder
			,stnk_no
			,stnk_expired_date
			,stnk_tax_date
			,stnk_renewal
			,built_year
			,last_miles
			,last_maintenance_date
			,purchase
			,remark
	from	asset_vehicle_upload
	where	FA_UPLOAD_ID = @p_fa_upload_id ;
end ;
