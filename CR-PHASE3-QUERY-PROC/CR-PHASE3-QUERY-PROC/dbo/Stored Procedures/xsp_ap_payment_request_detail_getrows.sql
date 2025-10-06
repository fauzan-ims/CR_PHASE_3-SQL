CREATE PROCEDURE dbo.xsp_ap_payment_request_detail_getrows
(
	@p_keywords				 nvarchar(50)
	,@p_pagenumber			 int
	,@p_rowspage			 int
	,@p_order_by			 int
	,@p_sort_by				 nvarchar(5)
	,@p_payment_request_code nvarchar(50)
	,@p_company_code		 nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	ap_payment_request_detail prd
			left join dbo.ap_payment_request apr on (prd.payment_request_code = apr.code)
			inner join dbo.ap_invoice_registration ir on (ir.code = prd.invoice_register_code) 
	where	prd.payment_request_code = @p_payment_request_code
			and prd.company_code = @p_company_code
			and (
					prd.payment_request_code						like '%' + @p_keywords + '%'
					or	convert(varchar(50), apr.invoice_date, 103) like '%' + @p_keywords + '%'
					or	convert(varchar(50), apr.due_date, 103)     like '%' + @p_keywords + '%'
					or	prd.unit_price								like '%' + @p_keywords + '%'
					or	apr.ppn										like '%' + @p_keywords + '%'
					or	prd.pph										like '%' + @p_keywords + '%'
					or	prd.payment_amount							like '%' + @p_keywords + '%'
					or	prd.discount								like '%' + @p_keywords + '%'
					or	ir.remark									like '%' + @p_keywords + '%'
				) ;

	select		prd.id
				,prd.payment_request_code
				,prd.invoice_register_code
				,case prd.is_paid
					 when '1' then 'Yes'
					 else 'No'
				 end 'is_paid'
				,prd.ppn
				,prd.pph
				,prd.fee
				,prd.payment_amount 'total_amount'
				,convert(varchar(50), apr.invoice_date, 103) 'invoice_date'
				,convert(varchar(50),ir.due_date, 103) 'due_date'
				,prd.unit_price
				,prd.discount
				,ir.remark 'payment_remark'
				,ir.file_name
				,ir.paths 'file_path'
				,@rows_count 'rowcount'
	from		ap_payment_request_detail prd
				left join dbo.ap_payment_request apr on (prd.payment_request_code = apr.code)
				inner join dbo.ap_invoice_registration ir on (ir.code = prd.invoice_register_code) 
	where		prd.payment_request_code = @p_payment_request_code
				and prd.company_code = @p_company_code
				and (
						prd.payment_request_code						like '%' + @p_keywords + '%'
						or	convert(varchar(50), apr.invoice_date, 103) like '%' + @p_keywords + '%'
						or	convert(varchar(50), apr.due_date, 103)     like '%' + @p_keywords + '%'
						or	prd.unit_price								like '%' + @p_keywords + '%'
						or	apr.ppn										like '%' + @p_keywords + '%'
						or	prd.pph										like '%' + @p_keywords + '%'
						or	prd.payment_amount							like '%' + @p_keywords + '%'
						or	prd.discount								like '%' + @p_keywords + '%'
						or	ir.remark									like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then prd.invoice_register_code
													 when 2 then cast(apr.invoice_date + apr.due_date as sql_variant)
													 when 3 then cast(prd.unit_price as sql_variant)
													 when 4 then cast(prd.discount as sql_variant)
													 when 5 then cast(prd.ppn as sql_variant)
													 when 6 then cast(prd.pph as sql_variant)
													 when 7 then cast(prd.payment_amount as sql_variant)
													 when 8 then cast(ir.remark as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then prd.invoice_register_code
													 when 2 then cast(apr.invoice_date + apr.due_date as sql_variant)
													 when 3 then cast(prd.unit_price as sql_variant)
													 when 4 then cast(prd.discount as sql_variant)
													 when 5 then cast(prd.ppn as sql_variant)
													 when 6 then cast(prd.pph as sql_variant)
													 when 7 then cast(prd.payment_amount as sql_variant)
													 when 8 then cast(ir.remark as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
