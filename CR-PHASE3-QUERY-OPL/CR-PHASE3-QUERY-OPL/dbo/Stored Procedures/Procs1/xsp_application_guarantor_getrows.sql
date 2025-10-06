CREATE PROCEDURE dbo.xsp_application_guarantor_getrows
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
	from	application_guarantor ag
	where	ag.application_no = @p_application_no
			and (
					ag.guarantor_client_type		like '%' + @p_keywords + '%'
					or	ag.full_name				like '%' + @p_keywords + '%'
					or	ag.relationship				like '%' + @p_keywords + '%'
					or	ag.guaranted_pct			like '%' + @p_keywords + '%'
					or	ag.remarks					like '%' + @p_keywords + '%'
				) ;

	select		ag.id
				,ag.guarantor_client_type
				,ag.full_name 'client_name'
				,ag.relationship			
				,ag.guaranted_pct		
				,ag.remarks			 
				,@rows_count 'rowcount'
	from		application_guarantor ag
	where		ag.application_no = @p_application_no
				and (
						ag.guarantor_client_type		like '%' + @p_keywords + '%'
						or	ag.full_name				like '%' + @p_keywords + '%'
						or	ag.relationship				like '%' + @p_keywords + '%'
						or	ag.guaranted_pct			like '%' + @p_keywords + '%'
						or	ag.remarks					like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then ag.guarantor_client_type
														when 2 then ag.full_name
														when 3 then ag.relationship
														when 4 then cast(ag.guaranted_pct as sql_variant)		
														when 5 then ag.remarks		
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then ag.guarantor_client_type
														when 2 then ag.full_name
														when 3 then ag.relationship
														when 4 then cast(ag.guaranted_pct as sql_variant)		
														when 5 then ag.remarks			
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;

