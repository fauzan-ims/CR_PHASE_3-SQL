CREATE PROCEDURE dbo.xsp_good_receipt_note_detail_object_info_getrow
(
	@p_id bigint
)
as
begin
	select	grndoi.id
			,good_receipt_note_detail_id
			,plat_no
			,chassis_no
			,engine_no
			,grndoi.invoice_no
			,grndoi.serial_no
			,grndoi.domain
			,grndoi.imei
			,grn.status
	from	good_receipt_note_detail_object_info grndoi
	left join dbo.good_receipt_note_detail grnd on (grnd.id = grndoi.good_receipt_note_detail_id)
	left join dbo.good_receipt_note grn on (grn.code = grnd.good_receipt_note_code)
	where	grndoi.id = @p_id ;
end ;
