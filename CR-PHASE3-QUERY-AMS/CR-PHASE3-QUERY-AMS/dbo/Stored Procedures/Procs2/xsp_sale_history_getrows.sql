CREATE PROCEDURE dbo.xsp_sale_history_getrows
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
	from	dbo.sale_history sl
	where	sl.branch_code = case @p_branch_code
								when '' then sl.branch_code
								else @p_branch_code
							end
	and		location_code	  = case @p_location_code
										when '' then location_code
										else @p_location_code
									end
	and		status = case @p_status
						when 'ALL' then status
						else @p_status
					end
	and		sl.company_code = @p_company_code
	and		(
				sl.code										 like '%' + @p_keywords + '%'
				or	convert(nvarchar(30), sale_date, 103)	 like '%' + @p_keywords + '%'
				or	sl.branch_name							 like '%' + @p_keywords + '%'
				or	buyer									 like '%' + @p_keywords + '%'
				or	sale_amount								 like '%' + @p_keywords + '%'
				or	status									 like '%' + @p_keywords + '%'
			) ;

	select	sl.code
			,sl.company_code
			,convert(nvarchar(30), sale_date, 103) 'sale_date'
			,sl.description
			,sl.branch_code
			,sl.branch_name
			,location_code
			,buyer
			,buyer_phone_no
			,sale_amount
			,remark
			,status
			,@rows_count 'rowcount'
	from	dbo.sale_history sl
	where	sl.branch_code = case @p_branch_code
								when '' then sl.branch_code
								else @p_branch_code
							end
	and		location_code	  = case @p_location_code
										when '' then location_code
										else @p_location_code
									end
	and		status = case @p_status
						when 'ALL' then status
						else @p_status
					end
	and		sl.company_code = @p_company_code
	and		(
				sl.code										 like '%' + @p_keywords + '%'
				or	convert(nvarchar(30), sale_date, 103)	 like '%' + @p_keywords + '%'
				or	sl.branch_name							 like '%' + @p_keywords + '%'
				or	buyer									 like '%' + @p_keywords + '%'
				or	sale_amount								 like '%' + @p_keywords + '%'
				or	status									 like '%' + @p_keywords + '%'
			)
	order by	
			case
				when @p_sort_by = 'asc' then case @p_order_by
												when 1 then sl.code
												when 2 then cast(sale_date as sql_variant)
												when 3 then sl.branch_name
												when 4 then buyer
												when 5 then cast(sale_amount as sql_variant)
												when 6 then status
											end
				end asc
			,case
			when @p_sort_by = 'desc' then case @p_order_by
												when 1 then sl.code
												when 2 then cast(sale_date as sql_variant)
												when 3 then sl.branch_name
												when 4 then buyer
												when 5 then cast(sale_amount as sql_variant)
												when 6 then status
										   end
			end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
