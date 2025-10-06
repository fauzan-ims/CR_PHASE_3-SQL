CREATE PROCEDURE dbo.xsp_maintenance_history_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)	= ''
	,@p_location_code	nvarchar(50)	= ''
	,@p_status			nvarchar(20)
	,@p_company_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.maintenance_history mn
			inner join dbo.asset ast on mn.asset_code = ast.code
	where	mn.branch_code		  = case @p_branch_code
										when '' then mn.branch_code
										else @p_branch_code
									end
	and		mn.location_code	  = case @p_location_code
										when '' then mn.location_code
										else @p_location_code
									end
	and		mn.status = case @p_status
						when 'ALL' then mn.status
						else @p_status
					end
	and		mn.company_code = @p_company_code
	and		(
				mn.code											 like '%' + @p_keywords + '%'
				or	mn.asset_code								 like '%' + @p_keywords + '%'
				or	mn.category_name							 like '%' + @p_keywords + '%'
				or	convert(nvarchar(30),transaction_date, 103)  like '%' + @p_keywords + '%'
				or	mn.branch_name								 like '%' + @p_keywords + '%'
				or	transaction_amount							 like '%' + @p_keywords + '%'
				or	mn.status									 like '%' + @p_keywords + '%'
			) ;
			
	select		mn.code
				,mn.company_code
				,asset_code
				,convert(nvarchar(30), transaction_date, 103) 'transaction_date'
				,ast.barcode
				,mn.category_name
				,transaction_amount
				,mn.branch_code
				,mn.branch_name
				,mn.location_code
				,mn.requestor_code
				,mn.division_code
				,mn.division_name
				,mn.department_code
				,mn.department_name
				,mn.sub_department_code
				,mn.sub_department_name
				,unit_code
				,unit_name
				,mn.status
				,remark
				,@rows_count 'rowcount'
	from		dbo.maintenance_history mn
				inner join dbo.asset ast on mn.asset_code = ast.code
	where		mn.branch_code		  = case @p_branch_code
											when '' then mn.branch_code
											else @p_branch_code
										end
	and			mn.location_code	  = case @p_location_code
											when '' then mn.location_code
											else @p_location_code
										end
	and			mn.status = case @p_status
							when 'ALL' then mn.status
							else @p_status
						end
	and			mn.company_code = @p_company_code
	and			(
					mn.code											 like '%' + @p_keywords + '%'
					or	mn.asset_code								 like '%' + @p_keywords + '%'
					or	mn.category_name							 like '%' + @p_keywords + '%'
					or	convert(nvarchar(30),transaction_date, 103)  like '%' + @p_keywords + '%'
					or	mn.branch_name								 like '%' + @p_keywords + '%'
					or	transaction_amount							 like '%' + @p_keywords + '%'
					or	mn.status									 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then mn.code
													 when 2 then mn.asset_code
													 when 3 then mn.category_name
													 when 4 then cast(transaction_date as sql_variant)
													 when 5 then mn.branch_name
													 when 6 then cast(transaction_amount as sql_variant)
													 when 7 then mn.status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													  when 1 then mn.code
													  when 2 then mn.asset_code
													  when 3 then mn.category_name
													  when 4 then cast(transaction_date as sql_variant)
													  when 5 then mn.branch_name
													  when 6 then cast(transaction_amount as sql_variant)
													  when 7 then mn.status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
