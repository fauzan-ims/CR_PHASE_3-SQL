
CREATE PROCEDURE [dbo].[xsp_sale_detail_history_getrows]
(
	@p_keywords	    nvarchar(50)
	,@p_pagenumber  int
	,@p_rowspage    int
	,@p_order_by    int
	,@p_sort_by	    nvarchar(5)
	,@p_sale_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.sale_detail_history sd
			inner join dbo.asset ass		on (ass.code = sd.asset_code)
	where	sale_code = @p_sale_code
	and		(
				asset_code													like '%' + @p_keywords + '%'
				or	ass.item_name											like '%' + @p_keywords + '%'
				or	sd.description											like '%' + @p_keywords + '%'
				or	sd.cost_center_name										like '%' + @p_keywords + '%'
				or	sd.sale_value											like '%' + @p_keywords + '%'
				or	ass.barcode												like '%' + @p_keywords + '%'
				or	sd.net_book_value										like '%' + @p_keywords + '%'
				or	sd.cost_center_code										like '%' + @p_keywords + '%'
				or	(isnull(sd.sale_value,0) - isnull(sd.net_book_value,0))	like '%' + @p_keywords + '%'
			) ;

	select		id
				,sale_code
				,asset_code
				,ass.item_name
				,sd.description
				,sd.cost_center_code
				,sd.cost_center_name
				,sale_value
				,ass.barcode
				,sd.net_book_value
				,(isnull(sd.sale_value,0) - isnull(sd.net_book_value,0)) 'gain_loss'
				,@rows_count 'rowcount'
	from		dbo.sale_detail_history sd
				inner join dbo.asset ass on (ass.code = sd.asset_code)
	where		sale_code = @p_sale_code
	and			(
					asset_code													like '%' + @p_keywords + '%'
					or	ass.item_name											like '%' + @p_keywords + '%'
					or	sd.description											like '%' + @p_keywords + '%'
					or	sd.cost_center_code										like '%' + @p_keywords + '%'
					or	sd.cost_center_name										like '%' + @p_keywords + '%'
					or	sd.sale_value											like '%' + @p_keywords + '%'
					or	ass.barcode												like '%' + @p_keywords + '%'
					or	sd.net_book_value										like '%' + @p_keywords + '%'
					or	(isnull(sd.sale_value,0) - isnull(sd.net_book_value,0))	like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then asset_code
													 when 2 then sd.cost_center_name
													 when 3 then sd.description
													 when 4 then cast(sd.net_book_value as sql_variant)
													 when 5 then cast(sale_value as sql_variant)
													 when 6 then cast(isnull(sd.sale_value,0) - isnull(sd.net_book_value,0) as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then asset_code
													 when 2 then sd.cost_center_name
													 when 3 then sd.description
													 when 4 then cast(sd.net_book_value as sql_variant)
													 when 5 then cast(sale_value as sql_variant)
													 when 6 then cast(isnull(sd.sale_value,0) - isnull(sd.net_book_value,0) as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
