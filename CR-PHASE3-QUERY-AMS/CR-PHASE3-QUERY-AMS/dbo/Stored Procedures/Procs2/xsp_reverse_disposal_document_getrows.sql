CREATE procedure [dbo].[xsp_reverse_disposal_document_getrows]
(
	@p_keywords				  nvarchar(50)
	,@p_pagenumber			  int
	,@p_rowspage			  int
	,@p_order_by			  int
	,@p_sort_by				  nvarchar(5)
	,@p_reverse_disposal_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	reverse_disposal_document
	where	reverse_disposal_code = @p_reverse_disposal_code
			and (
					file_name		like '%' + @p_keywords + '%'
					or	path		like '%' + @p_keywords + '%'
					or	description like '%' + @p_keywords + '%'
				) ;

	select		id
				,reverse_disposal_code
				,file_name
				,path
				,description
				,@rows_count 'rowcount'
	from		reverse_disposal_document
	where		reverse_disposal_code = @p_reverse_disposal_code
				and (
						file_name		like '%' + @p_keywords + '%'
						or	path		like '%' + @p_keywords + '%'
						or	description like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then description
													 when 2 then file_name
													 when 3 then cast(id as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then description
													   when 2 then file_name
													   when 3 then cast(id as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
