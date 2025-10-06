CREATE PROCEDURE dbo.xsp_quotation_review_document_getrow
(
	@p_id			bigint
) as
begin

	select	 id
			,quotation_review_code
			,document_code
			,file_path
			,file_name
			,remark
	from	quotation_review_document
	where	id	= @p_id
end
