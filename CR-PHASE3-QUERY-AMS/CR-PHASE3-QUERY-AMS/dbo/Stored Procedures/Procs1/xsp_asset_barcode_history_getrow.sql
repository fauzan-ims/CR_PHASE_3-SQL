CREATE procedure dbo.xsp_asset_barcode_history_getrow
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
	from	asset_barcode_history
	where	id = @p_id ;
end ;
