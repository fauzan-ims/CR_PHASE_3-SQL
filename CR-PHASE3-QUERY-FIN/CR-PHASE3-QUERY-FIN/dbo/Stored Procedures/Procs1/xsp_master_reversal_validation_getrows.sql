create PROCEDURE dbo.xsp_master_reversal_validation_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_reversal_validation 
	where	(
				name					like '%' + @p_keywords + '%'
				or	module_code			like '%' + @p_keywords + '%'
				or	process_name   		like '%' + @p_keywords + '%'
				or	api_validation		like '%' + @p_keywords + '%'
			) ;

		select		id
					,name
					,module_code		
					,process_name  
					,api_validation
					,@rows_count 'rowcount'
		from		master_reversal_validation 
		where		(
						name					like '%' + @p_keywords + '%'
						or	module_code			like '%' + @p_keywords + '%'
						or	process_name   		like '%' + @p_keywords + '%'
						or	api_validation		like '%' + @p_keywords + '%'
					) 
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then name
														when 2 then module_code		
														when 3 then process_name  
														when 4 then api_validation
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then name
														when 2 then module_code		
														when 3 then process_name  
														when 4 then api_validation
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
