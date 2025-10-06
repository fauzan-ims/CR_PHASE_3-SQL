
create procedure xsp_deposit_release_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,deposit_release_code
			,deposit_code
			,deposit_amount
			,release_amount
	from	deposit_release_detail
	where	id = @p_id ;
end ;
