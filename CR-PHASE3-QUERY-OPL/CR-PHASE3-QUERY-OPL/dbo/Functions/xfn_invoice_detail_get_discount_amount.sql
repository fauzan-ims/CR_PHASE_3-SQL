create FUNCTION dbo.xfn_invoice_detail_get_discount_amount
(
	@p_id bigint
)
returns decimal(18, 2)
as
begin
	declare @total_amount decimal(18, 2) ;

	select	@total_amount = discount_amount
	from	dbo.invoice_detail
	where	id = @p_id ;

	return isnull(@total_amount, 0) ;
end ;
