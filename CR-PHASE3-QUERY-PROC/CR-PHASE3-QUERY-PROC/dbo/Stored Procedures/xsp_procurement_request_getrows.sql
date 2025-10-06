CREATE PROCEDURE [dbo].[xsp_procurement_request_getrows]
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	--
	,@p_company_code nvarchar(50)
	,@p_status		 nvarchar(50)
	,@p_branch		 nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
				and value = @p_branch
	)
	begin
		set @p_branch = 'ALL' ;
	end ;

	select	@rows_count = count(1)
	from	procurement_request pr
	--outer apply 
	--( 
	--	select top 1 pri.specification
	--	from dbo.procurement_request_item pri 
	--	where pri.procurement_request_code = pr.code 
	--	and (pri.specification	like '%' + @p_keywords + '%')
	--) prt 
	where	pr.company_code	   = @p_company_code
			and pr.status	   = case @p_status
									 when 'ALL' then pr.status
									 else @p_status
								 end
			and pr.branch_code = case @p_branch
									 when 'ALL' then pr.branch_code
									 else @p_branch
								 end
			and (
					pr.code												like '%' + @p_keywords + '%'
					or	convert(varchar(30), pr.request_date, 103)		like '%' + @p_keywords + '%'
					or	pr.branch_name									like '%' + @p_keywords + '%'
					or	pr.requestor_name								like '%' + @p_keywords + '%'
					or	pr.status										like '%' + @p_keywords + '%'
					or	pr.remark										like '%' + @p_keywords + '%'
					or	pr.procurement_type								like '%' + @p_keywords + '%'
					--or	prt.specification								like '%' + @p_keywords + '%'
				) ;

	select		pr.code
				,pr.company_code
				,convert(varchar(30), pr.request_date, 103) 'request_date'
				,pr.requestor_code
				,pr.requirement_type
				,pr.branch_code
				,pr.branch_name
				,pr.division_code
				,pr.division_name
				,pr.department_code
				,pr.department_name
				,pr.status
				,pr.remark
				,pr.requestor_name
				,pr.procurement_type
				--,prt.specification
				,@rows_count 'rowcount'
	from		procurement_request pr
	--outer apply 
	--( 
	--	select top 1 pri.specification
	--	from dbo.procurement_request_item pri 
	--	where pri.procurement_request_code = pr.code 
	--	and (pri.specification	like '%' + @p_keywords + '%')
	--) prt
	where		pr.company_code	   = @p_company_code
				and pr.status	   = case @p_status
										 when 'ALL' then pr.status
										 else @p_status
									 end
				and pr.branch_code = case @p_branch
										 when 'ALL' then pr.branch_code
										 else @p_branch
									 end
				and (
						pr.code												like '%' + @p_keywords + '%'
						or	convert(varchar(30), pr.request_date, 103)		like '%' + @p_keywords + '%'
						or	pr.branch_name									like '%' + @p_keywords + '%'
						or	pr.requestor_name								like '%' + @p_keywords + '%'
						or	pr.status										like '%' + @p_keywords + '%'
						or	pr.remark										like '%' + @p_keywords + '%'
						or	pr.procurement_type								like '%' + @p_keywords + '%'
						--or	prt.specification								like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then pr.code
													 when 2 then pr.branch_name
													 when 3 then cast(pr.request_date as sql_variant)
													 when 4 then pr.requestor_name
													 when 5 then pr.remark
													 when 6 then pr.status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then pr.code
													 when 2 then pr.branch_name
													 when 3 then cast(pr.request_date as sql_variant)
													 when 4 then pr.requestor_name
													 when 5 then pr.remark
													 when 6 then pr.status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
