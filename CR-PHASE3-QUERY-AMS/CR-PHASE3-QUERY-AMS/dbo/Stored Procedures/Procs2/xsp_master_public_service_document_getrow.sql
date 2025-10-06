CREATE PROCEDURE dbo.xsp_master_public_service_document_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,public_service_code
			,document_code
			,document_name
			,file_name
			,paths
			,expired_date
	from	master_public_service_document
	where	id = @p_id ;
end ;
