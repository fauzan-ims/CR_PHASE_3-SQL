CREATE PROCEDURE dbo.xsp_opname_detail_history_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_opname_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	opname_detail_history od
			left join dbo.asset ass on (ass.code = od.asset_code)
	where	opname_code = @p_opname_code
	and		(
				asset_code				 like '%' + @p_keywords + '%'
				or	ass.item_name		 like '%' + @p_keywords + '%'
				or	depre_comercial		 like '%' + @p_keywords + '%'
				or	depre_fiscal		 like '%' + @p_keywords + '%'
				or	ass.barcode			 like '%' + @p_keywords + '%'
				or	stock				 like '%' + @p_keywords + '%'
				or	quantity			 like '%' + @p_keywords + '%'
				or	condition_code		 like '%' + @p_keywords + '%'
			) ;

	select		id
				,opname_code
				,asset_code
				,ass.item_name
				,stock
				,quantity
				,depre_comercial
				,depre_fiscal
				,od.branch_code
				,od.branch_name
				,ass.barcode
				,od.location_code
				,condition_code
				,od.location_in
				,od.file_name
				,od.path
				,@rows_count 'rowcount'
	from		opname_detail_history od
				left join dbo.asset ass on (ass.code = od.asset_code)
	where		opname_code = @p_opname_code
	and			(
					asset_code				 like '%' + @p_keywords + '%'
					or	ass.item_name		 like '%' + @p_keywords + '%'
					or	depre_comercial		 like '%' + @p_keywords + '%'
					or	depre_fiscal		 like '%' + @p_keywords + '%'
					or	ass.barcode			 like '%' + @p_keywords + '%'
					or	stock				 like '%' + @p_keywords + '%'
					or	quantity			 like '%' + @p_keywords + '%'
					or	condition_code		 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ass.item_name
													 when 2 then cast(stock as sql_variant)
													 when 3 then cast(quantity as sql_variant)
													 when 4 then condition_code
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then ass.item_name
													 when 2 then cast(stock as sql_variant)
													 when 3 then cast(quantity as sql_variant)
													 when 4 then condition_code
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
