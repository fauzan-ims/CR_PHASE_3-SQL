CREATE FUNCTION dbo.xfn_work_order_get_service_fee
(
	@p_id	bigint
)
returns decimal(18,2)
as
begin
	declare @amount			decimal(18,2)

	select	@amount = (service_fee * quantity)
	from	dbo.work_order_detail wod
	where	id = @p_id 
	and wod.service_code <> 'MNTCL'
	and wod.service_type = 'JASA'

	return @amount
end ;
