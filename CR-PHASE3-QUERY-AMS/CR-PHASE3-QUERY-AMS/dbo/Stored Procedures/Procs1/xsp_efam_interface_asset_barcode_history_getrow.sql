CREATE procedure dbo.xsp_efam_interface_asset_barcode_history_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,asset_code
			,previous_barcode
			,new_barcode
			,remark
	from	efam_interface_asset_barcode_history
	where	ID = @p_id ;
end ;
