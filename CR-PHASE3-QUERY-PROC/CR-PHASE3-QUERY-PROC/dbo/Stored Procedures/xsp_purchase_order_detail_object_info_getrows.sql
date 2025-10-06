create PROCEDURE dbo.xsp_purchase_order_detail_object_info_getrows
(
	@p_keywords						nvarchar(50)
	,@p_pagenumber					int
	,@p_rowspage					int
	,@p_order_by					int
	,@p_sort_by						nvarchar(5)
	,@p_purchase_order_detail_id	bigint
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.purchase_order_detail_object_info
	where	purchase_order_detail_id = @p_purchase_order_detail_id
	and		(
				plat_no				like '%' + @p_keywords + '%'
				or	chassis_no		like '%' + @p_keywords + '%'
				or	engine_no		like '%' + @p_keywords + '%'
				or	serial_no		like '%' + @p_keywords + '%'
				or	invoice_no		like '%' + @p_keywords + '%'
				or	domain			like '%' + @p_keywords + '%'
				or	imei			like '%' + @p_keywords + '%'

			) ;

	select		id
				,good_receipt_note_detail_id
				,plat_no
				,chassis_no
				,engine_no
				,serial_no
				,invoice_no
				,domain
				,imei
				,@rows_count 'rowcount'
	from		dbo.purchase_order_detail_object_info
	where		purchase_order_detail_id = @p_purchase_order_detail_id
	and			(
					plat_no				like '%' + @p_keywords + '%'
					or	chassis_no		like '%' + @p_keywords + '%'
					or	engine_no		like '%' + @p_keywords + '%'
					or	serial_no		like '%' + @p_keywords + '%'
					or	invoice_no		like '%' + @p_keywords + '%'
					or	domain			like '%' + @p_keywords + '%'
					or	imei			like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then plat_no
													 when 2 then serial_no
													 when 3 then invoice_no
													 when 4 then chassis_no
													 when 5 then engine_no
													 when 6 then domain
													 when 7 then imei
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													  when 1 then plat_no
													  when 2 then serial_no
													  when 3 then invoice_no
													  when 4 then chassis_no
													  when 5 then engine_no
													  when 6 then domain
													  when 7 then imei
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
