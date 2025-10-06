CREATE PROCEDURE [dbo].[xsp_master_upload_table_validation_getrow]
(
	@p_id			bigint
)
as
begin
	
	select	id
			,upload_table_column_code
			,upload_validation_code
	from	dbo.master_upload_table_validation
	where	id = @p_id;

end ;
