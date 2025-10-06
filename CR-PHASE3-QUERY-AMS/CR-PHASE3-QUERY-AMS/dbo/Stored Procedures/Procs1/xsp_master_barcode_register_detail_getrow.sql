create PROCEDURE dbo.xsp_master_barcode_register_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,barcode_register_code
			,barcode_no
			,asset_code
			,status
	from	master_barcode_register_detail
	where	id = @p_id ;
end ;
