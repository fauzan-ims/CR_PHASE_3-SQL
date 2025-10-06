CREATE PROCEDURE dbo.xsp_master_upload_table_column_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_upload_table_code	nvarchar(50)
)
as
begin

	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.master_upload_table_column
	where	upload_table_code = @p_upload_table_code
	and		(
				column_name					                like '%' + @p_keywords + '%'
				or data_type								like '%' + @p_keywords + '%'
			) ;


	select	code
			,column_name
			--,(select stuff((
			--		   select ' '+upper(left(T3.V, 1))+lower(stuff(T3.V, 1, 1, ''))
			--		   from (select cast(replace((select data_type as '*' for xml path('')), ' ', '<X/>') as xml).query('.')) as T1(X)
			--			 cross apply T1.X.nodes('text()') as T2(X)
			--			 cross apply (select T2.X.value('.', 'varchar(250)')) as T3(V)
			--		   for xml path(''), type
			--		   ).value('text()[1]', 'varchar(30)'), 1, 1, '') as [Capitalize first letter only]) 'data_type'
			,max_length
			,case data_type
				when 'nvarchar' then 'String'
				when 'int' then 'Number'
				when 'datetime' then 'Date'
				when 'decimal' then 'Decimal'
				else data_type end 'data_type'
			,@rows_count 'rowcount'
	from	dbo.master_upload_table_column
	where	upload_table_code = @p_upload_table_code
	and		(
				column_name					                like '%' + @p_keywords + '%'
				or data_type								like '%' + @p_keywords + '%'
			)
	order by 
				case 
					when @p_sort_by = 'asc' then 
												case @p_order_by 
												when 1 then column_name		
												when 2 then data_type
												when 3 then cast(max_length as sql_variant)
												end				
				end asc,
				case 
					when @p_sort_by = 'desc' then 
												case @p_order_by 
												when 1 then column_name		
												when 2 then data_type
												when 3 then cast(max_length as sql_variant)
												end				
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;

end ;
