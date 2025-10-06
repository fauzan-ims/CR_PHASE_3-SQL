CREATE PROCEDURE dbo.xsp_document_movement_detail_getrow
(
	@p_id int
)
as
begin
	select	id
			,movement_code
			,document_code
			,document_request_code
			,document_pending_code
			,is_reject
			,remarks
	from	document_movement_detail
	where	id = @p_id ;
end ;
