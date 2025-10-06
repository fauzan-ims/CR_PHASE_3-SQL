CREATE PROCEDURE [dbo].[xsp_master_selling_attachtment_group_detail_getrows]
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
	from	dbo.master_selling_attachment_group_detail d
			inner join dbo.sys_general_document s on (s.code = d.general_doc_code)
	where	document_group_code = @p_document_group_code
			and (
				s.document_name				like 	'%'+@p_keywords+'%'
				or	is_required				like 	'%'+@p_keywords+'%'

			);

		select	id
				,s.document_name	
				,is_required
				,@rows_count	 'rowcount'
		from	dbo.master_selling_attachment_group_detail d
				inner join dbo.sys_general_document s on (s.code = d.general_doc_code)
		where	document_group_code = @p_document_group_code
				and (
						s.document_name			like 	'%'+@p_keywords+'%'
					or	is_required				like 	'%'+@p_keywords+'%'

				)

	order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1	then s.document_name	
													when 2	then is_required
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1	then s.document_name	
														when 2	then is_required
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end
