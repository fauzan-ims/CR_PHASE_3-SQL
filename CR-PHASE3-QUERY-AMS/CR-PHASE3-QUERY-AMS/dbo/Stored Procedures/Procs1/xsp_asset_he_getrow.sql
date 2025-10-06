CREATE PROCEDURE dbo.xsp_asset_he_getrow
(
	@p_asset_code nvarchar(50)
)
as
begin
	select	asset_code
			,merk_code
			,merk_name
			,type_item_code
			,type_item_name
			,model_code
			,built_year
			,invoice_no
			,chassis_no
			,engine_no
			,colour
			,serial_no
			,remark
			,model_name
	from	asset_he
	where	asset_code = @p_asset_code ;
end ;
