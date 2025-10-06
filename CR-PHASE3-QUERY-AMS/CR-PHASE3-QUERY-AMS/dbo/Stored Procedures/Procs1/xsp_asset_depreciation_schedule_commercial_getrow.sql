CREATE procedure dbo.xsp_asset_depreciation_schedule_commercial_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,asset_code
			,depreciation_date
			,original_price
			,depreciation_amount
			,net_book_value
			,transaction_code
	from	asset_depreciation_schedule_commercial
	where	id = @p_id ;
end ;
