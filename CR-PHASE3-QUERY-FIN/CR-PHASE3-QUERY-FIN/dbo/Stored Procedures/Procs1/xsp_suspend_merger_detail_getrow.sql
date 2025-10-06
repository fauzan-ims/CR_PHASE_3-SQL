
create procedure xsp_suspend_merger_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,suspend_merger_code
			,suspend_code
			,suspend_amount
	from	suspend_merger_detail
	where	id = @p_id ;
end ;
