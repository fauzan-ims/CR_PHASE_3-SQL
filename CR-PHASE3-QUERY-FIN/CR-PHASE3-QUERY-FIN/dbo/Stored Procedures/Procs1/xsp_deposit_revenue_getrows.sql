CREATE PROCEDURE dbo.xsp_deposit_revenue_getrows
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_branch_code	   nvarchar(50)
	,@p_revenue_status nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	end
	select	@rows_count = count(1)
	from	deposit_revenue dr
			inner join agreement_main am on (am.agreement_no = dr.agreement_no)
	where	dr.branch_code		  = case @p_branch_code
										 when 'ALL' then dr.branch_code
										 else @p_branch_code
									end
			and dr.revenue_status = case @p_revenue_status
										 when 'ALL' then dr.revenue_status
										 else @p_revenue_status
									end
			and (
					dr.code											like '%' + @p_keywords + '%'
					or	dr.branch_name								like '%' + @p_keywords + '%'
					or	am.agreement_external_no					like '%' + @p_keywords + '%'
					or	am.client_name								like '%' + @p_keywords + '%'
					or	convert(varchar(30), dr.revenue_date, 103)	like '%' + @p_keywords + '%'
					or	dr.revenue_amount							like '%' + @p_keywords + '%'
					or	dr.revenue_status							like '%' + @p_keywords + '%'
				) ;

		select		dr.code
					,dr.branch_name								
					,am.agreement_external_no					
					,convert(varchar(30), dr.revenue_date, 103)	'revenue_date'
					,dr.revenue_amount							
					,dr.revenue_status	
					,@rows_count 'rowcount'
		from		deposit_revenue dr
					inner join agreement_main am on (am.agreement_no = dr.agreement_no)
		where		dr.branch_code		  = case @p_branch_code
												 when 'ALL' then dr.branch_code
												 else @p_branch_code
											end
					and dr.revenue_status = case @p_revenue_status
												 when 'ALL' then dr.revenue_status
												 else @p_revenue_status
											end
					and (
							dr.code											like '%' + @p_keywords + '%'
							or	dr.branch_name								like '%' + @p_keywords + '%'
							or	am.agreement_external_no					like '%' + @p_keywords + '%'
							or	am.client_name								like '%' + @p_keywords + '%'
							or	convert(varchar(30), dr.revenue_date, 103)	like '%' + @p_keywords + '%'
							or	dr.revenue_amount							like '%' + @p_keywords + '%'
							or	dr.revenue_status							like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then dr.code
														when 2 then dr.branch_name								
														when 3 then cast(dr.revenue_date as sql_variant)	
														when 4 then am.agreement_external_no					
														when 5 then cast(dr.revenue_amount as sql_variant)							
														when 6 then dr.revenue_status	
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then dr.code
														when 2 then dr.branch_name								
														when 3 then cast(dr.revenue_date as sql_variant)	
														when 4 then am.agreement_external_no					
														when 5 then cast(dr.revenue_amount as sql_variant)							
														when 6 then dr.revenue_status	
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
