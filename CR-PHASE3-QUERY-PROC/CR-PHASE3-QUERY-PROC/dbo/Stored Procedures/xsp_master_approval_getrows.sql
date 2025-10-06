create PROCEDURE dbo.xsp_master_approval_getrows
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
	from	master_approval
	where	(
				code like '%' + @p_keywords + '%'
				or	approval_name like '%' + @p_keywords + '%'
				or	reff_approval_category_code like '%' + @p_keywords + '%'
				or	reff_approval_category_name like '%' + @p_keywords + '%'
				or	case is_active
						when '1' then 'Yes'
						else 'No'
					end like '%' + @p_keywords + '%'
			) ;

	select		code
				,approval_name
				,reff_approval_category_code
				,reff_approval_category_name
				,case is_active
					 when '1' then 'Yes'
					 else 'No'
				 end 'is_active'
				,@rows_count 'rowcount'
	from		master_approval
	where		(
					code like '%' + @p_keywords + '%'
					or	approval_name like '%' + @p_keywords + '%'
					or	reff_approval_category_code like '%' + @p_keywords + '%'
					or	reff_approval_category_name like '%' + @p_keywords + '%'
					or	case is_active
							when '1' then 'Yes'
							else 'No'
						end like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then approval_name
													 when 3 then reff_approval_category_code
													 when 4 then reff_approval_category_name
													 when 5 then is_active
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then code
													   when 2 then approval_name
													   when 3 then reff_approval_category_code
													   when 4 then reff_approval_category_name
													   when 5 then is_active
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
