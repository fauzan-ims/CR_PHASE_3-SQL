CREATE PROCEDURE [dbo].[xsp_application_recomendation_getrows]
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_application_no nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	application_recomendation ar
			inner join dbo.master_workflow mw on (mw.code = ar.level_status)
	where	application_no = @p_application_no
			and (
					mw.description																	like '%' + @p_keywords + '%'
					or	format(cast(recomendation_date as datetime),'dd/MM/yyyy HH:mm:ss','en-us')	like '%' + @p_keywords + '%'
					or	recomendation_result														like '%' + @p_keywords + '%'
					or	employee_name																like '%' + @p_keywords + '%'
					or	remarks																		like '%' + @p_keywords + '%'
					or	cycle																		like '%' + @p_keywords + '%'
				) ;

	select		id
				,mw.description	'level_status'
				,format(cast(recomendation_date as datetime),'dd/MM/yyyy HH:mm:ss','en-us') 'recomendation_date'		
				,recomendation_result	
				,employee_name			
				,remarks		
				,cycle			
				,@rows_count 'rowcount'
	from		application_recomendation ar
				inner join dbo.master_workflow mw on (mw.code = ar.level_status)
	where		application_no = @p_application_no
				and (
						mw.description																	like '%' + @p_keywords + '%'
						or	format(cast(recomendation_date as datetime),'dd/MM/yyyy HH:mm:ss','en-us')	like '%' + @p_keywords + '%'
						or	recomendation_result														like '%' + @p_keywords + '%'
						or	employee_name																like '%' + @p_keywords + '%'
						or	remarks																		like '%' + @p_keywords + '%'
						or	cycle																		like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then format(cast(recomendation_date as datetime),'dd/MM/yyyy HH:mm:ss','en-us')	
														when 2 then recomendation_result	
														when 3 then level_status
														when 4 then employee_name			
														when 5 then remarks		
														when 6 then cast(cycle as sql_variant)	
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then format(cast(recomendation_date as datetime),'dd/MM/yyyy HH:mm:ss','en-us')	
														when 2 then recomendation_result	
														when 3 then level_status
														when 4 then employee_name			
														when 5 then remarks		
														when 6 then cast(cycle as sql_variant)	
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;  
end ;

