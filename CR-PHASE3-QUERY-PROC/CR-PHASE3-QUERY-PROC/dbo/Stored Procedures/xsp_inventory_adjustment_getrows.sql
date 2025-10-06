CREATE PROCEDURE dbo.xsp_inventory_adjustment_getrows
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	,@p_company_code nvarchar(50)
	,@p_status		 nvarchar(50)
	,@p_branch_code	 nvarchar(50)
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
	from	inventory_adjustment
	where	company_code	= @p_company_code
			and status		= case @p_status
								  when 'ALL' then status
								  else @p_status
							  end
			and branch_code = case @p_branch_code
								  when 'ALL' then branch_code
								  else @p_branch_code
							  end
			and
			(
				code											like '%' + @p_keywords + '%'
				or	branch_name									like '%' + @p_keywords + '%'
				or	convert(nvarchar(50), adjustment_date, 103) like '%' + @p_keywords + '%'
				or	status										like '%' + @p_keywords + '%'
				or	reason										like '%' + @p_keywords + '%'
			) ;

	select		code
				,company_code
				,convert(nvarchar(50), adjustment_date, 103) 'adjustment_date'
				,branch_code
				,branch_name
				,division_code
				,division_name
				,department_code
				,department_name
				,sub_department_code
				,sub_department_name
				,units_code
				,units_name
				,reason
				,remark
				,status
				,@rows_count								 'rowcount'
	from		inventory_adjustment
	where		company_code	= @p_company_code
				and status		= case @p_status
									  when 'ALL' then status
									  else @p_status
								  end
				and branch_code = case @p_branch_code
									  when 'ALL' then branch_code
									  else @p_branch_code
								  end
				and
				(
					code											like '%' + @p_keywords + '%'
					or	branch_name									like '%' + @p_keywords + '%'
					or	convert(nvarchar(50), adjustment_date, 103) like '%' + @p_keywords + '%'
					or	status										like '%' + @p_keywords + '%'
					or	reason										like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then branch_name
													 when 3 then cast(adjustment_date as sql_variant)
													 when 4 then status
													 when 5 then reason
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then code
													   when 2 then branch_name
													   when 3 then cast(adjustment_date as sql_variant)
													   when 4 then status
													   when 5 then reason
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
