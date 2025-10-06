create procedure xsp_document_storage_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,document_storage_code
			,document_code
	from	document_storage_detail
	where	id = @p_id ;
end ;
