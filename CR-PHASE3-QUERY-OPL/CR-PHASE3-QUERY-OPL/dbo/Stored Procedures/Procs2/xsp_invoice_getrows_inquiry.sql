CREATE procedure dbo.xsp_invoice_getrows_inquiry
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	--
	,@p_invoice_status nvarchar(10)
	,@p_branch_code	   nvarchar(10)
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
	from	dbo.invoice inv
	where	inv.invoice_status	= case @p_invoice_status
									  when 'ALL' then inv.invoice_status
									  else @p_invoice_status
								  end
			and inv.branch_code = case @p_branch_code
									  when 'ALL' then inv.branch_code
									  else @p_branch_code
								  end
			and
			(
				inv.invoice_no										like '%' + @p_keywords + '%'
				or	inv.invoice_external_no							like '%' + @p_keywords + '%'
				or	invoice_name									like '%' + @p_keywords + '%'
				or	convert(varchar(30), inv.invoice_date, 103)		like '%' + @p_keywords + '%'
				or	convert(varchar(30), invoice_due_date, 103)		like '%' + @p_keywords + '%'
				or	client_name										like '%' + @p_keywords + '%'
				or	total_amount									like '%' + @p_keywords + '%'
				or	invoice_status									like '%' + @p_keywords + '%'
			) ;

	select		invoice_no
				,inv.invoice_external_no
				,total_amount
				,convert(varchar(30), inv.invoice_date, 103) 'invoice_date'
				,convert(varchar(30), invoice_due_date, 103) 'invoice_due_date'
				,invoice_name
				,invoice_status
				,client_name
				,@rows_count 'rowcount'
	from		dbo.invoice inv
	where		inv.invoice_status	= case @p_invoice_status
										  when 'ALL' then inv.invoice_status
										  else @p_invoice_status
									  end
				and inv.branch_code = case @p_branch_code
										  when 'ALL' then inv.branch_code
										  else @p_branch_code
									  end
				and
				(
					inv.invoice_no										like '%' + @p_keywords + '%'
					or	inv.invoice_external_no							like '%' + @p_keywords + '%'
					or	invoice_name									like '%' + @p_keywords + '%'
					or	convert(varchar(30), inv.invoice_date, 103)		like '%' + @p_keywords + '%'
					or	convert(varchar(30), invoice_due_date, 103)		like '%' + @p_keywords + '%'
					or	client_name										like '%' + @p_keywords + '%'
					or	total_amount									like '%' + @p_keywords + '%'
					or	invoice_status									like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then inv.invoice_external_no
													 when 2 then invoice_name
													 when 3 then cast(inv.invoice_date as sql_variant)
													 when 4 then cast(invoice_due_date as sql_variant)
													 when 5 then client_name
													 when 6 then total_amount
													 when 7 then invoice_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then inv.invoice_external_no
													   when 2 then invoice_name
													   when 3 then cast(inv.invoice_date as sql_variant)
													   when 4 then cast(invoice_due_date as sql_variant)
													   when 5 then client_name
													   when 6 then total_amount
													   when 7 then invoice_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
