CREATE PROCEDURE dbo.xsp_fin_interface_cashier_received_request_detail_getrows
(
	@p_keywords						   nvarchar(50)
	,@p_pagenumber					   int
	,@p_rowspage					   int
	,@p_order_by					   int
	,@p_sort_by						   nvarchar(5)
	,@p_cashier_received_request_code  nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.fin_interface_cashier_received_request_detail prd
			left join dbo.agreement_main am on (am.agreement_no = prd.agreement_no)
			left join dbo.journal_gl_link jgl on (jgl.code = prd.gl_link_code)
	where	prd.cashier_received_request_code = @p_cashier_received_request_code
			and	(
					prd.branch_name					like '%' + @p_keywords + '%'
					or	jgl.gl_link_name			like '%' + @p_keywords + '%'
					or	am.agreement_external_no	like '%' + @p_keywords + '%'
					or	am.client_name				like '%' + @p_keywords + '%'
					or	orig_currency_code			like '%' + @p_keywords + '%'
					or	orig_amount					like '%' + @p_keywords + '%'
					or	division_name				like '%' + @p_keywords + '%'
					or	department_name				like '%' + @p_keywords + '%'
					or	remarks						like '%' + @p_keywords + '%'
				) ;

	select		id
				,cashier_received_request_code
				,prd.branch_name
				,jgl.gl_link_name
				,am.agreement_external_no
				,am.client_name
				,prd.facility_name
				,orig_currency_code
				,orig_amount
				,division_name
				,department_name
				,remarks
				,@rows_count 'rowcount'
	from		fin_interface_cashier_received_request_detail prd
				left join dbo.agreement_main am on (am.agreement_no = prd.agreement_no)
				left join dbo.journal_gl_link jgl on (jgl.code = prd.gl_link_code)
	where		prd.cashier_received_request_code = @p_cashier_received_request_code
				and	(
						prd.branch_name					like '%' + @p_keywords + '%'
						or	gl_link_code				like '%' + @p_keywords + '%'
						or	am.agreement_external_no	like '%' + @p_keywords + '%'
						or	am.client_name				like '%' + @p_keywords + '%'
						or	orig_currency_code			like '%' + @p_keywords + '%'
						or	orig_amount					like '%' + @p_keywords + '%'
						or	division_name				like '%' + @p_keywords + '%'
						or	department_name				like '%' + @p_keywords + '%'
						or	remarks						like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then gl_link_code
													 when 2 then prd.branch_name
													 when 3 then am.agreement_external_no + am.client_name
													 when 4 then prd.orig_currency_code + cast(prd.orig_amount as nvarchar(50))
													 when 5 then division_name
													 when 6 then department_name
													 when 7 then remarks
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then gl_link_code
													   when 2 then prd.branch_name
													   when 3 then am.agreement_external_no + am.client_name
													   when 4 then prd.orig_currency_code + cast(prd.orig_amount as nvarchar(50))
													   when 5 then division_name
													   when 6 then department_name
													   when 7 then remarks
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
