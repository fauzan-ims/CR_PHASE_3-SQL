CREATE FUNCTION dbo.xfn_sold_settlement_get_bank_in
(
	@p_id bigint
)
returns decimal(18,2)
as
begin
	declare @amount			decimal(18,2)

	select @amount = sale_value - (total_fee_amount - total_pph_amount + total_ppn_amount) 
	from dbo.sale_detail
	where id = @p_id

	return @amount
end ;
