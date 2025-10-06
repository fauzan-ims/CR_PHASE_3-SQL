
CREATE PROCEDURE dbo.xsp_master_upload_tabel_detail_getrow
(
	@p_id			bigint
)
as
begin
	
	select	id
			,upload_tabel_code
			,upload_validation_code
			,param_generic_1
			,param_generic_2
	from	dbo.master_upload_tabel_detail
	where	id = @p_id;

end ;
