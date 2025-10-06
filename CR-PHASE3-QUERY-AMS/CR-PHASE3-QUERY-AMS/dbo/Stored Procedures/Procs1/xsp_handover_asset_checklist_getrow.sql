
create procedure xsp_handover_asset_checklist_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,handover_code
			,checklist_code
			,checklist_status
			,checklist_remark
	from	handover_asset_checklist
	where	id = @p_id ;
end ;
