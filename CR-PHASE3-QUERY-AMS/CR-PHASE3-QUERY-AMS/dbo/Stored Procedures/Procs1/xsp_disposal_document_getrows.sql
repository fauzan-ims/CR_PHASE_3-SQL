CREATE PROCEDURE [dbo].[xsp_disposal_document_getrows]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_disposal_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	disposal_document
	where	disposal_code =  @p_disposal_code
	and		(
				disposal_code		 like '%' + @p_keywords + '%'
				or	file_name		 like '%' + @p_keywords + '%'
				or	path			 like '%' + @p_keywords + '%'
				or	description		 like '%' + @p_keywords + '%'
			) ;

	select		id
				,disposal_code
				,file_name
				,path
				,description
				,@rows_count 'rowcount'
	from		disposal_document
	where		disposal_code =  @p_disposal_code
	and			(
					disposal_code		 like '%' + @p_keywords + '%'
					or	file_name		 like '%' + @p_keywords + '%'
					or	path			 like '%' + @p_keywords + '%'
					or	description		 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then cast(id as sql_variant)
													 when 2 then DESCRIPTION
													 when 3 then file_name
													 when 4 then cast(id as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														 when 1 then cast(id as sql_variant)
														 when 2 then DESCRIPTION
														 when 3 then file_name
														 when 4 then cast(id as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
