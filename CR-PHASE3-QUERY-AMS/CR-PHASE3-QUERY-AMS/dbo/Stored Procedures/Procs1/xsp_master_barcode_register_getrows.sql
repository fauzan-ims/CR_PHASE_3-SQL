create PROCEDURE dbo.xsp_master_barcode_register_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_status			nvarchar(20)
	,@p_company_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_barcode_register
	where	status = case @p_status
						when 'ALL' then status
						else @p_status
					end
	and		company_code = @p_company_code
	and		(
				code											 like '%' + @p_keywords + '%'
				or	convert(nvarchar(30), register_date, 103)	 like '%' + @p_keywords + '%'
				or	convert(nvarchar(30), start_date, 103)		 like '%' + @p_keywords + '%'
				or	convert(nvarchar(30), end_date, 103)		 like '%' + @p_keywords + '%'
				or	status										 like '%' + @p_keywords + '%'
			) ;

	select		code
				,company_code
				,convert(nvarchar(30), register_date, 103) 'register_date'
				,convert(nvarchar(30), start_date, 103) 'start_date'
				,convert(nvarchar(30), end_date, 103) 'end_date'
				,status
				,@rows_count 'rowcount'
	from		master_barcode_register
	where		status = case @p_status
						when 'ALL' then status
						else @p_status
					end
	and			company_code = @p_company_code
	and			(
					code											 like '%' + @p_keywords + '%'
					or	convert(nvarchar(30), register_date, 103)	 like '%' + @p_keywords + '%'
					or	convert(nvarchar(30), start_date, 103)		 like '%' + @p_keywords + '%'
					or	convert(nvarchar(30), end_date, 103)		 like '%' + @p_keywords + '%'
					or	status										 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 0 then code
													 when 1 then cast(register_date as sql_variant)
													 when 2 then cast(start_date as sql_variant)
													 when 3 then cast(end_date as sql_variant)
													 when 4 then status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 0 then code
													 when 1 then cast(register_date as sql_variant)
													 when 2 then cast(start_date as sql_variant)
													 when 3 then cast(end_date as sql_variant)
													 when 4 then status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
