CREATE FUNCTION dbo.xfn_sold_settlement_get_gain_loss_disposal
(
	@p_id bigint
)
returns decimal(18,2)
as
begin
	-- gain loss belum accounting sold asset
	declare @amount			bigint--decimal(18,2)

	select @amount =  gain_loss
	from dbo.sale_detail sd
	inner join dbo.sale sl on (sl.code = sd.sale_code)
	where id = @p_id
	and sl.sell_type = 'CLAIM'

	return @amount
end ;
