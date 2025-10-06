CREATE PROCEDURE dbo.xsp_sys_general_document_lookup_for_company_document
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_insurance_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.sys_general_document
	where	code not in (
					select	document_code
					from	dbo.master_insurance_document
					where	document_code		= code
							and insurance_code	= @p_insurance_code
			)
			and (
					code							like '%' + @p_keywords + '%'
					or	document_name				like '%' + @p_keywords + '%'
				) ;

		select		code
					,document_name
					,@rows_count 'rowcount'
		from		dbo.sys_general_document
		where		code not in (
							select	document_code
							from	dbo.master_insurance_document
							where	document_code		= code
									and insurance_code	= @p_insurance_code
					)
					and (
							code							like '%' + @p_keywords + '%'
							or	document_name				like '%' + @p_keywords + '%'
						)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then code
														when 2 then document_name 
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then document_name 
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;
