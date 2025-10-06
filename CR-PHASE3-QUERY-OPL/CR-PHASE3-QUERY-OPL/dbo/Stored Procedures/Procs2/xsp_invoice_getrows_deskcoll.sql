CREATE procedure dbo.xsp_invoice_getrows_deskcoll
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	--
	,@p_agreement_no nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	invoice inv
	where	exists ( select 1 from invoice_detail where invoice_no = inv.invoice_no and agreement_no = @p_agreement_no)
			and inv.invoice_status not in ('PAID', 'CANCEL') 
			and (
					inv.invoice_no										like '%' + @p_keywords + '%'
					or	inv.invoice_name								like '%' + @p_keywords + '%'
					or	convert(varchar(20), inv.invoice_date, 103)		like '%' + @p_keywords + '%'
					or	convert(varchar(20), inv.invoice_due_date, 103) like '%' + @p_keywords + '%'
					or	inv.total_amount								like '%' + @p_keywords + '%'
					or	inv.invoice_status								like '%' + @p_keywords + '%'
				) ;

	select		inv.invoice_no
				,inv.invoice_name 
				,convert(varchar(20), inv.invoice_date, 103) 'invoice_date'
				,convert(varchar(20), inv.invoice_due_date, 103) 'invoice_due_date'
				,inv.total_amount
				,inv.invoice_status
				,@rows_count 'rowcount'
	from		invoice inv 
	where		exists ( select 1 from invoice_detail where invoice_no = inv.invoice_no and agreement_no = @p_agreement_no)
				and inv.invoice_status not in ('PAID', 'CANCEL')
				and (
						inv.invoice_no										like '%' + @p_keywords + '%'
						or	inv.invoice_name								like '%' + @p_keywords + '%'
						or	convert(varchar(20), inv.invoice_date, 103)		like '%' + @p_keywords + '%'
						or	convert(varchar(20), inv.invoice_due_date, 103) like '%' + @p_keywords + '%'
						or	inv.total_amount								like '%' + @p_keywords + '%'
						or	inv.invoice_status								like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then inv.invoice_no
													 when 2 then inv.invoice_name
													 when 3 then cast(inv.invoice_date as sql_variant)
													 when 4 then cast(inv.invoice_due_date as sql_variant)
													 when 5 then cast(inv.total_amount as sql_variant)
													 when 6 then inv.invoice_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then inv.invoice_no
													   when 2 then inv.invoice_name
													   when 3 then cast(inv.invoice_date as sql_variant)
													   when 4 then cast(inv.invoice_due_date as sql_variant)
													   when 5 then cast(inv.total_amount as sql_variant)
													   when 6 then inv.invoice_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
