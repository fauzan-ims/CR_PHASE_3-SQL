CREATE PROCEDURE dbo.xsp_term_of_payment_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_po_code	   nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	term_of_payment
	where	po_code = @p_po_code
	and		(
				transaction_name									like '%' + @p_keywords + '%'
				or	convert(varchar(30), transaction_date, 103)		like '%' + @p_keywords + '%'
				or	termin_type_name								like '%' + @p_keywords + '%'
				or	percentage										like '%' + @p_keywords + '%'
				or	amount											like '%' + @p_keywords + '%'
				or	remark											like '%' + @p_keywords + '%'
			) ;

	select		id
				,po_code
				,transaction_code
				,transaction_name
				,convert(varchar(30), transaction_date, 103) 'transaction_date'
				,termin_type_code
				,termin_type_name
				,refference_code
				,percentage
				,amount
				,case is_paid
					 when '1' then 'YES'
					 else 'NO'
				 end 'is_paid'
				,pph_amount
				,ppn_amount
				,remark
				,@rows_count 'rowcount'
	from		term_of_payment
	where		po_code = @p_po_code
	and			(
					transaction_name									like '%' + @p_keywords + '%'
					or	convert(varchar(30), transaction_date, 103)		like '%' + @p_keywords + '%'
					or	termin_type_name								like '%' + @p_keywords + '%'
					or	percentage										like '%' + @p_keywords + '%'
					or	amount											like '%' + @p_keywords + '%'
					or	remark											like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then transaction_name
													 when 2 then termin_type_name
													 when 3 then cast(amount as sql_variant)
													 when 4 then cast(percentage as sql_variant)
													 when 5 then remark
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then transaction_name
													 when 2 then termin_type_name
													 when 3 then cast(amount as sql_variant)
													 when 4 then cast(percentage as sql_variant)
													 when 5 then remark
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
