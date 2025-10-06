
create procedure dbo.xsp_master_upload_tabel_validation_getrow
(
	@p_id			bigint
)
as
begin
	
	select	id
			,upload_tabel_column_code
			,upload_validation_code
			,param_generic_1
			,param_generic_2
	from	dbo.master_upload_tabel_validation
	where	id = @p_id;

end ;
