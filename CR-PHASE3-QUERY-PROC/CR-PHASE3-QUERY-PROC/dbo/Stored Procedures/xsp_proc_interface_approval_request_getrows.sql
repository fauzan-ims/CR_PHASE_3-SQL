CREATE PROCEDURE dbo.xsp_proc_interface_approval_request_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_branch_code nvarchar(50)
	,@p_status		nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
				and value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;

	select	@rows_count = count(1)
	from	dbo.proc_interface_approval_request liar
	where	liar.branch_code		= case @p_branch_code
										  when 'ALL' then liar.branch_code
										  else @p_branch_code
									  end
			and liar.job_status = case @p_status
										  when 'ALL' then liar.job_status
										  else @p_status
									  end
			and (
					liar.code												like '%' + @p_keywords + '%'
					or	liar.branch_name									like '%' + @p_keywords + '%'
					or	convert(varchar(30), liar.request_date, 103)		like '%' + @p_keywords + '%'
					or	liar.request_amount									like '%' + @p_keywords + '%'
					or	liar.reff_no										like '%' + @p_keywords + '%'
					or	liar.reff_name										like '%' + @p_keywords + '%'
					or	liar.request_remarks								like '%' + @p_keywords + '%'
					or	convert(varchar(30), liar.mod_date, 103)			like '%' + @p_keywords + '%'
					or	liar.job_status										like '%' + @p_keywords + '%'
				) ;

	select		liar.code
				,liar.branch_name
				,convert(varchar(30), liar.request_date, 103) 'request_date'
				,liar.request_amount
				,liar.reff_no 'reff_no'
				,liar.reff_name
				,liar.request_remarks
				,convert(varchar(30), liar.mod_date, 103) 'mod_date'
				--,liar.approval_status 'request_status'
				,liar.job_status
				,@rows_count 'rowcount'
	from		dbo.proc_interface_approval_request liar
	where		liar.branch_code		= case @p_branch_code
												when 'ALL' then liar.branch_code
												else @p_branch_code
											end
				and liar.job_status = case @p_status
												when 'ALL' then liar.job_status
												else @p_status
											end
				and (
						liar.code												like '%' + @p_keywords + '%'
						or	liar.branch_name									like '%' + @p_keywords + '%'
						or	convert(varchar(30), liar.request_date, 103)		like '%' + @p_keywords + '%'
						or	liar.request_amount									like '%' + @p_keywords + '%'
						or	liar.reff_no										like '%' + @p_keywords + '%'
						or	liar.reff_name										like '%' + @p_keywords + '%'
						or	liar.request_remarks								like '%' + @p_keywords + '%'
						or	convert(varchar(30), liar.mod_date, 103)			like '%' + @p_keywords + '%'
						or	liar.job_status										like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then liar.code
														when 2 then liar.branch_name
														when 3 then cast(liar.request_date as sql_variant)
														when 4 then reff_no + liar.reff_name
														when 5 then liar.request_remarks
														when 6 then liar.request_amount
														when 7 then cast(liar.mod_date as sql_variant)
														when 8 then liar.job_status
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then liar.code
														when 2 then liar.branch_name
														when 3 then cast(liar.request_date as sql_variant)
														when 4 then reff_no + liar.reff_name
														when 5 then liar.request_remarks
														when 6 then liar.request_amount
														when 7 then cast(liar.mod_date as sql_variant)
														when 8 then liar.job_status
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;



