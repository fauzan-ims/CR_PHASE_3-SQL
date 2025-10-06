CREATE PROCEDURE dbo.xsp_asset_lookup_for_pricing_request
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_code			nvarchar(50)
	,@p_branch_code		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.asset ass
	left join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
	where	ass.status		 = 'STOCK'
			and ass.branch_code = @p_branch_code
			and ass.code not in (select asset_code from dbo.asset_management_pricing_detail where pricing_code = @p_code)
			and (
					ass.code						like '%' + @p_keywords + '%'
					or	ass.item_name				like '%' + @p_keywords + '%'
					or	ass.sell_request_amount		like '%' + @p_keywords + '%'
					or	avh.plat_no					like '%' + @p_keywords + '%'
				) ;

	select		ass.code
				,ass.branch_code
				,ass.branch_name
				,ass.item_name
				,ass.barcode
				,ass.division_code
				,ass.division_name
				,ass.department_code
				,ass.department_name
				,ass.purchase_price
				,ass.total_depre_comm
				,ass.net_book_value_comm
				,ass.net_book_value_fiscal
				,isnull(ass.sell_request_amount,0) 'sell_request_amount'
				,avh.plat_no
				,@rows_count 'rowcount'
	from		dbo.asset ass
	left join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
	where		ass.status		 = 'STOCK'
				and ass.branch_code = @p_branch_code
				and ass.code not in (select asset_code from dbo.asset_management_pricing_detail where pricing_code = @p_code)
				and (
						ass.code						like '%' + @p_keywords + '%'
						or	ass.item_name				like '%' + @p_keywords + '%'
						or	ass.sell_request_amount		like '%' + @p_keywords + '%'
						or	avh.plat_no					like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ass.code
													 when 2 then ass.item_name
													 when 3 then avh.plat_no
													 when 4 then cast(ass.net_book_value_comm as sql_variant)
													 when 5 then cast(ass.sell_request_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													  when 1 then ass.code
													  when 2 then ass.item_name
													  when 3 then avh.plat_no
													  when 4 then cast(ass.net_book_value_comm as sql_variant)
													  when 5 then cast(ass.sell_request_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
