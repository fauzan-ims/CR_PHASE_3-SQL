CREATE PROCEDURE dbo.xsp_register_document_getrows
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_register_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	register_document rd 
			inner join dbo.sys_general_document sgd on (sgd.code = rd.document_code)
	where	register_code = @p_register_code
			and (
					sgd.document_name		like '%' + @p_keywords + '%'
					or	rd.file_name		like '%' + @p_keywords + '%'
					or	rd.paths			like '%' + @p_keywords + '%'
				) ;
 
		select		id
					,register_code
					,sgd.document_name
					,file_name
					,isnull(paths,'') 'paths'
					,@rows_count 'rowcount'
		from		register_document rd 
					inner join dbo.sys_general_document sgd on (sgd.code = rd.document_code)
		where		register_code = @p_register_code
					and (
							sgd.document_name		like '%' + @p_keywords + '%'
							or	rd.file_name		like '%' + @p_keywords + '%'
							or	rd.paths			like '%' + @p_keywords + '%'
						) 
		Order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then sgd.document_name
													when 2 then file_name
													when 3 then paths
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then sgd.document_name
													when 2 then file_name
													when 3 then paths
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;
