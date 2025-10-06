CREATE procedure dbo.xsp_cashier_upload_main_getrows
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_cashier_status nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	cashier_upload_main
	where	status = case @p_cashier_status
						 when 'ALL' then status
						 else @p_cashier_status
					 end
			and (
					batch_no								like '%' + @p_keywords + '%'
					or	fintech_name						like '%' + @p_keywords + '%'
					or	convert(varchar(30), trx_date, 103)	like '%' + @p_keywords + '%'
					or	status								like '%' + @p_keywords + '%'
				) ;

	select		code
				,batch_no
				,fintech_code
				,fintech_name
				,convert(varchar(30), value_date, 103) 'value_date'
				,convert(varchar(30), trx_date, 103) 'trx_date'
				,branch_bank_code
				,branch_bank_name
				,bank_gl_link_code
				,status
				,@rows_count 'rowcount'
	from		cashier_upload_main
	where		status = case @p_cashier_status
							 when 'ALL' then status
							 else @p_cashier_status
						 end
				and (
						batch_no								like '%' + @p_keywords + '%'
						or	fintech_name						like '%' + @p_keywords + '%'
						or	convert(varchar(30), trx_date, 103)	like '%' + @p_keywords + '%'
						or	status								like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then batch_no
													 when 2 then fintech_name
													 when 3 then cast(value_date as sql_variant)
													 when 4 then status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then batch_no
													   when 2 then fintech_name
													   when 3 then cast(value_date as sql_variant)
													   when 4 then status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
