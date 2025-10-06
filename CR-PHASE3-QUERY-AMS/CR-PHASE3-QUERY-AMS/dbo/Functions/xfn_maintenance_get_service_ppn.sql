CREATE FUNCTION dbo.xfn_maintenance_get_service_ppn
(
	@p_id	bigint
)
returns decimal(18,2)
as
begin
	declare @amount			decimal(18,2)

	select @amount = sum(ppn_amount)
	from dbo.work_order_detail
	where id = @p_id

	return @amount
end ;
