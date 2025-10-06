CREATE PROCEDURE dbo.xsp_sys_eod_task_list_getrows
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
	from	sys_eod_task_list
	where	(
				code							like '%' + @p_keywords + '%'
				or	name						like '%' + @p_keywords + '%'
				or	sp_name						like '%' + @p_keywords + '%'
				or	order_no					like '%' + @p_keywords + '%'
				or	case is_active
						when '1' then 'Yes'
						else 'No'
					end							like '%' + @p_keywords + '%'
			) ;


		select		code
					,name
					,sp_name
					,order_no
					,case is_active
						 when '1' then 'Yes'
						 else 'No'
					 end as 'is_active'
					,@rows_count as 'rowcount'
		from		sys_eod_task_list
		where		(
						code							like '%' + @p_keywords + '%'
						or	name						like '%' + @p_keywords + '%'
						or	sp_name						like '%' + @p_keywords + '%'
						or	order_no					like '%' + @p_keywords + '%'
						or	case is_active
								when '1' then 'Yes'
								else 'No'
							end							like '%' + @p_keywords + '%'
					)

		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then name
													when 2 then sp_name
													when 3 then cast(order_no as sql_variant)
													when 4 then is_active
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then name
													when 2 then sp_name
													when 3 then cast(order_no as sql_variant)
													when 4 then is_active
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;
