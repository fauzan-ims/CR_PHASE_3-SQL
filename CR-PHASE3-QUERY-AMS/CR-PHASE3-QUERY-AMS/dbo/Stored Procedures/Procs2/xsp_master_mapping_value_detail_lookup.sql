CREATE PROCEDURE dbo.xsp_master_mapping_value_detail_lookup
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_company_code		nvarchar(50)
	,@p_custom_report_code  nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.master_mapping_value_detail mmvd
	where	field_name not in
			(
				select header_name 
				from dbo.master_custom_report_column
			)
	and		(
				field_name like '%' + @p_keywords + '%'
			) ;

	select		mmvd.field_name 'column_name'
				,@rows_count 'rowcount'
	from		dbo.master_mapping_value_detail mmvd
	where		field_name not in
				(
					select header_name 
					from dbo.master_custom_report_column
				)
	and			(
					field_name like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then mmvd.field_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then mmvd.field_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
