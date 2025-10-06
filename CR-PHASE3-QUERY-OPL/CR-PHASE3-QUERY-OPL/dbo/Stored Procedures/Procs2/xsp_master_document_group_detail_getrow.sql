
CREATE procedure [dbo].[xsp_master_document_group_detail_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,document_group_code
			,general_doc_code
			,is_required
	from	master_document_group_detail
	where	id = @p_id ;
end ;

