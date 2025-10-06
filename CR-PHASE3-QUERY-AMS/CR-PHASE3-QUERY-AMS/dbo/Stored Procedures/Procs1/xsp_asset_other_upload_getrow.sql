CREATE procedure dbo.xsp_asset_other_upload_getrow
(
	@p_fa_upload_id bigint
)
as
begin
	select	fa_upload_id
			,file_name
			,upload_no
			,asset_code
			,remark
	from	asset_other_upload
	where	FA_UPLOAD_ID = @p_fa_upload_id ;
end ;
