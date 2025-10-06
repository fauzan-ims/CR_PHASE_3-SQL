CREATE PROCEDURE [dbo].[xsp_ap_invoice_registration_getrows]
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	,@p_company_code nvarchar(50)
	,@p_status		 nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	ap_invoice_registration						  air
	where	air.company_code = @p_company_code
			and air.status	 = case @p_status
								   when 'ALL' then air.status
								   else @p_status
							   end
			and
			(
				air.code												like '%' + @p_keywords + '%'
				or	convert(varchar(30), air.invoice_date, 103)			like '%' + @p_keywords + '%'
				or	air.branch_name										like '%' + @p_keywords + '%'
				or	air.invoice_amount									like '%' + @p_keywords + '%'
				or	air.status											like '%' + @p_keywords + '%'
				or	air.file_invoice_no									like '%' + @p_keywords + '%'
				or	air.supplier_name									like '%' + @p_keywords + '%'
				or	air.remark											like '%' + @p_keywords + '%'
				or	air.unit_info										like '%' + @p_keywords + '%'
			) ;

	select		air.code
				,air.company_code
				,convert(varchar(30), air.invoice_date, 103)	 'invoice_date'
				,air.currency_code
				,air.supplier_code
				,air.supplier_name
				,air.file_invoice_no
				,air.ppn
				,air.pph
				,air.bill_type
				,air.discount
				,convert(varchar(30), air.due_date, 103)		 'due_date'
				,air.purchase_order_code
				,convert(varchar(30), air.tax_invoice_date, 103) 'tax_invoice_date'
				,air.branch_code
				,air.branch_name
				,air.division_code
				,air.division_name
				,air.department_code
				,air.department_name
				,air.to_bank_code
				,air.to_bank_account_name
				,air.to_bank_account_no
				,air.payment_by
				,air.status
				,air.remark
				,air.file_invoice_no
				,air.invoice_amount
				,air.unit_info
				,@rows_count									 'rowcount'
	from		ap_invoice_registration						  air
	where		air.company_code = @p_company_code
				and air.status	 = case @p_status
									   when 'ALL' then air.status
									   else @p_status
								   end
				and
				(
					air.code												like '%' + @p_keywords + '%'
					or	convert(varchar(30), air.invoice_date, 103)			like '%' + @p_keywords + '%'
					or	air.branch_name										like '%' + @p_keywords + '%'
					or	air.invoice_amount									like '%' + @p_keywords + '%'
					or	air.status											like '%' + @p_keywords + '%'
					or	air.file_invoice_no									like '%' + @p_keywords + '%'
					or	air.supplier_name									like '%' + @p_keywords + '%'
					or	air.remark											like '%' + @p_keywords + '%'
					or	air.unit_info										like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then air.code
													 when 2 then cast(air.invoice_date as sql_variant)
													 when 3 then air.supplier_name
													 when 4 then air.file_invoice_no
													 when 5 then cast(air.invoice_amount as sql_variant)
													 when 6 then air.remark
													 when 7 then air.status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then air.code
													   when 2 then cast(air.invoice_date as sql_variant)
													   when 3 then air.supplier_name
													   when 4 then air.file_invoice_no
													   when 5 then cast(air.invoice_amount as sql_variant)
													   when 6 then air.remark
													   when 7 then air.status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
