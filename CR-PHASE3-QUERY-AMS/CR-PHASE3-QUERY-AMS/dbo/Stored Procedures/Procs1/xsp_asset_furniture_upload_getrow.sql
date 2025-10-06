CREATE procedure dbo.xsp_asset_furniture_upload_getrow
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
			,model_name
			,purchase
			,remark
	from	asset_furniture_upload
	where	FA_UPLOAD_ID = @p_fa_upload_id ;
end ;
