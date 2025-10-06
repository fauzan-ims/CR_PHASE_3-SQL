CREATE PROCEDURE dbo.xsp_adjustment_supplier_lookup
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_company_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.asset ass
	where	ass.company_code = @p_company_code
	and		ass.status in ('STOCK', 'REPLACEMENT')
			and (
					ass.code				like '%' + @p_keywords + '%'
					or	ass.company_code	like '%' + @p_keywords + '%'
					or	ass.item_name		like '%' + @p_keywords + '%'
				) ;

	select	ass.vendor_code
			,ass.vendor_name
			,ass.company_code
			,@rows_count 'rowcount'
	from	dbo.asset ass
	where	ass.company_code = @p_company_code			
	and		ass.status in ('STOCK', 'REPLACEMENT')
	and		(
				ass.vendor_code			like '%' + @p_keywords + '%'
				or	ass.vendor_name		like '%' + @p_keywords + '%'
				or	ass.company_code	like '%' + @p_keywords + '%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ass.vendor_code
													 when 2 then ass.vendor_name
													 when 3 then ass.company_code
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													    when 1 then ass.vendor_code
														when 2 then ass.vendor_name
														when 3 then ass.company_code
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
