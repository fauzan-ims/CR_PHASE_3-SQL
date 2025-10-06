CREATE PROCEDURE [dbo].[xsp_application_doc_upload_file_update]
(
	@p_id			bigint
	,@p_file_name	nvarchar(250)
	,@p_file_paths	nvarchar(250)
)
as
begin
	update	application_doc
	set		filename		= upper(@p_file_name)
			,paths			= upper(@p_file_paths)
			--,expired_date   = null
			--,promise_date	= null
	where	id				= @p_id;
end ;

