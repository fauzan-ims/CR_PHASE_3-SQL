CREATE PROCEDURE dbo.xsp_master_auction_document_getrow
(
	@p_id bigint
)
as
BEGIN

	select	id
			,auction_code
			,document_code
			,document_name
			,file_name
			,paths
			,is_required
			,is_latest
			,expired_date
	from	master_auction_document
	where	id = @p_id ;

end ;
