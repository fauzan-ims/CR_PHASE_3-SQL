CREATE PROCEDURE dbo.xsp_sys_eod_task_list_log_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_from_date  datetime
	,@p_to_date	   datetime
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	sys_eod_task_list_log setll
			inner join dbo.sys_eod_task_list setl on (setl.code = setll.eod_code)
	where	cast(setll.eod_date as date)
					between cast(@p_from_date as date) and cast( @p_to_date as date) 
			and (
					setl.name									like '%' + @p_keywords + '%'
					or	convert(varchar, setll.start_time, 20)  like '%' + @p_keywords + '%'
					or	convert(varchar, setll.end_time, 20) 	like '%' + @p_keywords + '%'
					or	setll.status							like '%' + @p_keywords + '%'
					or	setll.reason							like '%' + @p_keywords + '%'
				) ;

		select		 setl.name 'process'
					,convert(varchar, setll.start_time, 20) 'start_time'
					,convert(varchar, setll.end_time, 20) 'end_time'
					,setll.status
					,setll.reason
					,@rows_count as 'rowcount'
		from		sys_eod_task_list_log setll
					inner join dbo.sys_eod_task_list setl on (setl.code = setll.eod_code)
		where	cast(setll.eod_date as date)
					between cast(@p_from_date as date) and cast( @p_to_date as date) 
					and (
							setl.name									like '%' + @p_keywords + '%'
							or	convert(varchar, setll.start_time, 20)  like '%' + @p_keywords + '%'
							or	convert(varchar, setll.end_time, 20) 	like '%' + @p_keywords + '%'
							or	setll.status							like '%' + @p_keywords + '%'
							or	setll.reason							like '%' + @p_keywords + '%'
						)
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then setl.name
													when 2 then convert(varchar, setll.start_time, 20)  
													when 3 then convert(varchar, setll.end_time, 20) 	
													when 4 then setll.status
													when 5 then setll.reason
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then setl.name
														when 2 then convert(varchar, setll.start_time, 20)  
														when 3 then convert(varchar, setll.end_time, 20) 	
														when 4 then setll.status
														when 5 then setll.reason
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;

end ;
