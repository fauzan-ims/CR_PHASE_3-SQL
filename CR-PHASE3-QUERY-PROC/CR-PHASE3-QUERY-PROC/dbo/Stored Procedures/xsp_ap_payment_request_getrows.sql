CREATE PROCEDURE dbo.xsp_ap_payment_request_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_status		nvarchar(50)
	,@p_branch_code nvarchar(50)
	,@p_company_code	nvarchar(50)
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
	from	ap_payment_request pr
			left join dbo.purchase_order po on (po.code						   = pr.purchase_order_code)
	where	pr.status		   = case @p_status
									 when 'ALL' then pr.status
									 else @p_status
								 end
			and pr.branch_code = case @p_branch_code
									 when 'ALL' then pr.branch_code
									 else @p_branch_code
								 end
			and pr.company_code = @p_company_code
			and (
					pr.code												like '%' + @p_keywords + '%'
					or	convert(varchar(30), pr.invoice_date, 103)		like '%' + @p_keywords + '%'
					or	pr.supplier_name								like '%' + @p_keywords + '%'
					or	convert(varchar(30), pr.invoice_amount, 103)	like '%' + @p_keywords + '%'
					or	pr.status										like '%' + @p_keywords + '%'
					or	pr.remark										like '%' + @p_keywords + '%'
				) ;

	select		pr.code
				,convert(varchar(30), pr.invoice_date, 103) 'invoice_date'
				,pr.currency_code
				,pr.supplier_code
				,pr.supplier_name
				,pr.invoice_amount
				,pr.ppn
				,pr.pph
				,pr.fee
				,pr.discount
				,convert(varchar(30), pr.due_date, 103) 'due_date'
				,convert(varchar(30), pr.tax_invoice_date, 103) 'tax_invoice_date'
				,pr.branch_code
				,pr.branch_name
				,pr.to_bank_code
				,pr.to_bank_account_name
				,pr.to_bank_account_no
				,pr.payment_by
				,pr.status
				,pr.remark
				,@rows_count 'rowcount'
	from		ap_payment_request pr
				left join dbo.purchase_order po on (po.code						   = pr.purchase_order_code)
	where		pr.status		   = case @p_status
										 when 'ALL' then pr.status
										 else @p_status
									 end
				and pr.branch_code = case @p_branch_code
										 when 'ALL' then pr.branch_code
										 else @p_branch_code
									 end
				and pr.company_code = @p_company_code
				and (
						pr.code												like '%' + @p_keywords + '%'
						or	convert(varchar(30), pr.invoice_date, 103)		like '%' + @p_keywords + '%'
						or	pr.supplier_name								like '%' + @p_keywords + '%'
						or	convert(varchar(30), pr.invoice_amount, 103)	like '%' + @p_keywords + '%'
						or	pr.status										like '%' + @p_keywords + '%'
						or	pr.remark										like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then pr.code
													 when 2 then cast(pr.invoice_date as sql_variant)
													 when 3 then pr.supplier_name
													 when 4 then cast(pr.invoice_amount as sql_variant)
													 when 5 then pr.remark
													 when 6 then pr.status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													    when 1 then pr.code
														when 2 then cast(pr.invoice_date as sql_variant)
														when 3 then pr.supplier_name
														when 4 then cast(pr.invoice_amount as sql_variant)
														when 5 then pr.remark
														when 6 then pr.status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
