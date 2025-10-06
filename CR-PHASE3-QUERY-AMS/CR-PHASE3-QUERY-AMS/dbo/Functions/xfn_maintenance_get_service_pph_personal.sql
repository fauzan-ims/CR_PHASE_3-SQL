CREATE FUNCTION dbo.xfn_maintenance_get_service_pph_personal
(
	@p_id	bigint
)
returns decimal(18,2)
as
begin
	declare @amount			decimal(18,2)

	select @amount = isnull(sum(wod.pph_amount),0)
	from dbo.work_order_detail wod
	inner join dbo.work_order  wo on (wo.code = wod.work_order_code)
	inner join dbo.maintenance mnt on (mnt.code = wo.maintenance_code)
	left join ifinbam.dbo.master_vendor mv on (mv.code = mnt.vendor_code)
	where wod.id = @p_id
	and mv.vendor_type = 'P'

	return @amount
end ;
