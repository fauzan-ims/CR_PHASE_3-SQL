CREATE FUNCTION dbo.xfn_sold_settlement_get_gain_loss
(
	@p_id bigint
)
returns decimal(18,2)
as
begin
	-- gain loss belum accounting sold asset
	declare @amount			bigint

	select @amount =  gain_loss
	from dbo.sale_detail
	where id = @p_id

	return @amount
end ;
