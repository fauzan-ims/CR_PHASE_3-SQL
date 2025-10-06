CREATE procedure dbo.xsp_lgl_interface_journal_gl_link_transaction_getrows
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
	from	lgl_interface_journal_gl_link_transaction
	where	(
				id like '%' + @p_keywords + '%'
				or	code like '%' + @p_keywords + '%'
				or	branch_code like '%' + @p_keywords + '%'
				or	branch_name like '%' + @p_keywords + '%'
				or	transaction_status like '%' + @p_keywords + '%'
				or	transaction_date like '%' + @p_keywords + '%'
				or	transaction_value_date like '%' + @p_keywords + '%'
				or	transaction_code like '%' + @p_keywords + '%'
				or	transaction_name like '%' + @p_keywords + '%'
				or	reff_module_code like '%' + @p_keywords + '%'
				or	reff_source_no like '%' + @p_keywords + '%'
				or	reff_source_name like '%' + @p_keywords + '%'
			) ;

	select		id
				,code
				,branch_code
				,branch_name
				,transaction_status
				,transaction_date
				,transaction_value_date
				,transaction_code
				,transaction_name
				,reff_module_code
				,reff_source_no
				,reff_source_name
				,@rows_count 'rowcount'
	from		lgl_interface_journal_gl_link_transaction
	where		(
					id like '%' + @p_keywords + '%'
					or	code like '%' + @p_keywords + '%'
					or	branch_code like '%' + @p_keywords + '%'
					or	branch_name like '%' + @p_keywords + '%'
					or	transaction_status like '%' + @p_keywords + '%'
					or	transaction_date like '%' + @p_keywords + '%'
					or	transaction_value_date like '%' + @p_keywords + '%'
					or	transaction_code like '%' + @p_keywords + '%'
					or	transaction_name like '%' + @p_keywords + '%'
					or	reff_module_code like '%' + @p_keywords + '%'
					or	reff_source_no like '%' + @p_keywords + '%'
					or	reff_source_name like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then branch_code
													 when 3 then branch_name
													 when 4 then transaction_status
													 when 5 then transaction_code
													 when 6 then transaction_name
													 when 7 then reff_module_code
													 when 8 then reff_source_no
													 when 9 then reff_source_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then code
													   when 2 then branch_code
													   when 3 then branch_name
													   when 4 then transaction_status
													   when 5 then transaction_code
													   when 6 then transaction_name
													   when 7 then reff_module_code
													   when 8 then reff_source_no
													   when 9 then reff_source_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
