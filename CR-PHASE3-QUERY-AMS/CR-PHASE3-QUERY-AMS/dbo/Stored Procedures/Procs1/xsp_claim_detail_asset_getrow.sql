
create procedure xsp_claim_detail_asset_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,claim_code
			,policy_asset_code
	from	claim_detail_asset
	where	id = @p_id ;
end ;
