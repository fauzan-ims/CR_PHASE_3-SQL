CREATE PROCEDURE dbo.xsp_application_approval_comment_getrows
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_application_no nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	application_approval_comment aac
			left join dbo.master_workflow mw on (mw.code = aac.level_status)
	where	application_no = @p_application_no
			and (
					isnull(mw.description, aac.level_status)									like '%' + @p_keywords + '%'
					or	aac.level_status														like '%' + @p_keywords + '%'
					or	format(cast(aac.mod_date as datetime),'dd/MM/yyyy HH:mm:ss','en-us')	like '%' + @p_keywords + '%'
					or	aac.remarks																like '%' + @p_keywords + '%'
					or	aac.mod_by																like '%' + @p_keywords + '%'
					or	aac.cycle																like '%' + @p_keywords + '%'
				) ;

		select		aac.id
					,aac.last_status
					,isnull(mw.description, aac.level_status) 'level_status'				
					,format(cast(aac.mod_date as datetime),'dd/MM/yyyy HH:mm:ss','en-us') 'mod_date'
					,aac.remarks			
					,aac.mod_by				
					,aac.cycle		
					,@rows_count 'rowcount'
		from		application_approval_comment aac
					left join dbo.master_workflow mw on (mw.code = aac.level_status)
		where		application_no = @p_application_no
					and (
							isnull(mw.description, aac.level_status)									like '%' + @p_keywords + '%'
							or	aac.level_status														like '%' + @p_keywords + '%'
							or	format(cast(aac.mod_date as datetime),'dd/MM/yyyy HH:mm:ss','en-us')	like '%' + @p_keywords + '%'
							or	aac.remarks																like '%' + @p_keywords + '%'
							or	aac.mod_by																like '%' + @p_keywords + '%'
							or	aac.cycle																like '%' + @p_keywords + '%'
						)

	order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then format(cast(aac.mod_date as datetime),'dd/MM/yyyy HH:mm:ss','en-us')
													when 2 then isnull(mw.description, aac.level_status)		
													when 3 then aac.remarks							
													when 4 then aac.mod_by		
													when 5 then cast(aac.cycle as sql_variant)	
													when 6 then aac.last_status	
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then format(cast(aac.mod_date as datetime),'dd/MM/yyyy HH:mm:ss','en-us')
														when 2 then isnull(mw.description, aac.level_status)		
														when 3 then aac.remarks							
														when 4 then aac.mod_by		
														when 5 then cast(aac.cycle as sql_variant)	
														when 6 then aac.last_status	
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;

