CREATE PROCEDURE dbo.xsp_master_custom_report_column_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_custom_report_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_custom_report_column
	where	custom_report_code = @p_custom_report_code
	and		(
				id							 like '%' + @p_keywords + '%'
				or	custom_report_code		 like '%' + @p_keywords + '%'
				or	column_name				 like '%' + @p_keywords + '%'
				or	header_name				 like '%' + @p_keywords + '%'
				or	order_key				 like '%' + @p_keywords + '%'
			) ;

	select		id 'id_column'
				,custom_report_code
				,column_name
				,header_name
				,order_key
				,@rows_count 'rowcount'
	from		master_custom_report_column
	where		custom_report_code = @p_custom_report_code
	and			(
					id							 like '%' + @p_keywords + '%'
					or	custom_report_code		 like '%' + @p_keywords + '%'
					or	column_name				 like '%' + @p_keywords + '%'
					or	header_name				 like '%' + @p_keywords + '%'
					or	order_key				 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then header_name
													 when 2 then cast(order_key as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then header_name
													 when 2 then cast(order_key as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
