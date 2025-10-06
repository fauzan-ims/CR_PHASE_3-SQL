
create procedure xsp_asset_document_history_getrows
(
	@p_keywords	nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by	nvarchar(5)
)
as
begin
	declare 	@rows_count int = 0 ;

	select 	@rows_count = count(1)
	from	asset_document_history
	where	(
				asset_code			like 	'%'+@p_keywords+'%'
				or	document_code	like 	'%'+@p_keywords+'%'
				or	document_no		like 	'%'+@p_keywords+'%'
				or	description		like 	'%'+@p_keywords+'%'
				or	file_name		like 	'%'+@p_keywords+'%'
				or	path			like 	'%'+@p_keywords+'%'
			);

	select	id
			,asset_code
			,document_code
			,document_no
			,description
			,file_name
			,path
			,@rows_count	 'rowcount'
	from	asset_document_history
	where	(
				asset_code			like 	'%'+@p_keywords+'%'
				or	document_code	like 	'%'+@p_keywords+'%'
				or	document_no		like 	'%'+@p_keywords+'%'
				or	description		like 	'%'+@p_keywords+'%'
				or	file_name		like 	'%'+@p_keywords+'%'
				or	path			like 	'%'+@p_keywords+'%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													when 1	then asset_code
													when 2	then document_code
													when 3	then document_no
													when 4	then description
													when 5	then file_name
													when 6	then path
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													when 1	then asset_code
													when 2	then document_code
													when 3	then document_no
													when 4	then description
													when 5	then file_name
													when 6	then path
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	
end
