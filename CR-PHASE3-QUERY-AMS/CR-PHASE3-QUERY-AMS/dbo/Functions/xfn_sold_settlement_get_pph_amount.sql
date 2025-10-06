CREATE FUNCTION dbo.xfn_sold_settlement_get_pph_amount
(
	@p_id bigint
)
returns decimal(18,2)
as
begin
	declare @amount			bigint--decimal(18,2)

	select @amount = abs(sd.total_pph_amount)
	from dbo.sale_detail sd
	where id = @p_id

	return @amount
end ;
