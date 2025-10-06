CREATE PROCEDURE dbo.xsp_supplier_document_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_supplier_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	supplier_document
	where	supplier_code = @p_supplier_code
			and (
					document_name								like '%' + @p_keywords + '%'
					or	file_name								like '%' + @p_keywords + '%'
					or	convert(varchar(30), expired_date, 103)	like '%' + @p_keywords + '%'
				) ;

		select		id
					,document_code
					,document_name
					,file_name
					,paths
					,expired_date
					,@rows_count 'rowcount'
		from		supplier_document
		where		supplier_code = @p_supplier_code
					and (
							document_name								like '%' + @p_keywords + '%'
							or	file_name								like '%' + @p_keywords + '%'
							or	convert(varchar(30), expired_date, 103)	like '%' + @p_keywords + '%'
						)
		
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
												when 1 then document_name
												when 2 then file_name
												when 3 then cast(expired_date as sql_variant)
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
												when 1 then document_name
												when 2 then file_name
												when 3 then cast(expired_date as sql_variant)
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;
