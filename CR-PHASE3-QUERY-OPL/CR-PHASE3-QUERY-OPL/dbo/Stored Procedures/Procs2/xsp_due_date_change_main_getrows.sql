CREATE PROCEDURE dbo.xsp_due_date_change_main_getrows
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_branch_code	  nvarchar(50)
	,@p_change_status nvarchar(10)
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
	from	due_date_change_main ddcm
			inner join dbo.agreement_main am on (am.agreement_no = ddcm.agreement_no)
	where	ddcm.branch_code	   = case @p_branch_code
										 when 'ALL' then ddcm.branch_code
										 else @p_branch_code
									 end
			and ddcm.change_status = case @p_change_status
										 when 'ALL' then ddcm.change_status
										 else @p_change_status
									 end
			and (
					ddcm.code										like '%' + @p_keywords + '%'
					or	ddcm.branch_name							like '%' + @p_keywords + '%'
					or	am.agreement_external_no					like '%' + @p_keywords + '%'
					or	am.client_name								like '%' + @p_keywords + '%'
					or	convert(varchar(30), ddcm.change_date, 103)	like '%' + @p_keywords + '%'
					or	ddcm.change_amount							like '%' + @p_keywords + '%'
					or	ddcm.change_status							like '%' + @p_keywords + '%'
				) ;

	select		ddcm.code
				,ddcm.branch_name
				,am.agreement_external_no 
				,am.client_name
				,convert(varchar(30), ddcm.change_date, 103) 'change_date'
				,ddcm.change_amount
				,ddcm.change_status
				,@rows_count 'rowcount'
	from		due_date_change_main ddcm
				inner join dbo.agreement_main am on (am.agreement_no = ddcm.agreement_no)
	where		ddcm.branch_code	   = case @p_branch_code
												when 'ALL' then ddcm.branch_code
												else @p_branch_code
											end
				and ddcm.change_status = case @p_change_status
												when 'ALL' then ddcm.change_status
												else @p_change_status
											end
				and (
						ddcm.code										like '%' + @p_keywords + '%'
						or	ddcm.branch_name							like '%' + @p_keywords + '%'
						or	am.agreement_external_no					like '%' + @p_keywords + '%'
						or	am.client_name								like '%' + @p_keywords + '%'
						or	convert(varchar(30), ddcm.change_date, 103)	like '%' + @p_keywords + '%'
						or	ddcm.change_amount							like '%' + @p_keywords + '%'
						or	ddcm.change_status							like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then ddcm.code
														when 2 then ddcm.branch_name
														when 3 then am.agreement_external_no
														when 4 then cast(ddcm.change_date as sql_variant)
														when 5 then cast(ddcm.change_amount as sql_variant)
														when 6 then ddcm.change_status
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then ddcm.code
														when 2 then ddcm.branch_name
														when 3 then am.agreement_external_no
														when 4 then cast(ddcm.change_date as sql_variant)
														when 5 then cast(ddcm.change_amount as sql_variant)
														when 6 then ddcm.change_status
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;
