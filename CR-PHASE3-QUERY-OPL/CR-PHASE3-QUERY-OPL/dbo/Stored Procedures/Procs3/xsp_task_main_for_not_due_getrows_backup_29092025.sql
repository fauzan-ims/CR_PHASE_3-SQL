CREATE PROCEDURE dbo.xsp_task_main_for_not_due_getrows_backup_29092025
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_collector_code nvarchar(50)
	,@p_desk_status	   nvarchar(50) = ''
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	task_main								 tmn
			--left join dbo.agreement_main			 amn on (amn.agreement_no = tmn.agreement_no)
			left join dbo.deskcoll_main				 dmn on (dmn.id = tmn.deskcoll_main_id)
			--left join ifinsys.dbo.sys_employee_main sem on sem.code = amn.marketing_code
			--left join ifinsys.dbo.sys_employee_main	 sem2 on sem2.code = sem.head_emp_code
			--inner join dbo.master_collector mc on (mc.code = tmn.desk_collector_code)
	--		outer apply
	--(
	--	select	sum(aa.lease_rounded_amount) 'rental'
	--	from	dbo.agreement_asset aa
	--	where	aa.agreement_no = amn.agreement_no
	--)												 asset
	outer apply
(
	select	top 1
			a.marketing_name
			,sem2.name
	from	dbo.agreement_main						a
			left join ifinsys.dbo.sys_employee_main sem on sem.code	  = a.marketing_code
			left join ifinsys.dbo.sys_employee_main sem2 on sem2.code = sem.head_emp_code
	where	a.client_no = tmn.client_no
	order by a.agreement_date
) marketing
	where --tmn.desk_collector_code		= @p_collector_code		
		--AND
			tmn.desk_status		 = case @p_desk_status
									   when 'ALL' then tmn.desk_status
									   else @p_desk_status
								   end
			--and tmn.overdue_days <= 0
			and isnull(tmn.promise_date,'') <> ''
			and
			(
				tmn.client_name									like '%' + @p_keywords + '%'
				or	convert(varchar(30), tmn.task_date, 103)	like '%' + @p_keywords + '%'
				or	tmn.desk_status								like '%' + @p_keywords + '%'
				or	marketing.marketing_name							like '%' + @p_keywords + '%'
				or	marketing.name									like '%' + @p_keywords + '%'
			) ;

	select		tmn.id
				--,amn.agreement_external_no
				,tmn.client_name
				,convert(varchar(30), tmn.task_date, 103)			 'task_date'
				,convert(varchar(30), tmn.installment_due_date, 103) 'installment_due_date'
				--,asset.rental
				,tmn.overdue_days
				,tmn.desk_status
				--,amn.agreement_no
				,marketing.name											 'section_head'
				,marketing.marketing_name
				,convert(varchar(30), dmn.posting_date, 103)			 'posting_date'
				,convert(varchar(30), dmn.result_promise_date, 103)			 'promise_date'
				--,amn.is_recourse
				,@rows_count										 'rowcount'
	from		task_main								 tmn
				--left join dbo.agreement_main			 amn on (amn.agreement_no = tmn.agreement_no)
				left join dbo.deskcoll_main				 dmn on (dmn.id = tmn.deskcoll_main_id)
				--left join ifinsys.dbo.sys_employee_main sem on sem.code = amn.marketing_code
				--left join ifinsys.dbo.sys_employee_main	 sem2 on sem2.code = sem.head_emp_code
	--			outer apply
	--(
	--	select	sum(aa.lease_rounded_amount) 'rental'
	--	from	dbo.agreement_asset aa
	--	where	aa.agreement_no = amn.agreement_no
	--)													 asset
	outer apply
(
	select	top 1
			a.marketing_name
			,sem2.name
	from	dbo.agreement_main						a
			left join ifinsys.dbo.sys_employee_main sem on sem.code	  = a.marketing_code
			left join ifinsys.dbo.sys_employee_main sem2 on sem2.code = sem.head_emp_code
	where	a.client_no = tmn.client_no
	order by a.agreement_date
) marketing
	where --tmn.desk_collector_code		= @p_collector_code		
		--and	
				tmn.desk_status		 = case @p_desk_status
										   when 'ALL' then tmn.desk_status
										   else @p_desk_status
									   end
				--and (tmn.deskcoll_main_id is null or dmn.result_code is null)
				--and tmn.overdue_days <= 0
				and isnull(tmn.promise_date,'') <> ''
				and
				(
					tmn.client_name									like '%' + @p_keywords + '%'
					or	convert(varchar(30), tmn.task_date, 103)	like '%' + @p_keywords + '%'
					or	tmn.desk_status								like '%' + @p_keywords + '%'
					or	marketing.marketing_name							like '%' + @p_keywords + '%'
					or	marketing.name									like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then tmn.client_name
													 when 2 then cast(tmn.task_date as sql_variant)
													 when 3 then marketing.marketing_name
													 when 4 then marketing.name
													 when 5 then cast(tmn.task_date as sql_variant)
													 when 6 then tmn.desk_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then tmn.client_name
													 when 2 then cast(tmn.task_date as sql_variant)
													 when 3 then marketing.marketing_name
													 when 4 then marketing.name
													 when 5 then cast(tmn.task_date as sql_variant)
													 when 6 then tmn.desk_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
