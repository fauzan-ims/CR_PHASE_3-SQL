CREATE PROCEDURE dbo.xsp_sys_report_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_report_type nvarchar(15) = 'ALL'
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.sys_report
	where	 report_type	  = case @p_report_type
								when 'ALL' then report_type
								else @p_report_type
							end
	and		 (
					name							like '%' + @p_keywords + '%'
					or	report_type like '%' + @p_keywords + '%'
					or	case is_active
							when '1' then 'Yes'
							else 'No'
						end							like '%' + @p_keywords + '%'
				) ;

	select		code
				,name
				,screen_name
				,case is_active
					 when '1' then 'Yes'
					 else 'No'
				 end		 'is_active'
				,@rows_count 'rowcount'
	from		dbo.sys_report
	where		report_type	  = case @p_report_type
										when 'ALL' then report_type
										else @p_report_type
									end
	and			 (
						name						like '%' + @p_keywords + '%'
						or	report_type like '%' + @p_keywords + '%'
						or	case is_active
								when '1' then 'Yes'
								else 'No'
							end						like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then name
													 when 2 then is_active
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then name
													   when 2 then is_active
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
