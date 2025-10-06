create PROCEDURE dbo.xsp_order_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,order_code
			,register_code
	from	order_detail
	where	id = @p_id ;
end ;
