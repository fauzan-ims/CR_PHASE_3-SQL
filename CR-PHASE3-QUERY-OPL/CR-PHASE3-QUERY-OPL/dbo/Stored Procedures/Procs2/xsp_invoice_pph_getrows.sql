CREATE procedure dbo.xsp_invoice_pph_getrows
(
	@p_keywords			  nvarchar(50)
	,@p_pagenumber		  int
	,@p_rowspage		  int
	,@p_order_by		  int
	,@p_sort_by			  nvarchar(5)
	,@p_settlement_status nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	invoice_pph
	where	settlement_status = case @p_settlement_status
									when 'ALL' then settlement_status
									else @p_settlement_status
								end
			and (
					invoice_no				like '%' + @p_keywords + '%'
					or	settlement_type		like '%' + @p_keywords + '%'
					or	settlement_status	like '%' + @p_keywords + '%'
					or	file_name			like '%' + @p_keywords + '%'
					or	payment_reff_no		like '%' + @p_keywords + '%'
					or	payment_reff_date	like '%' + @p_keywords + '%'
				) ;

	select		id
				,invoice_no
				,settlement_type
				,settlement_status
				,file_name
				,payment_reff_no
				,payment_reff_date
				,@rows_count 'rowcount'
	from		invoice_pph
	where		settlement_status = case @p_settlement_status
										when 'ALL' then settlement_status
										else @p_settlement_status
									end
				and (
						invoice_no				like '%' + @p_keywords + '%'
						or	settlement_type		like '%' + @p_keywords + '%'
						or	settlement_status	like '%' + @p_keywords + '%'
		
						or	file_name			like '%' + @p_keywords + '%'
						or	payment_reff_no		like '%' + @p_keywords + '%'
						or	payment_reff_date	like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then invoice_no
													   when 2 then settlement_type
													   when 3 then settlement_status
													   when 4 then file_name
													   when 5 then payment_reff_no
													   when 6 then payment_reff_date
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then invoice_no
													   when 2 then settlement_type
													   when 3 then settlement_status
													   when 4 then file_name
													   when 5 then payment_reff_no
													   when 6 then payment_reff_date
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
