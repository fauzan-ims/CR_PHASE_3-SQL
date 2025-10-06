CREATE PROCEDURE dbo.xsp_procurement_request_verification_getrows
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	,@p_company_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	procurement_request pr
	where	pr.company_code = @p_company_code
			and pr.status	= 'ON VERIFIED'
			and (
					pr.code												like '%' + @p_keywords + '%'
					or	convert(varchar(30), pr.request_date, 103)		like '%' + @p_keywords + '%'
					or	pr.branch_name									like '%' + @p_keywords + '%'
					or	pr.requestor_name								like '%' + @p_keywords + '%'
					or	pr.status										like '%' + @p_keywords + '%'
					or	pr.remark										like '%' + @p_keywords + '%'
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
				,@rows_count 'rowcount'
				,pr.requestor_name
	from		procurement_request pr
	where		pr.company_code = @p_company_code
				and pr.status	= 'ON VERIFIED'
				and (

						pr.code												like '%' + @p_keywords + '%'
						or	convert(varchar(30), pr.request_date, 103)		like '%' + @p_keywords + '%'
						or	pr.branch_name									like '%' + @p_keywords + '%'
						or	pr.requestor_name								like '%' + @p_keywords + '%'
						or	pr.status										like '%' + @p_keywords + '%'
						or	pr.remark										like '%' + @p_keywords + '%'
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
