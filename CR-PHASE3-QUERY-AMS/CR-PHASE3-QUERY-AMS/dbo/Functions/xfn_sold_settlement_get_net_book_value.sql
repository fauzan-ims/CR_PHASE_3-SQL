create FUNCTION dbo.xfn_sold_settlement_get_net_book_value
(
	@p_id bigint
)
returns decimal(18,2)
as
begin
	declare @amount			decimal(18,2)

	select @amount = sd.net_book_value 
	from dbo.sale_detail sd
	where id = @p_id

	return @amount
end ;
