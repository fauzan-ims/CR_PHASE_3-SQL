CREATE PROCEDURE dbo.xsp_xxxxjournal_gl_link_transaction_getrows
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
	from	xxxxjournal_gl_link_transaction
	where	(
				id like '%' + @p_keywords + '%'
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
				or	gl_link_code like '%' + @p_keywords + '%'
				or	contra_gl_link_code like '%' + @p_keywords + '%'
				or	agreement_no like '%' + @p_keywords + '%'
				or	orig_currency_code like '%' + @p_keywords + '%'
				or	orig_amount_db like '%' + @p_keywords + '%'
				or	orig_amount_cr like '%' + @p_keywords + '%'
				or	exch_rate like '%' + @p_keywords + '%'
				or	base_amount_db like '%' + @p_keywords + '%'
				or	base_amount_cr like '%' + @p_keywords + '%'
				or	division_code like '%' + @p_keywords + '%'
				or	division_name like '%' + @p_keywords + '%'
				or	department_code like '%' + @p_keywords + '%'
				or	department_name like '%' + @p_keywords + '%'
			) ;
		select		id
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
					,gl_link_code
					,contra_gl_link_code
					,agreement_no
					,orig_currency_code
					,orig_amount_db
					,orig_amount_cr
					,exch_rate
					,base_amount_db
					,base_amount_cr
					,division_code
					,division_name
					,department_code
					,department_name
					,@rows_count 'rowcount'
		from		xxxxjournal_gl_link_transaction
		where		(
						id like '%' + @p_keywords + '%'
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
						or	gl_link_code like '%' + @p_keywords + '%'
						or	contra_gl_link_code like '%' + @p_keywords + '%'
						or	agreement_no like '%' + @p_keywords + '%'
						or	orig_currency_code like '%' + @p_keywords + '%'
						or	orig_amount_db like '%' + @p_keywords + '%'
						or	orig_amount_cr like '%' + @p_keywords + '%'
						or	exch_rate like '%' + @p_keywords + '%'
						or	base_amount_db like '%' + @p_keywords + '%'
						or	base_amount_cr like '%' + @p_keywords + '%'
						or	division_code like '%' + @p_keywords + '%'
						or	division_name like '%' + @p_keywords + '%'
						or	department_code like '%' + @p_keywords + '%'
						or	department_name like '%' + @p_keywords + '%'
					)
		order by case  
		when @p_sort_by = 'asc' then case @p_order_by
										when 1 then branch_code
										when 2 then branch_name
										when 3 then transaction_status
										when 4 then transaction_code
										when 5 then transaction_name
										when 6 then reff_module_code
										when 7 then reff_source_no
										when 8 then reff_source_name
										when 9 then gl_link_code
										when 10 then contra_gl_link_code
										when 11 then agreement_no
										when 12 then orig_currency_code
										when 13 then division_code
										when 14 then division_name
										when 15 then department_code
										when 16 then department_name
									end
		end asc 
		,case when @p_sort_by = 'desc' then case @p_order_by
												when 1 then branch_code
												when 2 then branch_name
												when 3 then transaction_status
												when 4 then transaction_code
												when 5 then transaction_name
												when 6 then reff_module_code
												when 7 then reff_source_no
												when 8 then reff_source_name
												when 9 then gl_link_code
												when 10 then contra_gl_link_code
												when 11 then agreement_no
												when 12 then orig_currency_code
												when 13 then division_code
												when 14 then division_name
												when 15 then department_code
												when 16 then department_name
											end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
