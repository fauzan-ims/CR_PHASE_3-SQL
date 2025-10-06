
CREATE procedure dbo.xsp_sys_document_upload_getrows
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
	from	sys_document_upload
	where	(
				reff_trx_code like '%' + @p_keywords + '%'
				or	file_name like '%' + @p_keywords + '%'
			) ;

	select		id
				,reff_trx_code
				,file_name
				,@rows_count 'rowcount'
	from		sys_document_upload
	where		(
					reff_trx_code like '%' + @p_keywords + '%'
					or	file_name like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then reff_trx_code
													 when 2 then file_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then reff_trx_code
													   when 2 then file_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
