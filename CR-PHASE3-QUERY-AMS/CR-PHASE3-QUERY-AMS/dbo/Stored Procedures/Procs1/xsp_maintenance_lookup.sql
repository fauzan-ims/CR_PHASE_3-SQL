CREATE PROCEDURE dbo.xsp_maintenance_lookup
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_company_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.maintenance
	where	company_code = @p_company_code
	and		status = 'POST'
	and		(
				code					like '%' + @p_keywords + '%' 
			) ;

	select		code
				,unit_code
				,unit_name
				,@rows_count 'rowcount'
	from		dbo.maintenance
	where		company_code = @p_company_code
	and			status = 'POST'
	and			(
					code					like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by	
														when 1 then code
					 								end
				end asc
				,case
					when @p_sort_by = 'desc' then case @p_order_by				
														when 1 then code
					 								end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;

end ;
