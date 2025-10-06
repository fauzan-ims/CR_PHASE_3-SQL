CREATE procedure dbo.xsp_eproc_interface_ap_payment_request_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	eproc_interface_ap_payment_request
	where	(
				id											like '%' + @p_keywords + '%'
				or	code									like '%' + @p_keywords + '%'
				or	invoice_date							like '%' + @p_keywords + '%'
				or	currency_code							like '%' + @p_keywords + '%'
				or	supplier_code							like '%' + @p_keywords + '%'
				or	invoice_amount							like '%' + @p_keywords + '%'
				or	case is_another_invoice
						when '1' then 'YES'
						else 'NO'
					end										like '%' + @p_keywords + '%'
				or	file_invoice_no							like '%' + @p_keywords + '%'
				or	ppn										like '%' + @p_keywords + '%'
				or	pph										like '%' + @p_keywords + '%'
				or	fee										like '%' + @p_keywords + '%'
				or	bill_type								like '%' + @p_keywords + '%'
				or	discount								like '%' + @p_keywords + '%'
				or	due_date								like '%' + @p_keywords + '%'
				or	tax_invoice_date						like '%' + @p_keywords + '%'
				or	purchase_order_code						like '%' + @p_keywords + '%'
				or	branch_code								like '%' + @p_keywords + '%'
				or	branch_name								like '%' + @p_keywords + '%'
				or	to_bank_code							like '%' + @p_keywords + '%'
				or	to_bank_account_name					like '%' + @p_keywords + '%'
				or	to_bank_account_no						like '%' + @p_keywords + '%'
				or	payment_by								like '%' + @p_keywords + '%'
				or	status									like '%' + @p_keywords + '%'
				or	remark									like '%' + @p_keywords + '%'
			) ;

	select		id
				,code
				,invoice_date
				,currency_code
				,supplier_code
				,invoice_amount
				,case is_another_invoice
					 when '1' then 'YES'
					 else 'NO'
				 end 'is_another_invoice'
				,file_invoice_no
				,ppn
				,pph
				,fee
				,bill_type
				,discount
				,due_date
				,tax_invoice_date
				,purchase_order_code
				,branch_code
				,branch_name
				,to_bank_code
				,to_bank_account_name
				,to_bank_account_no
				,payment_by
				,status
				,remark
				,@rows_count 'rowcount'
	from		eproc_interface_ap_payment_request
	where		(
					id											like '%' + @p_keywords + '%'
					or	code									like '%' + @p_keywords + '%'
					or	invoice_date							like '%' + @p_keywords + '%'
					or	currency_code							like '%' + @p_keywords + '%'
					or	supplier_code							like '%' + @p_keywords + '%'
					or	invoice_amount							like '%' + @p_keywords + '%'
					or	case is_another_invoice
							when '1' then 'YES'
							else 'NO'
						end										like '%' + @p_keywords + '%'
					or	file_invoice_no							like '%' + @p_keywords + '%'
					or	ppn										like '%' + @p_keywords + '%'
					or	pph										like '%' + @p_keywords + '%'
					or	fee										like '%' + @p_keywords + '%'
					or	bill_type								like '%' + @p_keywords + '%'
					or	discount								like '%' + @p_keywords + '%'
					or	due_date								like '%' + @p_keywords + '%'
					or	tax_invoice_date						like '%' + @p_keywords + '%'
					or	purchase_order_code						like '%' + @p_keywords + '%'
					or	branch_code								like '%' + @p_keywords + '%'
					or	branch_name								like '%' + @p_keywords + '%'
					or	to_bank_code							like '%' + @p_keywords + '%'
					or	to_bank_account_name					like '%' + @p_keywords + '%'
					or	to_bank_account_no						like '%' + @p_keywords + '%'
					or	payment_by								like '%' + @p_keywords + '%'
					or	status									like '%' + @p_keywords + '%'
					or	remark									like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then currency_code
													 when 3 then supplier_code
													 when 4 then is_another_invoice
													 when 5 then file_invoice_no
													 when 6 then bill_type
													 when 7 then purchase_order_code
													 when 8 then branch_code
													 when 9 then branch_name
													 when 10 then to_bank_code
													 when 11 then to_bank_account_name
													 when 12 then to_bank_account_no
													 when 13 then payment_by
													 when 14 then status
													 when 15 then remark
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then code
													   when 2 then currency_code
													   when 3 then supplier_code
													   when 4 then is_another_invoice
													   when 5 then file_invoice_no
													   when 6 then bill_type
													   when 7 then purchase_order_code
													   when 8 then branch_code
													   when 9 then branch_name
													   when 10 then to_bank_code
													   when 11 then to_bank_account_name
													   when 12 then to_bank_account_no
													   when 13 then payment_by
													   when 14 then status
													   when 15 then remark
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
