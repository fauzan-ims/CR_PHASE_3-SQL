CREATE PROCEDURE dbo.xsp_master_collector_getrows
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
	from	master_collector mc
			left join dbo.master_collector mc1 on (mc1.code = mc.supervisor_collector_code)
	where	(
				mc.collector_name							like '%' + @p_keywords + '%'
				or	mc.collector_emp_name					like '%' + @p_keywords + '%'
				or	mc.supervisor_collector_code			like '%' + @p_keywords + '%'
				or	mc.max_load_agreement					like '%' + @p_keywords + '%'
				or	mc.max_load_daily_agreement				like '%' + @p_keywords + '%'
				or	mc1.collector_name						like '%' + @p_keywords + '%'
				or	case mc.is_active
						when '1' then 'Yes'
						else 'No'
					end										like '%' + @p_keywords + '%'
			) ;
			 
		select		mc.code
					,mc.collector_name
					,mc.collector_emp_name
					,mc.supervisor_collector_code
					,mc1.collector_name 'supervisor_name'
					,mc.max_load_agreement
					,mc.max_load_daily_agreement
					,case mc.is_active
						 when '1' then 'Yes'
						 else 'No'
					 end 'is_active'
					,@rows_count 'rowcount'
		from	master_collector mc
				left join dbo.master_collector mc1 on (mc1.code = mc.supervisor_collector_code)
		where	(
						mc.collector_name					like '%' + @p_keywords + '%'
					or	mc.collector_emp_name				like '%' + @p_keywords + '%'
					or	mc1.collector_name					LIKE '%' + @p_keywords + '%'
					or	mc.max_load_agreement				like '%' + @p_keywords + '%'
					or	mc.max_load_daily_agreement			like '%' + @p_keywords + '%'
					or	mc1.collector_name					like '%' + @p_keywords + '%'
					or	case mc.is_active
							when '1' then 'Yes'
							else 'No'
						end									LIKE '%' + @p_keywords + '%'
				)  
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then mc.collector_name
													when 2 then mc1.collector_emp_name
													when 3 then mc1.collector_name
													when 4 then cast(mc.max_load_agreement as sql_variant)
													when 5 then	cast(mc.max_load_daily_agreement as sql_variant)
													when 6 then	mc.is_active
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then mc.collector_name
													when 2 then mc1.collector_emp_name
													when 3 then mc1.collector_name
													when 4 then cast(mc.max_load_agreement as sql_variant)
													when 5 then	cast(mc.max_load_daily_agreement as sql_variant)
													when 6 then	mc.is_active
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
	 
end ;
