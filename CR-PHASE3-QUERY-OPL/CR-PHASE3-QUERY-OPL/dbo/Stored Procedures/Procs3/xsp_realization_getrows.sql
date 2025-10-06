CREATE PROCEDURE dbo.xsp_realization_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_branch_code nvarchar(50)
	,@p_status		nvarchar(15) = 'ALL'
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
	from	realization rz
			inner join application_main am on (am.application_no = rz.application_no)
			inner join dbo.client_main cm on (cm.code = am.client_code)
	where	rz.branch_code = case @p_branch_code
							  when 'ALL' then rz.branch_code
							  else @p_branch_code
						  end
			and rz.status	= case @p_status
							  when 'ALL' then rz.status
							  else @p_status
						  end
			and (
					rz.application_no						like '%' + @p_keywords + '%'
					or	cm.client_name						like '%' + @p_keywords + '%'
					or	rz.branch_name						like '%' + @p_keywords + '%'
					or	convert(nvarchar(15), rz.date, 103)	like '%' + @p_keywords + '%'
					or	rz.remark							like '%' + @p_keywords + '%'
					or	rz.status							like '%' + @p_keywords + '%'
					or	am.application_external_no			like '%' + @p_keywords + '%'
					or	rz.agreement_external_no			like '%' + @p_keywords + '%'
				) ;

	select		rz.code
				,rz.application_no
				,cm.client_name
				,rz.branch_name
				,convert(nvarchar(15), rz.date, 103) 'date'
				,rz.remark
				,rz.status
				,am.application_external_no
				,rz.agreement_external_no
				,@rows_count 'rowcount'
	from		realization rz
				inner join application_main am on (am.application_no = rz.application_no)
				inner join dbo.client_main cm on (cm.code = am.client_code)
	where		rz.branch_code = case @p_branch_code
								  when 'ALL' then rz.branch_code
								  else @p_branch_code
							  end
				and rz.status	= case @p_status
								  when 'ALL' then rz.status
								  else @p_status
							  end
				and (
						rz.application_no						like '%' + @p_keywords + '%'
						or	cm.client_name						like '%' + @p_keywords + '%'
						or	rz.branch_name						like '%' + @p_keywords + '%'
						or	convert(nvarchar(15), rz.date, 103)	like '%' + @p_keywords + '%'
						or	rz.remark							like '%' + @p_keywords + '%'
						or	rz.status							like '%' + @p_keywords + '%'
						or	am.application_external_no			like '%' + @p_keywords + '%'
						or	rz.agreement_external_no			like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then am.application_external_no + cm.client_name
													 when 2 then rz.branch_name
													 when 3 then cast(rz.date as sql_variant)
													 when 4 then rz.agreement_external_no
													 when 5 then rz.remark
													 when 6 then rz.status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then am.application_external_no + cm.client_name
													   when 2 then rz.branch_name
													   when 3 then cast(rz.date as sql_variant)
													   when 4 then rz.agreement_external_no
													   when 5 then rz.remark
													   when 6 then rz.status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
