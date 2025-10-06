CREATE PROCEDURE [dbo].[xsp_application_log_getrows]
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
	from	application_log							al
			left join ifinsys.dbo.sys_employee_main sem on sem.code = al.mod_by
	where	application_no = @p_application_no
			and
			(
				format(cast(log_date as datetime), 'dd/MM/yyyy HH:mm:ss', 'en-us')	like '%' + @p_keywords + '%'
				or	log_description													like '%' + @p_keywords + '%'
				or	sem.name														like '%' + @p_keywords + '%'
				or	log_cycle														like '%' + @p_keywords + '%'
			) ;

	select		id
				,format(cast(log_date as datetime), 'dd/MM/yyyy HH:mm:ss', 'en-us') 'log_date'
				,log_description
				,al.mod_by
				,log_cycle
				,case 
					when al.mod_by = 'job' then al.mod_by
					else sem.name
				end 'process_by'
				,@rows_count														'rowcount'
	from		application_log							al
				left join ifinsys.dbo.sys_employee_main sem on sem.code = al.mod_by
	where		application_no = @p_application_no
				and
				(
					format(cast(log_date as datetime), 'dd/MM/yyyy HH:mm:ss', 'en-us')	like '%' + @p_keywords + '%'
					or	log_description													like '%' + @p_keywords + '%'
					or	sem.name														like '%' + @p_keywords + '%'
					or	log_cycle														like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then cast(log_date as datetime)
													 when 2 then log_description
													 when 3 then sem.name
													 when 4 then cast(log_cycle as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then cast(log_date as datetime)
													   when 2 then log_description
													   when 3 then sem.name
													   when 4 then cast(log_cycle as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
