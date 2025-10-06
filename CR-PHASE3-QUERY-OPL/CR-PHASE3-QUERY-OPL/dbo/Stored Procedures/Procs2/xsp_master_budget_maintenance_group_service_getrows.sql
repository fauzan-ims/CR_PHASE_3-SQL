--created by, Rian at 11/05/2023	

CREATE PROCEDURE [dbo].[xsp_master_budget_maintenance_group_service_getrows]
(
	@p_keywords					nvarchar(50)
	,@p_pagenumber				int
	,@p_rowspage				int
	,@p_order_by				int
	,@p_sort_by					nvarchar(5)
	--
	,@p_budget_maintenance_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select		@rows_count = count(1)
	from		dbo.master_budget_maintenance_group_service bmgs
	inner join	dbo.master_budget_maintenance_group bmg on (bmg.code = bmgs.budget_maintenance_group_code)
	where		bmgs.budget_maintenance_code = @p_budget_maintenance_code
				and (
						bmgs.budget_maintenance_group_code	like '%' + @p_keywords + '%'
						or	bmgs.budget_maintenance_code	like '%' + @p_keywords + '%'
						or	bmgs.group_code					like '%' + @p_keywords + '%'
						or	bmgs.service_description		like '%' + @p_keywords + '%'
						or	bmgs.unit_qty					like '%' + @p_keywords + '%'
						or	bmgs.unit_cost					like '%' + @p_keywords + '%'
						or	bmgs.labor_cost					like '%' + @p_keywords + '%'
						or	bmgs.replacement_cycle			like '%' + @p_keywords + '%'
						or	bmgs.replacement_type			like '%' + @p_keywords + '%'
						or	bmgs.total_cost					like '%' + @p_keywords + '%'
						or	bmg.group_description			like '%' + @p_keywords + '%'
					) ;

	select		bmgs.id
				,bmgs.budget_maintenance_code
				,bmgs.budget_maintenance_group_code
				,bmgs.group_code
				,bmgs.service_code
				,bmgs.service_description
				,bmgs.unit_qty
				,bmgs.unit_cost
				,bmgs.labor_cost
				,bmgs.replacement_cycle
				,bmgs.replacement_type
				,bmgs.total_cost
				,bmg.group_description 
				,@rows_count 'rowcount'
	from		dbo.master_budget_maintenance_group_service bmgs
	inner join	dbo.master_budget_maintenance_group bmg on (bmg.code = bmgs.budget_maintenance_group_code)
	where		bmgs.budget_maintenance_code = @p_budget_maintenance_code
				and (
						bmgs.budget_maintenance_group_code	like '%' + @p_keywords + '%'
						or	bmgs.budget_maintenance_code	like '%' + @p_keywords + '%'
						or	bmgs.group_code					like '%' + @p_keywords + '%'
						or	bmgs.service_description		like '%' + @p_keywords + '%'
						or	bmgs.unit_qty					like '%' + @p_keywords + '%'
						or	bmgs.unit_cost					like '%' + @p_keywords + '%'
						or	bmgs.labor_cost					like '%' + @p_keywords + '%'
						or	bmgs.replacement_cycle			like '%' + @p_keywords + '%'
						or	bmgs.replacement_type			like '%' + @p_keywords + '%'
						or	bmgs.total_cost					like '%' + @p_keywords + '%'
						or	bmg.group_description			like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then bmg.group_description
													 when 2 then bmgs.service_description
													 when 3 then cast(bmgs.unit_qty as sql_variant)
													 when 4 then cast(bmgs.unit_cost as sql_variant)
													 when 5 then cast(bmgs.labor_cost as sql_variant)
													 when 6 then bmgs.replacement_cycle
													 when 7 then cast(bmgs.replacement_type as sql_variant)
													 when 8 then cast(bmgs.total_cost as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then bmg.group_description
													 when 2 then bmgs.service_description
													 when 3 then cast(bmgs.unit_qty as sql_variant)
													 when 4 then cast(bmgs.unit_cost as sql_variant)
													 when 5 then cast(bmgs.labor_cost as sql_variant)
													 when 6 then bmgs.replacement_cycle
													 when 7 then cast(bmgs.replacement_type as sql_variant)
													 when 8 then cast(bmgs.total_cost as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
