CREATE PROCEDURE dbo.xsp_sys_document_number_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
)
as
begin
	declare 	@rows_count int = 0 ;

	select 	@rows_count = count(1)
	from	sys_document_number
	where	(
				code				like 	'%'+@p_keywords+'%'
				or	code_document	like 	'%'+@p_keywords+'%'
				or	description		like 	'%'+@p_keywords+'%'
			);

		select	code
				,code_document
				,description
				,@rows_count	 'rowcount'
		from	sys_document_number
		where	(
					code				like 	'%'+@p_keywords+'%'
					or	code_document	like 	'%'+@p_keywords+'%'
					or	description		like 	'%'+@p_keywords+'%'
				)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1	then code
														when 2	then code_document
														when 3	then description
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1	then code
														when 2	then code_document
														when 3	then description
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end
