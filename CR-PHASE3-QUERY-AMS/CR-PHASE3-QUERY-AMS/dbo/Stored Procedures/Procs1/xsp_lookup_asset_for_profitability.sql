CREATE PROCEDURE [dbo].[xsp_lookup_asset_for_profitability]
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
	left join dbo.asset_vehicle avh on (ass.code = avh.asset_code)
	where	company_code	= @p_company_code
	--and status in ('STOCK', 'REPLACEMENT')
	and		(
				code							like '%' + @p_keywords + '%'
				or	item_name					like '%' + @p_keywords + '%'
				or	avh.plat_no					like '%' + @p_keywords + '%'
			) ;

	select		code
				,barcode
				,item_name
				,avh.plat_no
				,@rows_count 'rowcount'
	from		dbo.asset ass
	left join dbo.asset_vehicle avh on (ass.code = avh.asset_code)
	where		company_code	= @p_company_code
	--and status in ('STOCK', 'REPLACEMENT')
	and			(
					code							like '%' + @p_keywords + '%'
					or	item_name					like '%' + @p_keywords + '%'
					or	avh.plat_no					like '%' + @p_keywords + '%'
				) 
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then ass.item_name
													 when 3 then avh.plat_no
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then ass.item_name
														when 3 then avh.plat_no
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
