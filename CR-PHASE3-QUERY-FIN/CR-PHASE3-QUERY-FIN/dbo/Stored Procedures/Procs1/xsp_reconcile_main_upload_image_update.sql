CREATE PROCEDURE dbo.xsp_reconcile_main_upload_image_update
(
	@p_code			nvarchar(50)
	,@p_file_name	nvarchar(250)
	,@p_file_paths	nvarchar(250)
)
as
begin
	update	dbo.reconcile_main
	set		file_name		= upper(@p_file_name)
			,paths			= upper(@p_file_paths)
	where	code			= @p_code;
end ;
