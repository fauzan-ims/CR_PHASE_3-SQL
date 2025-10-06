CREATE PROCEDURE dbo.xsp_application_asset_component_getrows
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_asset_no nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	application_asset_component
	where	asset_no = @p_asset_no
			and (
					component_name									like '%' + @p_keywords + '%'
					or	component_no								like '%' + @p_keywords + '%'
					or	convert(varchar(30), component_date, 103)	like '%' + @p_keywords + '%'
					or	component_remarks							like '%' + @p_keywords + '%'
				) ;

		select		id
					,component_name
					,component_no
					,convert(varchar(30), component_date, 103) 'component_date'
					,component_remarks
					,@rows_count 'rowcount'
		from		application_asset_component
		where		asset_no = @p_asset_no
					and (
							component_name									like '%' + @p_keywords + '%'
							or	component_no								like '%' + @p_keywords + '%'
							or	convert(varchar(30), component_date, 103)	like '%' + @p_keywords + '%'
							or	component_remarks							like '%' + @p_keywords + '%'
						)
	
	Order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then component_name
													when 2 then component_no								
													when 3 then convert(varchar(30), component_date, 103)	
													when 4 then component_remarks	
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then component_name
														when 2 then component_no								
														when 3 then convert(varchar(30), component_date, 103)	
														when 4 then component_remarks	
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;

