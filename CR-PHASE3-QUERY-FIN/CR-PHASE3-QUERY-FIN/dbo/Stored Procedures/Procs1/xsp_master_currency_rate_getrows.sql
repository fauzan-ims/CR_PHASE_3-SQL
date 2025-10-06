CREATE PROCEDURE dbo.xsp_master_currency_rate_getrows
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
	from	master_currency_rate
	where	(
				id						like '%' + @p_keywords + '%'
				or	currency_code		like '%' + @p_keywords + '%'
				or	eff_date			like '%' + @p_keywords + '%'
				or	exch_rate			like '%' + @p_keywords + '%'
			) ;

		select		id
					,currency_code
					,eff_date
					,exch_rate
					,@rows_count 'rowcount'
		from		master_currency_rate
		where		(
						id						like '%' + @p_keywords + '%'
						or	currency_code		like '%' + @p_keywords + '%'
						or	eff_date			like '%' + @p_keywords + '%'
						or	exch_rate			like '%' + @p_keywords + '%'
					)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then currency_code
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then currency_code
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
