
CREATE procedure xsp_document_pending_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,document_pending_code
			,document_name
			,document_description
			,document_primary_no
			,document_primary_name
			,file_name
			,paths
			,expired_date
			,bpkb_name
			,bpkb_no
			,certificate_name
			,certificate_no
			,faktur_no
			,stnk_no
			,stnk_taxt_date
			,is_expired_date
	from	document_pending_detail
	where	id = @p_id ;
end ;
