CREATE PROCEDURE dbo.xsp_task_main_getrows
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
	from	task_main tmn
			left join dbo.agreement_main amn on (amn.agreement_no = tmn.agreement_no)
	where	(
				tmn.id													like '%' + @p_keywords + '%'
				or	amn.agreement_external_no							like '%' + @p_keywords + '%'
				or	convert(varchar(30), tmn.task_date, 103)			like '%' + @p_keywords + '%'
				or	convert(varchar(30), tmn.installment_due_date, 103) like '%' + @p_keywords + '%'
				or	tmn.overdue_period									like '%' + @p_keywords + '%'
				or	tmn.overdue_days									like '%' + @p_keywords + '%'
				or	amn.client_name										like '%' + @p_keywords + '%'
				or	tmn.desk_status										like '%' + @p_keywords + '%'
			) ;

		select		tmn.id
					,amn.agreement_external_no	
					,convert(varchar(30), tmn.task_date, 103) 'task_date'				
					,convert(varchar(30), tmn.installment_due_date, 103) 'installment_due_date'	
					,tmn.overdue_period			
					,tmn.overdue_days	
					,amn.client_name
					,tmn.desk_status 
					,@rows_count 'rowcount'
		from		task_main tmn
					left join dbo.agreement_main amn on (amn.agreement_no = tmn.agreement_no)
		where		(
						tmn.id													like '%' + @p_keywords + '%'
						or	amn.agreement_external_no							like '%' + @p_keywords + '%'
						or	convert(varchar(30), tmn.task_date, 103)			like '%' + @p_keywords + '%'
						or	convert(varchar(30), tmn.installment_due_date, 103) like '%' + @p_keywords + '%'
						or	tmn.overdue_period									like '%' + @p_keywords + '%'
						or	tmn.overdue_days									like '%' + @p_keywords + '%'
						or	amn.client_name										like '%' + @p_keywords + '%'
						or	tmn.desk_status										like '%' + @p_keywords + '%'
					)

	order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then amn.agreement_external_no							
													when 2 then cast(tmn.task_date as sql_variant)			
													when 3 then cast(tmn.installment_due_date as sql_variant) 
													when 4 then cast(tmn.overdue_period as sql_variant)									
													when 5 then	cast(tmn.overdue_days as sql_variant)	
													when 6 then amn.client_name	
													when 7 then tmn.desk_status	
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then amn.agreement_external_no							
														when 2 then cast(tmn.task_date as sql_variant)			
														when 3 then cast(tmn.installment_due_date as sql_variant) 
														when 4 then cast(tmn.overdue_period as sql_variant)									
														when 5 then	cast(tmn.overdue_days as sql_variant)	
														when 6 then amn.client_name	
														when 7 then tmn.desk_status	
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;
