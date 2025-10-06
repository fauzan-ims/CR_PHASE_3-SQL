
create procedure xsp_suspend_revenue_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,suspend_revenue_code
			,suspend_code
			,suspend_amount
			,revenue_amount
	from	suspend_revenue_detail
	where	id = @p_id ;
end ;
