CREATE PROCEDURE dbo.xsp_reverse_sale_detail_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_reverse_sale_code	nvarchar(50)
)
as
begin

	declare		@rows_count int = 0 ;

	select		@rows_count = count(1)
	from		reverse_sale_detail rsd
				inner join dbo.asset ass on (ass.code = rsd.asset_code)
	where		reverse_sale_code = @p_reverse_sale_code
	and			(
					rsd.id															like '%' + @p_keywords + '%'
					or	rsd.reverse_sale_code										like '%' + @p_keywords + '%'
					or	rsd.asset_code												like '%' + @p_keywords + '%'
					or	rsd.description												like '%' + @p_keywords + '%'
					or	ass.barcode													like '%' + @p_keywords + '%'
					or	rsd.sale_value												like '%' + @p_keywords + '%'
					or	rsd.net_book_value											like '%' + @p_keywords + '%'
					or	(isnull(rsd.sale_value,0) - isnull(rsd.net_book_value,0))	like '%' + @p_keywords + '%'
					or	rsd.cost_center_code										like '%' + @p_keywords + '%'
					or	rsd.cost_center_name										like '%' + @p_keywords + '%'
				) ;

	select		rsd.id
				,rsd.reverse_sale_code
				,rsd.asset_code 'asset'
				,rsd.description
				,rsd.sale_value
				,ass.item_name 'asset_code'
				,ass.barcode
				,rsd.net_book_value
				,(isnull(rsd.sale_value,0) - isnull(rsd.net_book_value,0)) 'gain_loss'
				,rsd.cost_center_code
				,rsd.cost_center_name
				,@rows_count 'rowcount'
	from		reverse_sale_detail rsd
				inner join dbo.asset ass on (ass.code = rsd.asset_code)
	where		reverse_sale_code = @p_reverse_sale_code
	and			(
					rsd.id															like '%' + @p_keywords + '%'
					or	rsd.reverse_sale_code										like '%' + @p_keywords + '%'
					or	rsd.asset_code												like '%' + @p_keywords + '%'
					or	rsd.description												like '%' + @p_keywords + '%'
					or	ass.barcode													like '%' + @p_keywords + '%'
					or	rsd.sale_value												like '%' + @p_keywords + '%'
					or	rsd.net_book_value											like '%' + @p_keywords + '%'
					or	rsd.cost_center_code										like '%' + @p_keywords + '%'
					or	rsd.cost_center_name										like '%' + @p_keywords + '%'
					or	(isnull(rsd.sale_value,0) - isnull(rsd.net_book_value,0))	like '%' + @p_keywords + '%'
				)
	order by	case
				 	when @p_sort_by = 'asc' then case @p_order_by			
														when 1 then rsd.reverse_sale_code
														when 2 then rsd.asset_code
														when 3 then rsd.description
														when 4 then rsd.net_book_value
														when 5 then rsd.sale_value
														when 6 then cast(isnull(rsd.sale_value,0) - isnull(rsd.net_book_value,0) as sql_variant)
				 									end
				end asc
				,case
				 		when @p_sort_by = 'desc' then case @p_order_by				
														when 1 then rsd.reverse_sale_code
														when 2 then rsd.asset_code
														when 3 then rsd.description
														when 4 then rsd.net_book_value
														when 5 then rsd.sale_value
														when 6 then cast(isnull(rsd.sale_value,0) - isnull(rsd.net_book_value,0) as sql_variant)
				 									end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
