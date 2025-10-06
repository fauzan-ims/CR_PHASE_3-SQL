--created by, Rian at 05/06/2023	

CREATE procedure xsp_master_budget_insurance_rate_detail_getrows
(
	@p_keywords						nvarchar(50)
	,@p_pagenumber					int
	,@p_rowspage					int
	,@p_order_by					int
	,@p_sort_by						nvarchar(5)
	--
	,@p_budget_insurance_rate_code	nvarchar(15)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.master_budget_insurance_rate_detail ird
	where	ird.budget_insurance_rate_code = @p_budget_insurance_rate_code
			and (
					ird.ID									like '%' + @p_keywords + '%'
					or	ird.BUDGET_INSURANCE_RATE_CODE		like '%' + @p_keywords + '%'
					or	ird.SUM_INSURED_FROM				like '%' + @p_keywords + '%'
					or	ird.SUM_INSURED_TO					like '%' + @p_keywords + '%'
					or	ird.REGION_DESCRIPTION				like '%' + @p_keywords + '%'
					or	ird.RATE_1							like '%' + @p_keywords + '%'
					or	ird.RATE_2							like '%' + @p_keywords + '%'
					or	ird.RATE_3							like '%' + @p_keywords + '%'
					or	ird.RATE_4							like '%' + @p_keywords + '%'
				) ;

	select		ird.id
				,ird.budget_insurance_rate_code
				,ird.sum_insured_from
				,ird.sum_insured_to
				,ird.region_code
				,ird.region_description
				,ird.rate_1
				,ird.rate_2
				,ird.rate_3
				,ird.rate_4
				,@rows_count 'rowcount'
	from		dbo.master_budget_insurance_rate_detail ird
	where		ird.budget_insurance_rate_code = @p_budget_insurance_rate_code
				and (
						ird.ID									like '%' + @p_keywords + '%'
						or	ird.BUDGET_INSURANCE_RATE_CODE		like '%' + @p_keywords + '%'
						or	ird.SUM_INSURED_FROM				like '%' + @p_keywords + '%'
						or	ird.SUM_INSURED_TO					like '%' + @p_keywords + '%'
						or	ird.REGION_DESCRIPTION				like '%' + @p_keywords + '%'
						or	ird.RATE_1							like '%' + @p_keywords + '%'
						or	ird.RATE_2							like '%' + @p_keywords + '%'
						or	ird.RATE_3							like '%' + @p_keywords + '%'
						or	ird.RATE_4							like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then cast(ird.sum_insured_from as sql_variant)
													 when 2 then cast(ird.sum_insured_to as sql_variant)
													 when 3 then ird.region_description
													 when 4 then cast(ird.rate_1 as sql_variant)
													 when 5 then cast(ird.rate_2 as sql_variant)
													 when 6 then cast(ird.rate_3 as sql_variant)
													 when 7 then cast(ird.rate_4 as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then cast(ird.sum_insured_from as sql_variant)
														when 2 then cast(ird.sum_insured_to as sql_variant)
														when 3 then ird.region_description
														when 4 then cast(ird.rate_1 as sql_variant)
														when 5 then cast(ird.rate_2 as sql_variant)
														when 6 then cast(ird.rate_3 as sql_variant)
														when 7 then cast(ird.rate_4 as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
