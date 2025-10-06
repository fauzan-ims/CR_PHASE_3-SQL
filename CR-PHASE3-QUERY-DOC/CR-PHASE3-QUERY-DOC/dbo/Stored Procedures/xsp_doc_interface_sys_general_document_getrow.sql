
create procedure xsp_doc_interface_sys_general_document_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,code
			,document_name
	from	doc_interface_sys_general_document
	where	id = @p_id ;
end ;
