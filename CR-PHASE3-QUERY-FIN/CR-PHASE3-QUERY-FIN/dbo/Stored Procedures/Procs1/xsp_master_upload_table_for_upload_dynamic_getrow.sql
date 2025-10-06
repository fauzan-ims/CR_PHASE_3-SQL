
CREATE PROCEDURE dbo.xsp_master_upload_table_for_upload_dynamic_getrow
(
	@p_code nvarchar(50)
)
as
begin

	select	sp_upload_name
	from	dbo.master_upload_table
	where	code = @p_code ;

end ;
