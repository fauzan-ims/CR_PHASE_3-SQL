CREATE PROCEDURE dbo.xsp_sys_general_document_lookup
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
	from	sys_general_document
	where	is_active = '1'
			and (
					code					like 	'%'+@p_keywords+'%'
					or	document_name		like 	'%'+@p_keywords+'%'
				);
			 
		select	code
				,document_name
				,@rows_count	 'rowcount'
		from	sys_general_document
		where	is_active = '1'
				and (
						code					like 	'%'+@p_keywords+'%'
						or	document_name		like 	'%'+@p_keywords+'%'
					) 
		Order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1	then code
													when 2	then document_name
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1	then code
													when 2	then document_name
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end
