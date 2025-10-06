CREATE procedure dbo.xsp_asset_electronic_upload_getrow
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
			,serial_no
			,dimension
			,hdd
			,processor
			,ram_size
			,domain
			,imei
			,purchase
			,remark
	from	asset_electronic_upload
	where	FA_UPLOAD_ID = @p_fa_upload_id ;
end ;
