CREATE PROCEDURE dbo.xsp_master_rounding_getrows
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
	from	master_rounding
	where	(
				code				like '%' + @p_keywords + '%'
				or	currency_code	like '%' + @p_keywords + '%'
				or	rounding_type	like '%' + @p_keywords + '%'
				or	rounding_amount like '%' + @p_keywords + '%'
			) ;
			 
		select		code
					,currency_code
					,rounding_type
					,rounding_amount
					,@rows_count 'rowcount'
		from		master_rounding
		where		(
						code				like '%' + @p_keywords + '%'
						or	currency_code	like '%' + @p_keywords + '%'
						or	rounding_type	like '%' + @p_keywords + '%'
						or	rounding_amount like '%' + @p_keywords + '%'
					) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then currency_code
													when 2 then rounding_type
													when 3 then cast(rounding_amount  as sql_variant)
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then currency_code
													when 2 then rounding_type
													when 3 then cast(rounding_amount  as sql_variant)
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;
