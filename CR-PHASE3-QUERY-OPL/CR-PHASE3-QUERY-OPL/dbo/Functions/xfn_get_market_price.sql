create FUNCTION dbo.xfn_get_market_price
(
	@p_reff_no	nvarchar(50) = null
)
returns decimal(18,2)
as
begin
	declare @total_market_price	decimal(18,2) = 0

		begin
			select	@total_market_price = sum(isnull(market_value,0))
			from	dbo.application_asset
			where	application_no = @p_reff_no

		end
	
    return @total_market_price;

end
