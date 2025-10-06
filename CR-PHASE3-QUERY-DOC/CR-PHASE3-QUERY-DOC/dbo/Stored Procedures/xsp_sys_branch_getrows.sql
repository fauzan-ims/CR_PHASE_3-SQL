CREATE PROCEDURE dbo.xsp_sys_branch_getrows
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
	from	sys_branch
	where	(
				branch_code like '%' + @p_keywords + '%'
				or	branch_name like '%' + @p_keywords + '%'
				or	case is_custody_branch
						when '1' then 'YES'
						else 'NO'
					end like '%' + @p_keywords + '%'
				or	custody_branch_code like '%' + @p_keywords + '%'
				or	custody_branch_name like '%' + @p_keywords + '%'
			) ;

	select		branch_code
				,branch_name
				,case is_custody_branch
					 when '1' then 'YES'
					 else 'NO'
				 end 'is_custody_branch'
				,custody_branch_code
				,custody_branch_name
				,@rows_count 'rowcount'
	from		sys_branch
	where		(
					branch_code like '%' + @p_keywords + '%'
					or	branch_name like '%' + @p_keywords + '%'
					or	case is_custody_branch
							when '1' then 'YES'
							else 'NO'
						end like '%' + @p_keywords + '%'
					or	custody_branch_code like '%' + @p_keywords + '%'
					or	custody_branch_name like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then branch_code
													 when 2 then branch_name
													 when 3 then is_custody_branch
													 when 4 then custody_branch_code
													 when 5 then custody_branch_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then branch_code
													   when 2 then branch_name
													   when 3 then is_custody_branch
													   when 4 then custody_branch_code
													   when 5 then custody_branch_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
