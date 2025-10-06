CREATE PROCEDURE dbo.xsp_work_order_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_company_code	nvarchar(50)
	,@p_status			nvarchar(20)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	work_order wo with(nolock)
	inner join dbo.asset ass with(nolock) on (wo.asset_code = ass.code)
	inner join dbo.maintenance mnt with(nolock) on (wo.maintenance_code = mnt.code)
	inner join dbo.asset_vehicle avh with(nolock) on (avh.asset_code = ass.code)
	where	wo.status = case @p_status
						when 'ALL' then wo.status
						else @p_status
					end
	and		wo.company_code = @p_company_code	
	and		(
				wo.asset_code										like '%' + @p_keywords + '%'
				or	mnt.spk_no										LIKE '%' + @p_keywords + '%'
				or	wo.remark										like '%' + @p_keywords + '%'
				or	wo.maintenance_by								like '%' + @p_keywords + '%'
				or	wo.status										like '%' + @p_keywords + '%'
				or	ass.item_name									like '%' + @p_keywords + '%'
				or	wo.CODE											like '%' + @p_keywords + '%'
				or	mnt.vendor_name									like '%' + @p_keywords + '%'
				or	mnt.service_type								like '%' + @p_keywords + '%'
				or	wo.payment_amount								like '%' + @p_keywords + '%'
				or	convert(nvarchar(30), mnt.work_date, 103)		like '%' + @p_keywords + '%'
				or	avh.plat_no										like '%' + @p_keywords + '%'
				or	avh.engine_no									like '%' + @p_keywords + '%'
				or	avh.chassis_no									like '%' + @p_keywords + '%'
				or	wo.faktur_no									like '%' + @p_keywords + '%'
				or	wo.actual_km									like '%' + @p_keywords + '%'
			) ;

	select		wo.code
				,wo.company_code
				,wo.asset_code
				,convert(nvarchar(30), mnt.work_date, 103) 'work_date'
				,ass.item_name
				,mnt.spk_no
				,case wo.maintenance_by
					when 'INT' then 'Internal'
					when 'EXT' then 'External'
					when 'CST' then 'Customer'
					else mnt.maintenance_by
					end	'maintenance_by'
				,wo.status
				,wo.remark
				,mnt.vendor_name
				,mnt.service_type
				,wo.payment_amount
				,avh.plat_no
				,avh.engine_no
				,avh.chassis_no
				,wo.actual_km  'last_meter'--,wo.last_meter
				,@rows_count 'rowcount'
	from		work_order wo with(nolock)
	inner join dbo.asset ass with(nolock) on (wo.asset_code = ass.code)
	inner join dbo.maintenance mnt with(nolock) on (wo.maintenance_code = mnt.code)
	inner join dbo.asset_vehicle avh with(nolock) on (avh.asset_code = ass.code)
	where		wo.status = case @p_status
						when 'ALL' then wo.status
						else @p_status
					end
	and		wo.company_code = @p_company_code
	and		(
					wo.asset_code										like '%' + @p_keywords + '%'
					or	mnt.spk_no										like '%' + @p_keywords + '%'
					or	wo.remark										like '%' + @p_keywords + '%'
					or	wo.maintenance_by								like '%' + @p_keywords + '%'
					or	wo.status										like '%' + @p_keywords + '%'
					or	ass.item_name									like '%' + @p_keywords + '%'
					or	wo.CODE											like '%' + @p_keywords + '%'
					or	mnt.vendor_name									like '%' + @p_keywords + '%'
					or	mnt.service_type								like '%' + @p_keywords + '%'
					or	wo.payment_amount								like '%' + @p_keywords + '%'
					or	convert(nvarchar(30), mnt.work_date, 103)		like '%' + @p_keywords + '%'
					or	avh.plat_no										like '%' + @p_keywords + '%'
					or	avh.engine_no									like '%' + @p_keywords + '%'
					or	avh.chassis_no									like '%' + @p_keywords + '%'
					or	wo.faktur_no									like '%' + @p_keywords + '%'
					or	wo.actual_km									like '%' + @p_keywords + '%'
				)	
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then wo.code + mnt.spk_no
													 when 2 then wo.asset_code + ass.item_name
													 when 3 then cast(mnt.work_date as sql_variant)
													 when 4 then mnt.vendor_name
													 when 5 then wo.maintenance_by
													 when 6 then wo.last_meter
													 when 7 then cast(wo.payment_amount as sql_variant)
													 when 8 then wo.remark
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then wo.code + mnt.spk_no
													 when 2 then wo.asset_code + ass.item_name
													 when 3 then cast(mnt.work_date as sql_variant)
													 when 4 then mnt.vendor_name
													 when 5 then wo.maintenance_by
													 when 6 then wo.last_meter
													 when 7 then cast(wo.payment_amount as sql_variant)
													 when 8 then wo.remark
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
