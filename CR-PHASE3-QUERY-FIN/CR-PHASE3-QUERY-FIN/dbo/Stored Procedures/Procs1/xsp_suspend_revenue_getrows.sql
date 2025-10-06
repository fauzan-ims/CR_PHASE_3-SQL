CREATE PROCEDURE dbo.xsp_suspend_revenue_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code	    nvarchar(50)
	,@p_revenue_status  nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	end
	select	@rows_count = count(1)
	from	suspend_revenue
	where	branch_code		   = case @p_branch_code
										 when 'ALL' then branch_code
										 else @p_branch_code
								 end
			and revenue_status = case @p_revenue_status
										 when 'ALL' then revenue_status
										 else @p_revenue_status
								 end
			and (
					code										like '%' + @p_keywords + '%'
					or	branch_name								like '%' + @p_keywords + '%'
					or	convert(varchar(30), revenue_date, 103)	like '%' + @p_keywords + '%'
					or	revenue_remarks							like '%' + @p_keywords + '%'
					or	revenue_amount							like '%' + @p_keywords + '%'
					or	revenue_status							like '%' + @p_keywords + '%'
				) ;

		select		code
					,branch_name
					,revenue_status
					,convert(varchar(30), revenue_date, 103) 'revenue_date'
					,revenue_amount
					,revenue_remarks
					,@rows_count 'rowcount'
		from		suspend_revenue
		where		branch_code		   = case @p_branch_code
												 when 'ALL' then branch_code
												 else @p_branch_code
										 end
					and revenue_status = case @p_revenue_status
												 when 'ALL' then revenue_status
												 else @p_revenue_status
										 end
					and (
							code										like '%' + @p_keywords + '%'
							or	branch_name								like '%' + @p_keywords + '%'
							or	convert(varchar(30), revenue_date, 103)	like '%' + @p_keywords + '%'
							or	revenue_remarks							like '%' + @p_keywords + '%'
							or	revenue_amount							like '%' + @p_keywords + '%'
							or	revenue_status							like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then code
														when 2 then branch_name								
														when 3 then cast(revenue_date as sql_variant)	
														when 4 then revenue_remarks							
														when 5 then cast(revenue_amount as nvarchar(20))							
														when 6 then revenue_status	
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then branch_name								
														when 3 then cast(revenue_date as sql_variant)	
														when 4 then revenue_remarks							
														when 5 then cast(revenue_amount as nvarchar(20))							
														when 6 then revenue_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
