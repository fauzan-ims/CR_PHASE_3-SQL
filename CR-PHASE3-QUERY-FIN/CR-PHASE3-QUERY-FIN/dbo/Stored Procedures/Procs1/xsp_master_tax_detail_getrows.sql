CREATE PROCEDURE dbo.xsp_master_tax_detail_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_tax_code   nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_tax_detail
	where	tax_code = @p_tax_code
	and		(
				convert(varchar, effective_date, 103)		like '%' + @p_keywords + '%'
				or	from_value_amount						like '%' + @p_keywords + '%'
				or	to_value_amount							like '%' + @p_keywords + '%'
				or	with_tax_number_pct						like '%' + @p_keywords + '%'
				or	without_tax_number_pct					like '%' + @p_keywords + '%'
			) ;

		select		id
					,convert(varchar(30), effective_date, 103) 'effective_date'
					,from_value_amount
					,to_value_amount
					,with_tax_number_pct
					,without_tax_number_pct
					,@rows_count 'rowcount'
		from		master_tax_detail
		where		tax_code = @p_tax_code
		and			(
						convert(varchar, effective_date, 103)		like '%' + @p_keywords + '%'
						or	from_value_amount						like '%' + @p_keywords + '%'
						or	to_value_amount							like '%' + @p_keywords + '%'
						or	with_tax_number_pct						like '%' + @p_keywords + '%'
						or	without_tax_number_pct					like '%' + @p_keywords + '%'
					)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then convert(varchar(30), effective_date, 103) 
														when 2 then cast(from_value_amount as sql_variant)
														when 3 then cast(to_value_amount as sql_variant)
														when 4 then cast(with_tax_number_pct as sql_variant)
														when 5 then cast(without_tax_number_pct as sql_variant)
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then convert(varchar(30), effective_date, 103) 
														when 2 then cast(from_value_amount as sql_variant)
														when 3 then cast(to_value_amount as sql_variant)
														when 4 then cast(with_tax_number_pct as sql_variant)
														when 5 then cast(without_tax_number_pct as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
