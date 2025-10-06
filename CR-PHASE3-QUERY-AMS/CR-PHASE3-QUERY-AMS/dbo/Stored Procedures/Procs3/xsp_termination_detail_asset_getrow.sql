
create procedure xsp_termination_detail_asset_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,termination_code
			,policy_asset_code
			,estimate_refund_amount
			,refund_amount
	from	termination_detail_asset
	where	id = @p_id ;
end ;
