CREATE PROCEDURE dbo.xsp_task_main_for_past_due_getrows_backup_25092025
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
			left join dbo.agreement_main			 amn on (amn.agreement_no = tmn.agreement_no)
			left join dbo.deskcoll_main				 dmn on (dmn.id = tmn.deskcoll_main_id)
			left join ifinsys.dbo.sys_employee_main sem on sem.code = amn.marketing_code
			left join ifinsys.dbo.sys_employee_main	 sem2 on sem2.code = sem.head_emp_code
			outer apply
	(
		select	sum(aa.lease_rounded_amount) 'rental'
		from	dbo.agreement_asset aa
		where	aa.agreement_no = amn.agreement_no
	)												 asset
	where --tmn.desk_collector_code = @p_collector_code
		--and
			tmn.desk_status		 = case @p_desk_status
									   when 'ALL' then tmn.desk_status
									   else @p_desk_status
								   end
			--and tmn.overdue_days > 0
			and isnull(tmn.promise_date,'') = ''
			and
			(
				convert(varchar(30), tmn.task_date, 103)	like '%' + @p_keywords + '%'
				or	amn.client_name							like '%' + @p_keywords + '%'
				or	tmn.desk_status							like '%' + @p_keywords + '%'
				or	amn.marketing_name						like '%' + @p_keywords + '%'
				or	sem2.name								like '%' + @p_keywords + '%'
			) ;

	select		tmn.id
				,amn.agreement_external_no
				,convert(varchar(30), tmn.task_date, 103)			 'task_date'
				,convert(varchar(30), tmn.installment_due_date, 103) 'installment_due_date'
				,tmn.overdue_period
				,tmn.overdue_days
				,amn.client_name
				,asset.rental
				,tmn.desk_status
				,amn.agreement_no
				,sem2.name											 'section_head'
				,amn.marketing_name
				--,amn.is_recourse
				,convert(varchar(30), dmn.posting_date, 103)			 'posting_date'
				,@rows_count										 'rowcount'
	from		task_main								 tmn
				left join dbo.agreement_main			 amn on (amn.agreement_no = tmn.agreement_no)
				left join dbo.deskcoll_main				 dmn on (dmn.id = tmn.deskcoll_main_id)
				left join ifinsys.dbo.sys_employee_main sem on sem.code = amn.marketing_code
				left join ifinsys.dbo.sys_employee_main	 sem2 on sem2.code = sem.head_emp_code
				outer apply
	(
		select	sum(aa.lease_rounded_amount) 'rental'
		from	dbo.agreement_asset aa
		where	aa.agreement_no = amn.agreement_no
	)													 asset
	where --tmn.desk_collector_code = @p_collector_code
		--and 
				tmn.desk_status		 = case @p_desk_status
										   when 'ALL' then tmn.desk_status
										   else @p_desk_status
									   end
				--and tmn.overdue_days > 0
				and isnull(tmn.promise_date,'') = ''
				and
				(
					convert(varchar(30), tmn.task_date, 103)	like '%' + @p_keywords + '%'
					or	amn.client_name							like '%' + @p_keywords + '%'
					or	tmn.desk_status							like '%' + @p_keywords + '%'
					or	amn.marketing_name						like '%' + @p_keywords + '%'
					or	sem2.name								like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then amn.client_name
													 when 2 then cast(tmn.task_date as sql_variant)
													 when 3 then amn.marketing_name
													 when 4 then sem2.name
													 when 5 then cast(tmn.task_date as sql_variant)
													 when 6 then tmn.desk_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then amn.client_name
													 when 2 then cast(tmn.task_date as sql_variant)
													 when 3 then amn.marketing_name
													 when 4 then sem2.name
													 when 5 then cast(tmn.task_date as sql_variant)
													 when 6 then tmn.desk_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
