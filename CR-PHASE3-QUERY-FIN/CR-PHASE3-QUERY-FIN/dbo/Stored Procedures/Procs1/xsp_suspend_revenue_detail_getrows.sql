CREATE PROCEDURE dbo.xsp_suspend_revenue_detail_getrows
(
	@p_keywords				 nvarchar(50)
	,@p_pagenumber			 int
	,@p_rowspage			 int
	,@p_order_by			 int
	,@p_sort_by				 nvarchar(5)
	,@p_suspend_revenue_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	suspend_revenue_detail srd
			inner join dbo.suspend_main sm on (sm.code = srd.suspend_code)
	where	suspend_revenue_code = @p_suspend_revenue_code
			and (
					srd.suspend_code								like '%' + @p_keywords + '%'
					or	convert(varchar(30), sm.suspend_date, 103)	like '%' + @p_keywords + '%'
					or	sm.suspend_remarks							like '%' + @p_keywords + '%'
					or	srd.suspend_amount							like '%' + @p_keywords + '%'
					or	sm.reff_no									like '%' + @p_keywords + '%'
					or	sm.reff_name								like '%' + @p_keywords + '%'
					or	srd.revenue_amount							like '%' + @p_keywords + '%'
				) ;

		select		srd.id
					,srd.suspend_code	
					,sm.suspend_remarks	
					,convert(varchar(30), sm.suspend_date, 103) 'suspend_date'
					,srd.suspend_amount	
					,srd.revenue_amount	
					,sm.reff_no			
					,sm.reff_name
					,@rows_count 'rowcount'
		from		suspend_revenue_detail srd
					inner join dbo.suspend_main sm on (sm.code = srd.suspend_code)
		where		suspend_revenue_code = @p_suspend_revenue_code
					and (
							srd.suspend_code								like '%' + @p_keywords + '%'
							or	convert(varchar(30), sm.suspend_date, 103)	like '%' + @p_keywords + '%'
							or	sm.suspend_remarks							like '%' + @p_keywords + '%'
							or	srd.suspend_amount							like '%' + @p_keywords + '%'
							or	sm.reff_no									like '%' + @p_keywords + '%'
							or	sm.reff_name								like '%' + @p_keywords + '%'
							or	srd.revenue_amount							like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then srd.suspend_code	
														when 2 then	sm.reff_no			
														when 3 then	cast(sm.suspend_date as sql_variant)	
														when 4 then sm.suspend_remarks	
														when 5 then	cast(srd.suspend_amount as sql_variant)	
														when 6 then	cast(srd.revenue_amount as sql_variant)	
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then srd.suspend_code	
														when 2 then	sm.reff_no			
														when 3 then	cast(sm.suspend_date as sql_variant)	
														when 4 then sm.suspend_remarks	
														when 5 then	cast(srd.suspend_amount as sql_variant)	
														when 6 then	cast(srd.revenue_amount as sql_variant)	
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
