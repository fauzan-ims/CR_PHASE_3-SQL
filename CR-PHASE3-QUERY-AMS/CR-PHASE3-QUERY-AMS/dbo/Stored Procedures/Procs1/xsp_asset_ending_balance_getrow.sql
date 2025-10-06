
CREATE procedure xsp_asset_ending_balance_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,asset_code
			,period
			,balance_amount
			,balance_amount_accum
	from	asset_ending_balance
	where	id = @p_id ;
end ;
