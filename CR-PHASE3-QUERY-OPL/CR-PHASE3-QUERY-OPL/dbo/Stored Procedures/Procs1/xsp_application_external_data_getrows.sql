create procedure dbo.xsp_application_external_data_getrows
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
	from	dbo.application_external_data
	where	(
				reff_name like '%' + @p_keywords + '%'
				or	reff_value like '%' + @p_keywords + '%'
				or	reff_value_datatype like '%' + @p_keywords + '%'
				or	reff_value_string like '%' + @p_keywords + '%'
				or	reff_value_number like '%' + @p_keywords + '%'
				or	remark like '%' + @p_keywords + '%'
			) ;

	select		id
				,reff_name
				,reff_value
				,reff_value_datatype
				,reff_value_string
				,reff_value_number
				,remark
				,@rows_count 'rowcount'
	from		dbo.application_external_data
	where		(
					reff_name like '%' + @p_keywords + '%'
					or	reff_value like '%' + @p_keywords + '%'
					or	reff_value_datatype like '%' + @p_keywords + '%'
					or	reff_value_string like '%' + @p_keywords + '%'
					or	reff_value_number like '%' + @p_keywords + '%'
					or	remark like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then reff_name
													 when 2 then reff_value
													 when 3 then reff_value_datatype
													 when 4 then reff_value_string
													 when 5 then reff_value_number
													 when 6 then remark
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then reff_name
													   when 2 then reff_value
													   when 3 then reff_value_datatype
													   when 4 then reff_value_string
													   when 5 then reff_value_number
													   when 6 then remark
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
