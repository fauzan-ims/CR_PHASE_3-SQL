CREATE PROCEDURE dbo.xsp_sale_detail_lookup
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_sale_code		nvarchar(50)
	--,@p_bidding_code	nvarchar(50) 
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.sale_detail sd
			inner join dbo.asset ass on (ass.code = sd.asset_code)
	where	sale_code = @p_sale_code
	--and		sd.asset_code not in (select asset_code from dbo.sale_bidding_detail where bidding_code = @p_bidding_code)
	and		(
				asset_code			like '%' + @p_keywords + '%'
				or	item_name		like '%' + @p_keywords + '%'
			) ;

	select		sale_code
				,asset_code
				,ass.item_name
				,description 'description_detail_lookup'
				,sale_value
				,@rows_count 'rowcount'
	from		dbo.sale_detail sd
				inner join dbo.asset ass on (ass.code = sd.asset_code)
	where		sale_code = @p_sale_code
	--and			sd.asset_code not in (select asset_code from dbo.sale_bidding_detail where bidding_code = @p_bidding_code)
	and			(
					asset_code			like '%' + @p_keywords + '%'
					or	item_name		like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by	
														when 1 then asset_code
														when 2 then description
					 								end
				end asc
				,case
					when @p_sort_by = 'desc' then case @p_order_by				
														when 1 then asset_code
														when 2 then description
					 								end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;

end ;
