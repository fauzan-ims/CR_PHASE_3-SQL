
create procedure xsp_receipt_register_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,register_code
			,receipt_no
	from	receipt_register_detail
	where	id = @p_id ;
end ;
