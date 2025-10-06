create FUNCTION dbo.xfn_sold_settlement_get_total_depre_comm
(
	@p_id bigint
)
returns decimal(18,2)
as
begin
	declare @amount			decimal(18,2)

	select @amount = ass.total_depre_comm 
	from dbo.sale_detail sd
	left join dbo.asset ass on (ass.code = sd.asset_code)
	where id = @p_id

	return @amount
end ;
