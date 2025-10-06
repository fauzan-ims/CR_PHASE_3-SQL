CREATE PROCEDURE [dbo].[xsp_master_budget_cost_getrows]
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_budget_cost
	where	code not in
				(
				N'MBDC.2208.000001',
				N'MBDC.2211.000001',
				N'MBDC.2211.000003',
				N'MBDC.2301.000001'
				)
			and (
					description								like '%' + @p_keywords + '%'
					or	class_code							like '%' + @p_keywords + '%'
					or	class_description					like '%' + @p_keywords + '%'
					or	convert(varchar(30), exp_date, 103)	like '%' + @p_keywords + '%'
					or	case is_subject_to_purchase
							when '1' then 'Yes'
							else 'No'
						end									like '%' + @p_keywords + '%'
					or	case is_active
							when '1' then 'Yes'
							else 'No'
						end									like '%' + @p_keywords + '%'
				) ;

	select		code
				,description
				,cost_type
				,bill_periode
				,class_code
				,class_description
				,convert(varchar(30), exp_date, 103) 'exp_date'
				,case is_subject_to_purchase
					 when '1' then 'Yes'
					 else 'No'
				 end 'is_subject_to_purchase'
				,case is_active
					 when '1' then 'Yes'
					 else 'No'
				 end 'is_active'
				,@rows_count as 'rowcount'
	from		master_budget_cost
	where		code not in
					(
					N'MBDC.2208.000001',
					N'MBDC.2211.000001',
					N'MBDC.2211.000003',
					N'MBDC.2301.000001'
					)
				and (
						description								like '%' + @p_keywords + '%'
						or	class_code							like '%' + @p_keywords + '%'
						or	class_description					like '%' + @p_keywords + '%'
						or	convert(varchar(30), exp_date, 103)	like '%' + @p_keywords + '%'
						or	case is_subject_to_purchase
								when '1' then 'Yes'
								else 'No'
							end									like '%' + @p_keywords + '%'
						or	case is_active
								when '1' then 'Yes'
								else 'No'
							end									like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then description
													 when 3 then class_description
													 when 4 then cast(exp_date as sql_variant)
													 when 5 then case is_subject_to_purchase
																	 when '1' then 'Yes'
																	 else 'No'
																 end
													 when 6 then case is_active
																	 when '1' then 'Yes'
																	 else 'No'
																 end
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then code
													 when 2 then description
													 when 3 then class_description
													 when 4 then cast(exp_date as sql_variant)
													 when 5 then case is_subject_to_purchase
																	 when '1' then 'Yes'
																	 else 'No'
																 end
													 when 6 then case is_active
																	 when '1' then 'Yes'
																	 else 'No'
																 end
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
