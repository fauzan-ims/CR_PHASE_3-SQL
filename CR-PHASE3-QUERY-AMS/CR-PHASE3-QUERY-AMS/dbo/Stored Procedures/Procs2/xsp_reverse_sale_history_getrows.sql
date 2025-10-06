CREATE procedure dbo.xsp_reverse_sale_history_getrows
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	---
	,@p_company_code  nvarchar(50)
	,@p_status		  nvarchar(25)
	,@p_branch_code	  nvarchar(50) = ''
	,@p_location_code nvarchar(50) = ''
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	reverse_sale_history
	where	branch_code		  = case @p_branch_code
									when '' then branch_code
									else @p_branch_code
								end
			and location_code = case @p_location_code
									when '' then location_code
									else @p_location_code
								end
			and status		  = case @p_status
									when 'ALL' then status
									else @p_status
								end
			and company_code  = @p_company_code
			and (
					code like '%' + @p_keywords + '%'
					or	convert(nvarchar(30), sale_date, 103) like '%' + @p_keywords + '%'
					or	branch_name like '%' + @p_keywords + '%'
					or	location_name like '%' + @p_keywords + '%'
					or	buyer like '%' + @p_keywords + '%'
					or	sale_amount like '%' + @p_keywords + '%'
					or	status like '%' + @p_keywords + '%'
				) ;

	select		code
				,company_code
				,sale_code
				,convert(nvarchar(30), reverse_sale_date, 103) 'sale_date'
				,description
				,branch_code
				,branch_name
				,location_code
				,location_name
				,to_bank_account_no
				,to_bank_account_name
				,to_bank_code
				,to_bank_name
				,buyer
				,buyer_phone_no
				,sale_amount
				,remark
				,status
				,@rows_count								   'rowcount'
	from		reverse_sale_history
	where		branch_code		  = case @p_branch_code
										when '' then branch_code
										else @p_branch_code
									end
				and location_code = case @p_location_code
										when '' then location_code
										else @p_location_code
									end
				and status		  = case @p_status
										when 'ALL' then status
										else @p_status
									end
				and company_code  = @p_company_code
				and (
						code like '%' + @p_keywords + '%'
						or	convert(nvarchar(30), sale_date, 103) like '%' + @p_keywords + '%'
						or	branch_name like '%' + @p_keywords + '%'
						or	location_name like '%' + @p_keywords + '%'
						or	buyer like '%' + @p_keywords + '%'
						or	sale_amount like '%' + @p_keywords + '%'
						or	status like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then cast(sale_date as sql_variant)
													 when 3 then branch_name
													 when 4 then location_name
													 when 5 then buyer
													 when 6 then sale_amount
													 when 7 then status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then code
													   when 2 then cast(sale_date as sql_variant)
													   when 3 then branch_name
													   when 4 then location_name
													   when 5 then buyer
													   when 6 then sale_amount
													   when 7 then status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
