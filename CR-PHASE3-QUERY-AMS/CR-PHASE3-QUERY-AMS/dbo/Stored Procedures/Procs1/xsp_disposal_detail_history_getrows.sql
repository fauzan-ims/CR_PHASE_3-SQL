
CREATE PROCEDURE [dbo].[xsp_disposal_detail_history_getrows]
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
	from	dbo.disposal_detail_history dd
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
				,@rows_count 'rowcount'
	from		dbo.disposal_detail_history dd
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
													 when 1 then asset_code
													 when 2 then dd.cost_center_name
													 when 3 then description
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then asset_code
													 when 2 then dd.cost_center_name
													 when 3 then description
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
