
create procedure xsp_good_receipt_note_detail_doc_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,good_receipt_note_detail_id
			,document_name
			,file_name
			,file_path
	from	good_receipt_note_detail_doc
	where	id = @p_id ;
end ;
