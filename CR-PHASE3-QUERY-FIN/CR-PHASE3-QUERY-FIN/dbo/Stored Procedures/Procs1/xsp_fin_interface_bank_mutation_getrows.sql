CREATE PROCEDURE dbo.xsp_fin_interface_bank_mutation_getrows
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
	from	fin_interface_bank_mutation
	where	(
				id							like '%' + @p_keywords + '%'
				or	gl_link_code			like '%' + @p_keywords + '%'
				or	reff_no					like '%' + @p_keywords + '%'
				or	reff_name				like '%' + @p_keywords + '%'
				or	reff_remarks			like '%' + @p_keywords + '%'
				or	mutation_date			like '%' + @p_keywords + '%'
				or	mutation_value_date		like '%' + @p_keywords + '%'
				or	mutation_orig_amount	like '%' + @p_keywords + '%'
				or	mutation_exch_rate		like '%' + @p_keywords + '%'
				or	mutation_base_amount	like '%' + @p_keywords + '%'
			) ;

		select		id
					,gl_link_code
					,reff_no
					,reff_name
					,reff_remarks
					,mutation_date
					,mutation_value_date
					,mutation_orig_amount
					,mutation_exch_rate
					,mutation_base_amount
					,@rows_count 'rowcount'
		from		fin_interface_bank_mutation
		where		(
						id							like '%' + @p_keywords + '%'
						or	gl_link_code			like '%' + @p_keywords + '%'
						or	reff_no					like '%' + @p_keywords + '%'
						or	reff_name				like '%' + @p_keywords + '%'
						or	reff_remarks			like '%' + @p_keywords + '%'
						or	mutation_date			like '%' + @p_keywords + '%'
						or	mutation_value_date		like '%' + @p_keywords + '%'
						or	mutation_orig_amount	like '%' + @p_keywords + '%'
						or	mutation_exch_rate		like '%' + @p_keywords + '%'
						or	mutation_base_amount	like '%' + @p_keywords + '%'
					)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then gl_link_code
														when 2 then reff_no
														when 3 then reff_name
														when 4 then reff_remarks
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then gl_link_code
														when 2 then reff_no
														when 3 then reff_name
														when 4 then reff_remarks
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
