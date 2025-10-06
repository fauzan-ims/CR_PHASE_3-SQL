CREATE PROCEDURE dbo.xsp_master_upload_tabel_column_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_upload_tabel_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.master_upload_tabel_column
	where	upload_tabel_code = @p_upload_tabel_code
	and		(
				column_name					                like '%' + @p_keywords + '%'
				or data_type								like '%' + @p_keywords + '%'
				or substring(order_key,8,2)					like '%' + @p_keywords + '%'
			) ;
		
		select	code
				,column_name
				,(select stuff((
						   select ' '+upper(left(T3.V, 1))+lower(stuff(T3.V, 1, 1, ''))
						   from (select cast(replace((select data_type as '*' for xml path('')), ' ', '<X/>') as xml).query('.')) as T1(X)
							 cross apply T1.X.nodes('text()') as T2(X)
							 cross apply (select T2.X.value('.', 'varchar(250)')) as T3(V)
						   for xml path(''), type
						   ).value('text()[1]', 'varchar(30)'), 1, 1, '') as [Capitalize first letter only]) 'data_type'
				,substring(order_key,8,2) 'order_key'
				,@rows_count 'rowcount'
		from	dbo.master_upload_tabel_column
		where	upload_tabel_code = @p_upload_tabel_code
		and		(
					column_name					                like '%' + @p_keywords + '%'
					or data_type								like '%' + @p_keywords + '%'
					or substring(order_key,8,2)					like '%' + @p_keywords + '%'
				)
		order by case  
		when @p_sort_by = 'asc' then case @p_order_by
											when 1 then column_name		
											when 2 then data_type
											when 3 then order_key	
										end
		end asc 
		,case when @p_sort_by = 'desc' then case @p_order_by
												when 1 then column_name		
												when 2 then data_type
												when 3 then order_key	
											end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
