CREATE PROCEDURE dbo.xsp_disposal_detail_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_disposal_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	disposal_detail dd
			left join dbo.asset ass on (ass.code =  dd.asset_code)
	where	disposal_code	= @p_disposal_code
	and		(
				asset_code				like '%' + @p_keywords + '%'
				or	dd.cost_center_name	like '%' + @p_keywords + '%'
				or	ass.barcode			like '%' + @p_keywords + '%'
				or	ass.item_name		like '%' + @p_keywords + '%'
				or	description			like '%' + @p_keywords + '%'
			) ;

	select		id
				,disposal_code
				,ass.item_name
				,asset_code
				,ass.barcode
				,dd.cost_center_name
				,description
				,dd.net_book_value
				,ass.purchase_price
				,ass.total_depre_comm
				,ass.item_group_code
				,@rows_count 'rowcount'
	from		disposal_detail dd
				left join dbo.asset ass on (ass.code =  dd.asset_code)
	where		disposal_code	= @p_disposal_code
	and			(
					asset_code				like '%' + @p_keywords + '%'
					or	dd.cost_center_name	like '%' + @p_keywords + '%'
					or	ass.barcode			like '%' + @p_keywords + '%'
					or	ass.item_name		like '%' + @p_keywords + '%'
					or	description			like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then dd.asset_code
													 when 2 then dd.description
													 when 3 then cast(ass.purchase_price as sql_variant)
													 when 4 then cast(ass.total_depre_comm as sql_variant)
													 when 5 then cast(dd.net_book_value as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then dd.asset_code 
													 when 2 then dd.description
													 when 3 then cast(ass.purchase_price as sql_variant)
													 when 4 then cast(ass.total_depre_comm as sql_variant)
													 when 5 then cast(dd.net_book_value as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
