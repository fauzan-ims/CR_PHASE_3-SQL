CREATE FUNCTION dbo.xfn_work_order_get_maintenance_service_fee
(
	@p_id	bigint
)
returns decimal(18,2)
as
begin
	declare @amount			decimal(18,2)

	select	@amount = (payment_amount)
	from	dbo.work_order_detail
	where	id = @p_id ;

	return @amount
end ;
