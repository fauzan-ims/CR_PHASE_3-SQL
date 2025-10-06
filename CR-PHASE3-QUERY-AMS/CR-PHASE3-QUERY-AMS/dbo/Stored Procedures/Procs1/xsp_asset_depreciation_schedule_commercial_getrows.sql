CREATE PROCEDURE dbo.xsp_asset_depreciation_schedule_commercial_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_asset_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	asset_depreciation_schedule_commercial
	where	asset_code = @p_asset_code
	and		(
				convert(varchar(30),depreciation_date,103)			 like '%' + @p_keywords + '%'
				or	transaction_code								 like '%' + @p_keywords + '%'
				or	depreciation_amount								 like '%' + @p_keywords + '%'
				or	accum_depre_amount								 like '%' + @p_keywords + '%'
				or	net_book_value									 like '%' + @p_keywords + '%'
			) ;

	select		id
				,asset_code
				,convert(varchar(30),depreciation_date,103) 'depreciation_date'
				,original_price
				,depreciation_amount
				,accum_depre_amount
				,net_book_value
				,transaction_code
				,@rows_count 'rowcount'
	from		asset_depreciation_schedule_commercial
	where		asset_code = @p_asset_code
	and			(
					convert(varchar(30),depreciation_date,103)			 like '%' + @p_keywords + '%'
					or	transaction_code								 like '%' + @p_keywords + '%'
					or	accum_depre_amount								 like '%' + @p_keywords + '%'
					or	depreciation_amount								 like '%' + @p_keywords + '%'
					or	net_book_value									 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then cast(depreciation_date as sql_variant)
													 when 2 then transaction_code
													 when 3 then cast(depreciation_amount as sql_variant)
													 when 4 then cast(accum_depre_amount as sql_variant)
													 when 5 then cast(net_book_value as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then cast(depreciation_date as sql_variant)
													 when 2 then transaction_code
													 when 3 then cast(depreciation_amount as sql_variant)
													 when 4 then cast(accum_depre_amount as sql_variant)
													 when 5 then cast(net_book_value as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
