--created by, Rian at 30/05/2023 

CREATE procedure dbo.xsp_opl_interface_purchase_order_update_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select		@rows_count = count(1)
	from		dbo.opl_interface_purchase_order_update
	where		(
					id											like '%' + @p_keywords + '%'
					or	purchase_code							like '%' + @p_keywords + '%'
					or	po_code									like '%' + @p_keywords + '%'
					or	convert(nvarchar(15), eta_po_date, 103)	like '%' + @p_keywords + '%'
					or	supplier_code							like '%' + @p_keywords + '%'
					or	supplier_name							like '%' + @p_keywords + '%'
					or	convert(nvarchar(15), settle_date, 103) like '%' + @p_keywords + '%'
					or	job_status								like '%' + @p_keywords + '%'
					or	failed_remarks							like '%' + @p_keywords + '%'
				) ;

	select		id
			   ,purchase_code
			   ,po_code
			   ,convert(nvarchar(15), eta_po_date, 103) 'eta_po_date'
			   ,supplier_code
			   ,supplier_name
			   ,unit_from
			   ,convert(nvarchar(15), settle_date, 103) 'settle_date'
			   ,job_status
			   ,failed_remarks
				,@rows_count 'rowcount'
	from		opl_interface_purchase_order_update
	where		(
					id											like '%' + @p_keywords + '%'
					or	purchase_code							like '%' + @p_keywords + '%'
					or	po_code									like '%' + @p_keywords + '%'
					or	convert(nvarchar(15), eta_po_date, 103)	like '%' + @p_keywords + '%'
					or	supplier_code							like '%' + @p_keywords + '%'
					or	supplier_name							like '%' + @p_keywords + '%'
					or	convert(nvarchar(15), settle_date, 103) like '%' + @p_keywords + '%'
					or	job_status								like '%' + @p_keywords + '%'
					or	failed_remarks							like '%' + @p_keywords + '%'
				) 
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then purchase_code										
													 when 2 then po_code								
													 when 3 then cast(eta_po_date as sql_variant)
													 when 4 then supplier_code							
													 when 5 then supplier_name								
													 when 6 then cast(settle_date as sql_variant)
													 when 7 then job_status
													 when 8 then failed_remarks
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then purchase_code										
														when 2 then po_code								
														when 3 then cast(eta_po_date as sql_variant)
														when 4 then supplier_code							
														when 5 then supplier_name								
														when 6 then cast(settle_date as sql_variant)
														when 7 then job_status
														when 8 then failed_remarks
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
