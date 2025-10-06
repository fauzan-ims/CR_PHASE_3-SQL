CREATE PROCEDURE dbo.xsp_invoice_getrows_for_payment_request
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	--
	,@p_branch_code			nvarchar(50)
	,@p_from_date			datetime = ''
	,@p_to_date				datetime = ''
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
	from	invoice
	where	branch_code	= case @p_branch_code
								when 'ALL' then branch_code
								else @p_branch_code
						  end
    and	invoice_status in ('PAID', 'POST')
	and isnull(payment_ppn_code,'') = ''
	and		invoice_date between @p_from_date and @p_to_date				 
	and		(	
				invoice_no										like '%' + @p_keywords + '%'
				or	faktur_no									like '%' + @p_keywords + '%'
				or	client_name									like '%' + @p_keywords + '%'
				or	convert(varchar(20),invoice_date,103)		like '%' + @p_keywords + '%'
				or	convert(varchar(20),invoice_due_date,103) 	like '%' + @p_keywords + '%'
				or	invoice_name								like '%' + @p_keywords + '%'
				or	total_amount								like '%' + @p_keywords + '%'
				or	total_ppn_amount - credit_ppn_amount		like '%' + @p_keywords + '%'
				or	invoice_status								like '%' + @p_keywords + '%'
				or	invoice_external_no							like '%' + @p_keywords + '%'
			) ;

	select	invoice_no	
			,invoice_external_no									
			,faktur_no									
			,client_name								
			,convert(varchar(20),invoice_date,103)		'invoice_date'
			,convert(varchar(20),invoice_due_date,103) 	'invoice_due_date'
			,invoice_name								
			,total_amount								
			,total_ppn_amount - credit_ppn_amount 'total_ppn_amount'						
			,invoice_status								
			,@rows_count 'rowcount'
	from	invoice
	where	branch_code	= case @p_branch_code
								when 'ALL' then branch_code
								else @p_branch_code
						  end
	and	invoice_status in ('PAID', 'POST')
	and isnull(payment_ppn_code,'') = ''
	and		invoice_date between @p_from_date and @p_to_date				 
	and		(	
				invoice_no										like '%' + @p_keywords + '%'
				or	faktur_no									like '%' + @p_keywords + '%'
				or	client_name									like '%' + @p_keywords + '%'
				or	convert(varchar(20),invoice_date,103)		like '%' + @p_keywords + '%'
				or	convert(varchar(20),invoice_due_date,103) 	like '%' + @p_keywords + '%'
				or	invoice_name								like '%' + @p_keywords + '%'
				or	total_amount								like '%' + @p_keywords + '%'
				or	total_ppn_amount - credit_ppn_amount		like '%' + @p_keywords + '%'
				or	invoice_status								like '%' + @p_keywords + '%'
				or	invoice_external_no							like '%' + @p_keywords + '%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then invoice_external_no
														when 2 then faktur_no
														when 3 then client_name
														when 4 then cast(invoice_date as sql_variant)
														when 5 then invoice_name
														when 6 then cast(total_amount as sql_variant)
														when 7 then cast(total_ppn_amount - credit_ppn_amount as sql_variant)
														when 8 then invoice_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then invoice_external_no
														when 2 then faktur_no
														when 3 then client_name
														when 4 then cast(invoice_date as sql_variant)
														when 5 then invoice_name
														when 6 then cast(total_amount as sql_variant)
														when 7 then cast(total_ppn_amount - credit_ppn_amount as sql_variant)
														when 8 then invoice_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
