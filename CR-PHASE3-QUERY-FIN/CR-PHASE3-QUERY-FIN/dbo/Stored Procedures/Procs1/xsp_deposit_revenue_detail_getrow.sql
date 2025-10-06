
create procedure xsp_deposit_revenue_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,deposit_revenue_code
			,deposit_code
			,deposit_amount
			,revenue_amount
	from	deposit_revenue_detail
	where	id = @p_id ;
end ;
