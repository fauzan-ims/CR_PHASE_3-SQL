CREATE PROCEDURE dbo.xsp_task_history_getrows
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
	from	task_history
	where	(
				id										like '%' + @p_keywords + '%'
				or	task_date							like '%' + @p_keywords + '%'
				or	desk_collector_code					like '%' + @p_keywords + '%'
				or	deskcoll_main_id					like '%' + @p_keywords + '%'
				or	field_collector_code				like '%' + @p_keywords + '%'
				--or	fieldcoll_main_id					like '%' + @p_keywords + '%'
				or	agreement_no						like '%' + @p_keywords + '%'
				or	last_paid_installment_no			like '%' + @p_keywords + '%'
				or	installment_due_date				like '%' + @p_keywords + '%'
				or	overdue_period						like '%' + @p_keywords + '%'
				or	overdue_days						like '%' + @p_keywords + '%'
				or	overdue_penalty_amount				like '%' + @p_keywords + '%'
				or	overdue_installment_amount			like '%' + @p_keywords + '%'
				or	outstanding_installment_amount		like '%' + @p_keywords + '%'
				or	outstanding_deposit_amount			like '%' + @p_keywords + '%'
			) ;
			 
		select		id
					,task_date
					,desk_collector_code
					,deskcoll_main_id
					,field_collector_code
					--,fieldcoll_main_id
					,agreement_no
					,last_paid_installment_no
					,installment_due_date
					,overdue_period
					,overdue_days
					,overdue_penalty_amount
					,overdue_installment_amount
					,outstanding_installment_amount
					,outstanding_deposit_amount
					,@rows_count 'rowcount'
		from		task_history
		where		(
						id										like '%' + @p_keywords + '%'
						or	task_date							like '%' + @p_keywords + '%'
						or	desk_collector_code					like '%' + @p_keywords + '%'
						or	deskcoll_main_id					like '%' + @p_keywords + '%'
						or	field_collector_code				like '%' + @p_keywords + '%'
						--or	fieldcoll_main_id					like '%' + @p_keywords + '%'
						or	agreement_no						like '%' + @p_keywords + '%'
						or	last_paid_installment_no			like '%' + @p_keywords + '%'
						or	installment_due_date				like '%' + @p_keywords + '%'
						or	overdue_period						like '%' + @p_keywords + '%'
						or	overdue_days						like '%' + @p_keywords + '%'
						or	overdue_penalty_amount				like '%' + @p_keywords + '%'
						or	overdue_installment_amount			like '%' + @p_keywords + '%'
						or	outstanding_installment_amount		like '%' + @p_keywords + '%'
						or	outstanding_deposit_amount			like '%' + @p_keywords + '%'
					) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then desk_collector_code
													when 2 then field_collector_code
													when 3 then agreement_no
													when 4 then last_paid_installment_no
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then desk_collector_code
													when 2 then field_collector_code
													when 3 then agreement_no
													when 4 then last_paid_installment_no
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;
