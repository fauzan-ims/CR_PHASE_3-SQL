CREATE procedure dbo.xsp_asset_machine_upload_getrow
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
			,built_year
			,chassis_no
			,engine_no
			,colour
			,serial_no
			,purchase
			,remark
	from	asset_machine_upload
	where	FA_UPLOAD_ID = @p_fa_upload_id ;
end ;
