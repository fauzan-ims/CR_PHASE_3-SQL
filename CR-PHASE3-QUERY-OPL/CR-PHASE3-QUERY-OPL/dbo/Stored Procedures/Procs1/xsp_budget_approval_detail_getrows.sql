CREATE PROCEDURE dbo.xsp_budget_approval_detail_getrows
(
	@p_keywords				   nvarchar(50)
	,@p_pagenumber			   int
	,@p_rowspage			   int
	,@p_order_by			   int
	,@p_sort_by				   nvarchar(5)
	,@p_budget_approval_code   nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	budget_approval_detail bad
			inner join dbo.master_budget_cost mbc on (mbc.code = bad.cost_code)
	where	bad.budget_approval_code = @p_budget_approval_code
			and (
					mbc.description			like '%' + @p_keywords + '%'
					or	mbc.bill_periode	like '%' + @p_keywords + '%'
					or	cost_amount_monthly like '%' + @p_keywords + '%'
					or	cost_amount_yearly	like '%' + @p_keywords + '%'
				) ;

	select		bad.id
				,bad.budget_approval_code
				,bad.cost_code
				,bad.cost_type
				,mbc.bill_periode
				,bad.cost_amount_monthly
				,bad.cost_amount_yearly
				,mbc.description
				,@rows_count as 'rowcount'
	from		budget_approval_detail bad
				inner join dbo.master_budget_cost mbc on (mbc.code = bad.cost_code)
	where		bad.budget_approval_code = @p_budget_approval_code
				and (
						mbc.description			like '%' + @p_keywords + '%'
						or	mbc.bill_periode	like '%' + @p_keywords + '%'
						or	cost_amount_monthly like '%' + @p_keywords + '%'
						or	cost_amount_yearly	like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then mbc.description
													 when 2 then mbc.bill_periode
													 when 3 then cast(cost_amount_yearly as sql_variant)
													 when 4 then cast(cost_amount_monthly as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then mbc.description
													   when 2 then mbc.bill_periode
													   when 3 then cast(cost_amount_yearly as sql_variant)
													   when 4 then cast(cost_amount_monthly as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
