CREATE PROCEDURE [dbo].[xsp_application_asset_budget_getrows] 
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_asset_no   nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	application_asset_budget aab
			left join dbo.master_budget_cost mbc on (mbc.code = aab.cost_code)
	where	asset_no = @p_asset_no
			and (
					mbc.description					like '%' + @p_keywords + '%'
					or	cost_amount_yearly			like '%' + @p_keywords + '%'
					or	aab.budget_amount			like '%' + @p_keywords + '%'
					or	case aab.is_subject_to_purchase
							when '1' then 'Yes'
							else 'No'
						end								like '%' + @p_keywords + '%'
				)

	select		aab.id
				,aab.asset_no
				,aab.cost_code
				,aab.cost_type
				,mbc.bill_periode
				,aab.cost_amount_monthly
				,aab.cost_amount_yearly
				,aab.budget_adjustment_amount
				,aab.budget_amount
				,mbc.description
				,case aab.is_subject_to_purchase
						when '1' then 'Yes'
						else 'No'
					end 'is_subject_to_purchase' 
				,@rows_count as 'rowcount'
	from		application_asset_budget aab
				left join dbo.master_budget_cost mbc on (mbc.code = aab.cost_code)
	where		asset_no = @p_asset_no
				and (
						mbc.description						like '%' + @p_keywords + '%'
						or	cost_amount_yearly				like '%' + @p_keywords + '%'
						or	aab.budget_amount				like '%' + @p_keywords + '%'
						or	case aab.is_subject_to_purchase
								when '1' then 'Yes'
								else 'No'
							end								like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then mbc.description
													 when 2 then cast(cost_amount_yearly as sql_variant)
													 when 3 then cast(budget_amount as sql_variant)
													 when 4 then aab.is_subject_to_purchase
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then mbc.description
													 when 2 then cast(cost_amount_yearly as sql_variant)
													 when 3 then cast(budget_amount as sql_variant)
													 when 4 then aab.is_subject_to_purchase
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
