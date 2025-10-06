CREATE PROCEDURE dbo.xsp_invoice_pph_payment_getrows
(
	@p_branch_code			nvarchar(50)
	,@p_status				nvarchar(15)
	,@p_from_date			datetime = ''
	,@p_to_date				datetime = ''
	--
	,@p_keywords			nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
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
	from	invoice_pph_payment
	where	branch_code	= case @p_branch_code
								when 'ALL' then branch_code
								else @p_branch_code
						  end
	and		status	= case @p_status
								when 'ALL' then status
								else @p_status
						  end
	--and		date between @p_from_date and @p_to_date	
	and		(
				code								like '%' + @p_keywords + '%'
				or	branch_name						like '%' + @p_keywords + '%'
				or	status							like '%' + @p_keywords + '%'
				or	convert(varchar(30), date, 103) like '%' + @p_keywords + '%'
				or	remark							like '%' + @p_keywords + '%'
				or	total_pph_amount				like '%' + @p_keywords + '%'
				or	currency_code					like '%' + @p_keywords + '%'

			) ;

	select		code
				,branch_code
				,branch_name
				,status
				,convert(varchar(30), date, 103) 'date'
				,remark
				,total_pph_amount
				,process_date
				,process_reff_no
				,process_reff_name
				,currency_code
				,@rows_count 'rowcount'
	from		invoice_pph_payment
	where		branch_code	= case @p_branch_code
								when 'ALL' then branch_code
								else @p_branch_code
						  end
	and		status	= case @p_status
								when 'ALL' then status
								else @p_status
						  end
	--and		date between @p_from_date and @p_to_date		
	and			(
					code								like '%' + @p_keywords + '%'
					or	branch_name						like '%' + @p_keywords + '%'
					or	status							like '%' + @p_keywords + '%'
					or	convert(varchar(30), date, 103) like '%' + @p_keywords + '%'
					or	remark							like '%' + @p_keywords + '%'
					or	total_pph_amount				like '%' + @p_keywords + '%'
					or	currency_code					like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then branch_name
													 when 3 then cast(date as sql_variant)
													 when 4 then remark
													 when 5 then cast(total_pph_amount as sql_variant)
													 when 6 then remark
													 when 7 then status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then code
													 when 2 then branch_name
													 when 3 then cast(date as sql_variant)
													 when 4 then remark
													 when 5 then cast(total_pph_amount as sql_variant)
													 when 6 then remark
													 when 7 then status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
