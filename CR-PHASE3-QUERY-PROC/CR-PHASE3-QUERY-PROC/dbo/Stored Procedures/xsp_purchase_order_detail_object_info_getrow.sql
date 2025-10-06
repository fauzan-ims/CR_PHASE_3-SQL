CREATE PROCEDURE dbo.xsp_purchase_order_detail_object_info_getrow
(
	@p_id bigint
)
as
begin
	select id
		  ,purchase_order_detail_id
		  ,good_receipt_note_detail_id
		  ,plat_no
		  ,chassis_no
		  ,engine_no
		  ,serial_no
		  ,invoice_no
		  ,domain
		  ,imei
		  ,bpkb_no
		  ,cover_note
		  ,exp_date
	from dbo.purchase_order_detail_object_info
	where id = @p_id
end ;
