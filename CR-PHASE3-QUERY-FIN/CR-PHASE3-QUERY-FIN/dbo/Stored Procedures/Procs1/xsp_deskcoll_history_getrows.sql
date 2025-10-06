CREATE PROCEDURE [dbo].[xsp_deskcoll_history_getrows]
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_client_no  nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.deskcoll_history a
	left join dbo.master_deskcoll_result b on a.result_code = b.code
	where	client_no = @p_client_no
			and
			(
				remarks like '%' + @p_keywords + '%'
				or	b.result_name like '%' + @p_keywords + '%'
				or	convert(varchar(30), task_date, 103) like '%' + @p_keywords + '%'
				or	convert(varchar(30), posting_date, 103) like '%' + @p_keywords + '%'
				or	convert(varchar(30), promise_date, 103) like '%' + @p_keywords + '%'
				or	convert(varchar(30), next_fu_date, 103) like '%' + @p_keywords + '%'
			) ;

	select		a.id
				,convert(varchar(30), task_date, 103)	 'task_date'
				,convert(varchar(30), posting_date, 103) 'posting_date'
				,convert(varchar(30), promise_date, 103) 'promise_date'
				,convert(varchar(30), next_fu_date, 103) 'next_fu_date'
				,b.result_name
				,a.remarks
				,a.RESULT_CODE+' '+b.RESULT_NAME 'result_name_detail'
				,sem.posting_by
				,@rows_count							 'rowcount'
	from		dbo.deskcoll_history a
	left join dbo.master_deskcoll_result b on a.result_code = b.code
	outer apply 
	(
		select	name 'posting_by' 
		from	ifinsys.dbo.sys_employee_main
		where	a.cre_by = code
	)sem
	where		client_no = @p_client_no
				and
				(
					remarks like '%' + @p_keywords + '%'
					or	b.result_name like '%' + @p_keywords + '%'
					or	convert(varchar(30), task_date, 103) like '%' + @p_keywords + '%'
					or	convert(varchar(30), posting_date, 103) like '%' + @p_keywords + '%'
					or	convert(varchar(30), promise_date, 103) like '%' + @p_keywords + '%'
					or	convert(varchar(30), next_fu_date, 103) like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then cast(task_date as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then cast(task_date as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
