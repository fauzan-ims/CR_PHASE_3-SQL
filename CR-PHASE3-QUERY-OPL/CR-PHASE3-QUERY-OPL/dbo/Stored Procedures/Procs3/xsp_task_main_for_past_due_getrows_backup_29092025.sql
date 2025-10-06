CREATE PROCEDURE dbo.xsp_task_main_for_past_due_getrows_backup_29092025
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_collector_code nvarchar(50) = ''
	,@p_desk_status	   nvarchar(50) = ''
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	task_main								 tmn
			left join dbo.deskcoll_main				 dmn on (dmn.id = tmn.deskcoll_main_id)
	where	tmn.desk_status		 = case @p_desk_status
									   when 'all' then tmn.desk_status
									   else @p_desk_status
								   end
			and isnull(tmn.promise_date,'') = ''
			and
			(
				convert(varchar(30), tmn.task_date, 103)		like '%' + @p_keywords + '%'
				or	tmn.client_name								like '%' + @p_keywords + '%'
				or	tmn.deskcoll_staff_name						like '%' + @p_keywords + '%'
				or	posting_by_name								like '%' + @p_keywords + '%'
				or	convert(varchar(30), dmn.posting_date, 103)	like '%' + @p_keywords + '%'
				or	convert(varchar(30), isnull(dmn.result_promise_date,tmn.promise_date), 103)	like '%' + @p_keywords + '%'
				or	dmn.desk_status								like '%' + @p_keywords + '%'
			)

	select		tmn.id
				,convert(varchar(30), tmn.task_date, 103)			'task_date'
				,tmn.client_name
				,tmn.deskcoll_staff_name							'marketing_name'
				,posting_by_name	
				,convert(varchar(30), dmn.posting_date, 103)		'posting_date'
				,isnull(dmn.result_promise_date,tmn.promise_date)	'promise_date'
				,tmn.desk_status
				,@rows_count										 'rowcount'
				--
				,''	 'agreement_external_no'
				,''		'installment_due_date'
				,0	'overdue_period'
				,0	'overdue_days'
				,0	'rental'
				,''	'agreement_no'
				,'' 'section_head'

	from		task_main								 tmn
				left join dbo.deskcoll_main				 dmn on (dmn.id = tmn.deskcoll_main_id)
	where		tmn.desk_status		 = case @p_desk_status
										   when 'all' then tmn.desk_status
										   else @p_desk_status
									   end
				and isnull(tmn.promise_date,'') = ''
				and
				(
					convert(varchar(30), tmn.task_date, 103)		like '%' + @p_keywords + '%'
					or	tmn.client_name								like '%' + @p_keywords + '%'
					or	tmn.deskcoll_staff_name						like '%' + @p_keywords + '%'
					or	posting_by_name								like '%' + @p_keywords + '%'
					or	convert(varchar(30), dmn.posting_date, 103)	like '%' + @p_keywords + '%'
					or	convert(varchar(30), isnull(dmn.result_promise_date,tmn.promise_date), 103)	like '%' + @p_keywords + '%'
					or	dmn.desk_status								like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then tmn.client_name
													 when 2 then cast(tmn.task_date as sql_variant)
													 when 3 then tmn.deskcoll_staff_name
													 when 4 then posting_by_name
													 when 5 then cast(dmn.posting_date as sql_variant)
													 when 6 then cast(isnull(dmn.result_promise_date,tmn.promise_date) as sql_variant)
													 when 7 then dmn.desk_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then tmn.client_name
													 when 2 then cast(tmn.task_date as sql_variant)
													 when 3 then tmn.deskcoll_staff_name
													 when 4 then posting_by_name
													 when 5 then cast(dmn.posting_date as sql_variant)
													 when 6 then cast(isnull(dmn.result_promise_date,tmn.promise_date) as sql_variant)
													 when 7 then dmn.desk_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
