CREATE PROCEDURE dbo.xsp_master_upload_table_for_cancel_upload_dynamic_getrow
(
	@p_code nvarchar(50)
)
as
begin

	select	sp_cancel_name
	from	dbo.master_upload_table
	where	code = @p_code ;

end ;
