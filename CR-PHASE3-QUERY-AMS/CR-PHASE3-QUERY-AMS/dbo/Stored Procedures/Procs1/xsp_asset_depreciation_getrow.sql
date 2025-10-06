CREATE procedure dbo.xsp_asset_depreciation_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,asset_code
			,barcode
			,depreciation_date
			,depreciation_commercial_amount
			,net_book_value_commercial
			,depreciation_fiscal_amount
			,net_book_value_fiscal
			,purchase_amount
			,status
	from	asset_depreciation
	where	id = @p_id ;
end ;
