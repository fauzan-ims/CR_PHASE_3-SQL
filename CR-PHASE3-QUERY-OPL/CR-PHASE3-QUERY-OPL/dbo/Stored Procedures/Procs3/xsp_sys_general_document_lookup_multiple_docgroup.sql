CREATE PROCEDURE dbo.xsp_sys_general_document_lookup_multiple_docgroup
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_document_group_code nvarchar(50)
)
as
begin
	declare 	@rows_count int = 0 ;

	select 	@rows_count = count(1)
	from	sys_general_document
	where	code not in (
					select	general_doc_code
					from	dbo.master_document_group_detail
					where	general_doc_code = code
							and document_group_code = @p_document_group_code
			)
			and is_active = '1'
			and(
				code					like 	'%'+@p_keywords+'%'
				or	document_name		like 	'%'+@p_keywords+'%'
			);
			 
		select	code
				,document_name
				,@rows_count	 'rowcount'
		from	sys_general_document
		where	code not in (
					select	general_doc_code
					from	dbo.master_document_group_detail
					where	general_doc_code = code
							and document_group_code = @p_document_group_code
				)
				and is_active = '1'
				and(
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
