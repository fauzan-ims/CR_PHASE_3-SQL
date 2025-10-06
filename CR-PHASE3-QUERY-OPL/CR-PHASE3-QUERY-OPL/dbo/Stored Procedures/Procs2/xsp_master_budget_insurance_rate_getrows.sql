--created by, Rian at 11/05/2023	

CREATE PROCEDURE dbo.xsp_master_budget_insurance_rate_getrows
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
	from	dbo.master_budget_insurance_rate mbir
	where		(
					mbir.code										like '%' + @p_keywords + '%'
					or	convert(varchar(15), mbir.exp_date,103)		like '%' + @p_keywords + '%'
					or	mbir.vehicle_type_description				like '%' + @p_keywords + '%'
					or	mbir.coverage_description					like '%' + @p_keywords + '%'
					or	case mbir.is_active
							when '1' then 'Yes'
							else 'No'
						end 										like '%' + @p_keywords + '%'
				) ;

	select		mbir.code
				,convert(varchar(15), mbir.exp_date,103) 'exp_date'
				,mbir.vehicle_type_code
				,mbir.vehicle_type_description
				,mbir.coverage_code
				,mbir.coverage_description
				,case mbir.is_active
					when '1' then 'Yes'
				 else 'No'
				end 	'is_active'
				,@rows_count 'rowcount'
	from		dbo.master_budget_insurance_rate mbir
	where		(
					mbir.code										like '%' + @p_keywords + '%'
					or	convert(varchar(15), mbir.exp_date,103)		like '%' + @p_keywords + '%'
					or	mbir.vehicle_type_description				like '%' + @p_keywords + '%'
					or	mbir.coverage_description					like '%' + @p_keywords + '%'
					or	case mbir.is_active
							when '1' then 'Yes'
							else 'No'
						end 										like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then mbir.code
													 when 2 then mbir.vehicle_type_description
													 when 3 then mbir.coverage_description
													 when 4 then cast(mbir.exp_date as sql_variant)
													 when 5 then mbir.is_active
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then mbir.code
														when 2 then mbir.vehicle_type_description
														when 3 then mbir.coverage_description
														when 4 then cast(mbir.exp_date as sql_variant)
														when 5 then mbir.is_active
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
