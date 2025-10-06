
CREATE procedure [dbo].[xsp_claim_doc_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,claim_code
			--,general_document_code
			,document_date
			,document_remarks
			,file_name
			,paths
			,is_required
	from	claim_doc
	where	id = @p_id ;
end ;

