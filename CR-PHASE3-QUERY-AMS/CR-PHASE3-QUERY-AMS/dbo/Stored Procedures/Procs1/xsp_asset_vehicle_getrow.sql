CREATE PROCEDURE [dbo].[xsp_asset_vehicle_getrow]
(
	@p_asset_code NVARCHAR(50)
)
AS
BEGIN

	SELECT	asset_code
			,av.merk_code
			,merk_name
			,av.type_item_code 'type_code'
			,av.type_item_name	'type_name'
			,av.model_code
			,av.model_name
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
			,remark
			,av.keur_no
			,av.keur_date
			,av.keur_expired_date
			,av.stnk_no
			,av.stnk_name
			,av.stnk_address
			--(+) Ari 2024-03-26 ket : add stck no, date, exp date & keur date
			,av.stck_no
			,av.stck_date
			,av.stck_exp_date
	FROM	asset_vehicle av
	where	asset_code = @p_asset_code ;

end ;
