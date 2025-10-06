create PROCEDURE dbo.xsp_register_document_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,register_code
			,document_code
			,file_name
			,paths
	from	register_document
	where	id = @p_id ;
end ;
