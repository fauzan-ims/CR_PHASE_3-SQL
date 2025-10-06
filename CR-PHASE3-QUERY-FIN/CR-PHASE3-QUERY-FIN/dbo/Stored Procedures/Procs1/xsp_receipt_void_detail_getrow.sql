
create procedure xsp_receipt_void_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,receipt_void_code
			,receipt_code
	from	receipt_void_detail
	where	id = @p_id ;
end ;
