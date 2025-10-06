CREATE PROCEDURE dbo.xsp_good_receipt_note_detail_checklist_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,good_receipt_note_detail_id
			,good_receipt_note_detail_object_info_id
			,checklist_code
			,checklist_status
			,checklist_remark
	from	good_receipt_note_detail_checklist
	where	id = @p_id ;
end ;
