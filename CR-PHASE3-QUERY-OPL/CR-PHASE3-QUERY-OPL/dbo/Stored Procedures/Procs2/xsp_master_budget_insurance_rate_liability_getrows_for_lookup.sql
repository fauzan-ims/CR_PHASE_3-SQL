
--created by, Rian at 11/05/2023	

CREATE PROCEDURE dbo.xsp_master_budget_insurance_rate_liability_getrows_for_lookup
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	--
	,@p_type	   nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.master_budget_insurance_rate_liability irl
	where	irl.type = @p_type	
			and	irl.is_active = '1'
			and (
					irl.code										like '%' + @p_keywords + '%'
					or	convert(varchar(15), irl.exp_date,103)		like '%' + @p_keywords + '%'
					or	irl.TYPE									like '%' + @p_keywords + '%'
					or	irl.coverage_description					like '%' + @p_keywords + '%'
					or	irl.coverage_amount							like '%' + @p_keywords + '%'
					or	irl.rate_of_limit							like '%' + @p_keywords + '%'
					or	case irl.is_active
							when '1' then 'yes'
							else 'no'
						end 										like '%' + @p_keywords + '%'
				) ;

	select		irl.code
				,irl.type
				,irl.code 'coverage_code'
				,irl.coverage_description
				,irl.coverage_amount
				,irl.rate_of_limit
				,convert(varchar(15), irl.exp_date,103) 'exp_date'
				,case irl.is_active
						when '1' then 'Yes'
						else 'No'
					end  'is_active'
				,@rows_count 'rowcount'
	from		dbo.master_budget_insurance_rate_liability irl
	where		irl.type = @p_type
				and	irl.is_active = '1'
				and (
						irl.code										like '%' + @p_keywords + '%'
						or	convert(varchar(15), irl.exp_date,103)		like '%' + @p_keywords + '%'
						or	irl.TYPE									like '%' + @p_keywords + '%'
						or	irl.coverage_description					like '%' + @p_keywords + '%'
						or	irl.coverage_amount							like '%' + @p_keywords + '%'
						or	irl.rate_of_limit							like '%' + @p_keywords + '%'
						or	case irl.is_active
								when '1' then 'yes'
								else 'no'
							end 										like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then irl.code
													 when 2 then irl.coverage_description 
													 when 3 then cast(irl.coverage_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then irl.code 
														when 2 then irl.coverage_description 
														when 3 then cast(irl.coverage_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
