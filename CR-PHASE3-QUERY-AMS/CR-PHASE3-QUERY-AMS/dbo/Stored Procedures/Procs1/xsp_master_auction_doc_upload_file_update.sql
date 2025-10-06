CREATE PROCEDURE dbo.xsp_master_auction_doc_upload_file_update
(
	@p_id			bigint
	,@p_file_name	nvarchar(250)
	,@p_file_paths	nvarchar(250)
)
as
begin
	update	dbo.master_auction_document
	set		file_name		= upper(@p_file_name)
			,paths			= upper(@p_file_paths)
			,expired_date	= null
	where	id				= @p_id;
end ;
