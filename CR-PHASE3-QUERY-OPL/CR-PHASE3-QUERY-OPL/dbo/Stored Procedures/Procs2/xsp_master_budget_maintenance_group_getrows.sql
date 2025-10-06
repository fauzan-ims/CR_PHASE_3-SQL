--created by, Rian at 11/05/2023	

CREATE PROCEDURE dbo.xsp_master_budget_maintenance_group_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	--
	,@p_budget_maintenance_code	   nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.master_budget_maintenance_group bmg
	where	bmg.budget_maintenance_code = @p_budget_maintenance_code
			and (
					bmg.code						like '%' + @p_keywords + '%'
					or bmg.budget_maintenance_code	like '%' + @p_keywords + '%'
					or bmg.group_code				like '%' + @p_keywords + '%'
					or bmg.group_description		like '%' + @p_keywords + '%'
					or bmg.probability_pct			like '%' + @p_keywords + '%'
				) ;

	select		bmg.code
			   ,bmg.budget_maintenance_code
			   ,bmg.group_code
			   ,bmg.group_description
			   ,bmg.probability_pct
				,@rows_count 'rowcount'
	from		dbo.master_budget_maintenance_group bmg
	where		bmg.budget_maintenance_code = @p_budget_maintenance_code
			and (
					bmg.code						like '%' + @p_keywords + '%'
					or bmg.budget_maintenance_code	like '%' + @p_keywords + '%'
					or bmg.group_code				like '%' + @p_keywords + '%'
					or bmg.group_description		like '%' + @p_keywords + '%'
					or bmg.probability_pct			like '%' + @p_keywords + '%'
				) 
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then bmg.group_description
													 when 2 then cast(bmg.probability_pct as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then bmg.group_description
														when 2 then cast(bmg.probability_pct as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
