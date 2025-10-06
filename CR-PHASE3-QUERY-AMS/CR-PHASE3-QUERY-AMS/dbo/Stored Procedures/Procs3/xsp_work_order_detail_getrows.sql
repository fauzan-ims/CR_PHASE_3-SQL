CREATE PROCEDURE dbo.xsp_work_order_detail_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_work_order_code		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	work_order_detail
	where	work_order_code = @p_work_order_code
	and		(
				service_code					like '%' + @p_keywords + '%'
				or	service_name				like '%' + @p_keywords + '%'
				or	service_type				like '%' + @p_keywords + '%'
				or	service_fee					like '%' + @p_keywords + '%'
				or	quantity					like '%' + @p_keywords + '%'
				or	pph_amount					like '%' + @p_keywords + '%'
				or	ppn_amount					like '%' + @p_keywords + '%'
				or	total_amount				like '%' + @p_keywords + '%'
				or	payment_amount				like '%' + @p_keywords + '%'
				or	tax_code					like '%' + @p_keywords + '%'
				or	tax_name					like '%' + @p_keywords + '%'
				or	ppn_pct						like '%' + @p_keywords + '%'
				or	pph_pct						like '%' + @p_keywords + '%'
				or	part_number					like '%' + @p_keywords + '%'
			) ;

	select		id
				,work_order_code
				,asset_maintenance_schedule_id
				,service_code
				,service_name
				,service_type
				,service_fee
				,quantity
				,pph_amount
				,ppn_amount
				,total_amount
				,payment_amount
				,tax_code
				,tax_name
				,ppn_pct
				,pph_pct
				,part_number
				,@rows_count 'rowcount'
	from		work_order_detail
	where		work_order_code = @p_work_order_code
	and			(
					service_code					like '%' + @p_keywords + '%'
					or	service_name				like '%' + @p_keywords + '%'
					or	service_type				like '%' + @p_keywords + '%'
					or	service_fee					like '%' + @p_keywords + '%'
					or	quantity					like '%' + @p_keywords + '%'
					or	pph_amount					like '%' + @p_keywords + '%'
					or	ppn_amount					like '%' + @p_keywords + '%'
					or	total_amount				like '%' + @p_keywords + '%'
					or	payment_amount				like '%' + @p_keywords + '%'
					or	tax_code					like '%' + @p_keywords + '%'
					or	tax_name					like '%' + @p_keywords + '%'
					or	ppn_pct						like '%' + @p_keywords + '%'
					or	pph_pct						like '%' + @p_keywords + '%'
					or	part_number					like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then service_code + service_name + service_type
													 when 2 then service_type
													 when 3 then part_number
													 when 4 then cast(service_fee as sql_variant)
													 when 5 then cast(quantity as sql_variant)
													 when 6 then cast(total_amount as sql_variant)
													 when 7 then tax_name
													 when 8 then cast(ppn_amount as sql_variant)
													 when 9 then cast(payment_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then service_code + service_name + service_type
													   when 2 then service_type
													   when 3 then part_number
													   when 4 then cast(service_fee as sql_variant)
													   when 5 then cast(quantity as sql_variant)
													   when 6 then cast(total_amount as sql_variant)
													   when 7 then tax_name
													   when 8 then cast(ppn_amount as sql_variant)
													   when 9 THEN cast(payment_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
