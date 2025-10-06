CREATE PROCEDURE dbo.xsp_application_main_lookup_for_report_level
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_for_all	   nvarchar(1) = ''
)
as
begin
	declare @rows_count int = 0 ;

	if (@p_for_all <> '')
	begin
		select	@rows_count = count(1)
		from
				(
					select	'ALL' as 'code'
							,'ALL' as 'level_name'
					union
					select	level_status
							,level_status
					from	dbo.application_main
				) as level_app
		where	(
					level_app.code like '%' + @p_keywords + '%'
					or	level_app.level_name like '%' + @p_keywords + '%'
				) ;
				 
			select		*
			from
						(
							select	'ALL' as 'code'
									,'ALL' as 'level_name'
									,@rows_count 'rowcount'
							union
							select	level_status
									,level_status
									,@rows_count 'rowcount'
							from	dbo.application_main
						) as level_app
			where		(
							level_app.code like '%' + @p_keywords + '%'
							or	level_app.level_name like '%' + @p_keywords + '%'
						) 
			order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then level_app.code
													when 2 then level_app.level_name
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then level_app.code
													when 2 then level_app.level_name
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
	end ;
	else
	begin
		select	@rows_count = count(1)
		from
				(
					select	'ALL' as 'code'
							,'ALL' as 'level_name'
					union
					select	level_status
							,level_status
					from	dbo.application_main
				) as level_app
		where	(
					level_app.code like '%' + @p_keywords + '%'
					or	level_app.level_name like '%' + @p_keywords + '%'
				) ;
				 
			select		*
			from
						(
							select	'ALL' as 'code'
									,'ALL' as 'level_name'
									,@rows_count 'rowcount'
							union
							select	level_status
									,level_status
									,@rows_count 'rowcount'
							from	dbo.application_main
						) as level_app
			where		(
							level_app.code like '%' + @p_keywords + '%'
							or	level_app.level_name like '%' + @p_keywords + '%'
						) 
			order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then level_app.code
													when 2 then level_app.level_name
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then level_app.code
													when 2 then level_app.level_name
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
	end ;
end ;

