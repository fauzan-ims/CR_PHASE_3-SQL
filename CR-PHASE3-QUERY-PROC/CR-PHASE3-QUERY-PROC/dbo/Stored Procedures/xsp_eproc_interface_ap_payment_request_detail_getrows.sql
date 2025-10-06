CREATE procedure dbo.xsp_eproc_interface_ap_payment_request_detail_getrows
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
	from	eproc_interface_ap_payment_request_detail
	where	(
				id								like '%' + @p_keywords + '%'
				or	payment_request_code		like '%' + @p_keywords + '%'
				or	invoice_register_code		like '%' + @p_keywords + '%'
				or	payment_amount				like '%' + @p_keywords + '%'
				or	case is_paid
						when '1' then 'YES'
						else 'NO'
					end							like '%' + @p_keywords + '%'
				or	ppn							like '%' + @p_keywords + '%'
				or	pph							like '%' + @p_keywords + '%'
				or	fee							like '%' + @p_keywords + '%'
			) ;

	select		id
				,payment_request_code
				,invoice_register_code
				,payment_amount
				,case is_paid
					 when '1' then 'YES'
					 else 'NO'
				 end 'is_paid'
				,ppn
				,pph
				,fee
				,@rows_count 'rowcount'
	from		eproc_interface_ap_payment_request_detail
	where		(
					id								like '%' + @p_keywords + '%'
					or	payment_request_code		like '%' + @p_keywords + '%'
					or	invoice_register_code		like '%' + @p_keywords + '%'
					or	payment_amount				like '%' + @p_keywords + '%'
					or	case is_paid
							when '1' then 'YES'
							else 'NO'
						end							like '%' + @p_keywords + '%'
					or	ppn							like '%' + @p_keywords + '%'
					or	pph							like '%' + @p_keywords + '%'
					or	fee							like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then payment_request_code
													 when 2 then invoice_register_code
													 when 3 then is_paid
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then payment_request_code
													   when 2 then invoice_register_code
													   when 3 then is_paid
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
