CREATE procedure [dbo].[xsp_replacement_request_getrow]
(
	@p_id bigint
)
as
begin
	declare @received_asset int ;

	select	@received_asset = count(1)
	from	dbo.replacement_request_detail
	where	replacement_request_id = @p_id ;

	select	id
			,branch_code
			,branch_name
			,cover_note_no
			,cover_note_date
			,cover_note_exp_date
			,vendor_code
			,vendor_name
			,vendor_address
			,vendor_pic_name
			,vendor_pic_area_phone_no
			,vendor_pic_phone_no
			,document_name
			,count_asset
			,received_asset
			,extend_count
			,file_name
			,paths
			,status
			,remarks
			,replacement_code
			,@received_asset 'received_asset'
	from	replacement_request
	where	id = @p_id ;
end ;
