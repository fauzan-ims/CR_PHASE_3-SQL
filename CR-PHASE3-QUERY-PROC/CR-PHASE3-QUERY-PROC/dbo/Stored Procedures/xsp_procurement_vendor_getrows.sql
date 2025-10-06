CREATE PROCEDURE dbo.xsp_procurement_vendor_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_code	   nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	procurement_vendor
	where	procurement_code = @p_code
			and (
					id like '%' + @p_keywords + '%'
					or	procurement_code like '%' + @p_keywords + '%'
					or	vendor_code like '%' + @p_keywords + '%'
					or	vendor_name like '%' + @p_keywords + '%'
				) ;

	select		id
				,procurement_code
				,vendor_code
				,vendor_name
				,@rows_count 'rowcount'
	from		procurement_vendor
	where		procurement_code = @p_code
				and (
						id like '%' + @p_keywords + '%'
						or	procurement_code like '%' + @p_keywords + '%'
						or	vendor_code like '%' + @p_keywords + '%'
						or	vendor_name like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then procurement_code
													 when 2 then vendor_code  collate latin1_general_ci_as
													 when 3 then vendor_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then procurement_code
													   when 2 then vendor_code collate latin1_general_ci_as
													   when 3 then vendor_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
