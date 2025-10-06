CREATE procedure dbo.xsp_master_mapping_value_getrows
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
	from	master_mapping_value
	where	(
				code like '%' + @p_keywords + '%'
				or	company_code like '%' + @p_keywords + '%'
				or	transaction_type like '%' + @p_keywords + '%'
				or	view_name like '%' + @p_keywords + '%'
				or	case is_active
						when '1' then 'ACTIVE'
						else 'INACTIVE'
					end like '%' + @p_keywords + '%'
			) ;

	select		code
				,company_code
				,transaction_type
				,view_name
				,case is_active
					 when '1' then 'ACTIVE'
					 else 'INACTIVE'
				 end 'is_active'
				,@rows_count 'rowcount'
	from		master_mapping_value
	where		(
					code like '%' + @p_keywords + '%'
					or	company_code like '%' + @p_keywords + '%'
					or	transaction_type like '%' + @p_keywords + '%'
					or	view_name like '%' + @p_keywords + '%'
					or	case is_active
							when '1' then 'ACTIVE'
							else 'INACTIVE'
						end like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then company_code
													 when 3 then transaction_type
													 when 4 then view_name
													 when 5 then is_active
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then code
													   when 2 then company_code
													   when 3 then transaction_type
													   when 4 then view_name
													   when 5 then is_active
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
