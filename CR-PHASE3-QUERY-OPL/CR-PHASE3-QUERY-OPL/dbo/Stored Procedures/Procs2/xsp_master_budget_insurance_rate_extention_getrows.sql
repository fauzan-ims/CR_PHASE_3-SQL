--created by, Rian at 11/05/2023	

CREATE PROCEDURE dbo.xsp_master_budget_insurance_rate_extention_getrows
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
	from	dbo.master_budget_insurance_rate_extention ire
	where		(
					ire.code										like '%' + @p_keywords + '%'
					or	convert(varchar(15), ire.exp_date,103)		like '%' + @p_keywords + '%'
					or	ire.coverage_description					like '%' + @p_keywords + '%'
					or	ire.tlo										like '%' + @p_keywords + '%'
					or	ire.region_description						like '%' + @p_keywords + '%'
					or	ire.compre									like '%' + @p_keywords + '%'
					or	case ire.is_active
							when '1' then 'yes'
							else 'no'
						end 										like '%' + @p_keywords + '%'
				) ;

	select		ire.code
			   ,ire.coverage_code
			   ,ire.coverage_description
			   ,convert(varchar(15), ire.exp_date,103) 'exp_date'
			   ,ire.tlo
			   ,ire.compre
			   ,ire.region_code
			   ,ire.region_description
				,case ire.is_active
				 	when '1' then 'Yes'
				 	else 'No'
				 end 'is_active'			
				,@rows_count 'rowcount'
	from		dbo.master_budget_insurance_rate_extention ire
	where		(
					ire.code										like '%' + @p_keywords + '%'
					or	convert(varchar(15), ire.exp_date,103)		like '%' + @p_keywords + '%'
					or	ire.coverage_description					like '%' + @p_keywords + '%'
					or	ire.tlo										like '%' + @p_keywords + '%'
					or	ire.region_description						like '%' + @p_keywords + '%'
					or	ire.compre									like '%' + @p_keywords + '%'
					or	case ire.is_active
							when '1' then 'yes'
							else 'no'
						end 										like '%' + @p_keywords + '%'
				) 
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ire.code
													 when 2 then ire.coverage_description
													 when 3 then cast(ire.compre as sql_variant)
													 when 4 then cast(ire.tlo as sql_variant)
													 when 5 then ire.region_description
													 when 6 then cast(ire.exp_date as sql_variant)
													 when 7 then ire.is_active
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then ire.code
														when 2 then ire.coverage_description
														when 3 then cast(ire.compre as sql_variant)
														when 4 then cast(ire.tlo as sql_variant)
														when 5 then ire.region_description
														when 6 then cast(ire.exp_date as sql_variant)
														when 7 then ire.is_active
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
