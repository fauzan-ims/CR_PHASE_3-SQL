create procedure dbo.xsp_replacement_request_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,replacement_request_id
			,asset_no
			,status
			,replacement_code
			,document_main_code
	from	replacement_request_detail
	where	id = @p_id ;
end ;
