
CREATE procedure xsp_asset_ending_balance_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	asset_ending_balance
	where	(
				asset_code like '%' + @p_keywords + '%'
				or	period like '%' + @p_keywords + '%'
				or	balance_amount like '%' + @p_keywords + '%'
				or	balance_amount_accum like '%' + @p_keywords + '%'
			) ;

	select		id
				,asset_code
				,period
				,balance_amount
				,balance_amount_accum
				,@rows_count 'rowcount'
	from		asset_ending_balance
	where		(
					id like '%' + @p_keywords + '%'
					or	asset_code like '%' + @p_keywords + '%'
					or	period like '%' + @p_keywords + '%'
					or	balance_amount like '%' + @p_keywords + '%'
					or	balance_amount_accum like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then asset_code
													 when 2 then cast(period as sql_variant)
													 when 3 then balance_amount
													 when 4 then balance_amount_accum
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then asset_code
													   when 2 then cast(period as sql_variant)
													   when 3 then balance_amount
													   when 4 then balance_amount_accum
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
