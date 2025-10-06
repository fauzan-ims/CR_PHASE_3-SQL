CREATE FUNCTION [dbo].[xfn_sold_settlement_get_rl_deduct]
(
	@p_id bigint
)
returns decimal(18, 2)
as
begin
	declare @amount			   BIGINT
			, @nb_fiskalamount decimal(18, 2) ;

	select	@nb_fiskalamount = net_book_value_fiscal
	from	asset
	where	code =
	(
		select	asset_code
		from	dbo.sale_detail
		where	id = @p_id
	) ;

	-- harga jual setelah ppn - nb fiscal
	select	@amount = (sold_amount - ppn_asset) - @nb_fiskalamount
	from	dbo.sale_detail
	where	id = @p_id ;

	return @amount ;
end ;
