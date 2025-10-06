CREATE PROCEDURE dbo.xsp_insurance_existing_lookup_for_register
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.insurance_register_existing 
	where	(
					policy_no										like '%' + @p_keywords + '%'
					or	convert(varchar(30), policy_eff_date, 103)	like '%' + @p_keywords + '%'
					or	convert(varchar(30), policy_exp_date, 103)	like '%' + @p_keywords + '%'
			) ;

	select	policy_code
			,policy_no
			,convert(varchar(30), policy_eff_date, 103) 'policy_eff_date'
			,convert(varchar(30), policy_exp_date, 103) 'policy_exp_date'
			,@rows_count 'rowcount'
	from	dbo.insurance_register_existing 
	where	(
				policy_no										like '%' + @p_keywords + '%'
				or	convert(varchar(30), policy_eff_date, 103)	like '%' + @p_keywords + '%'
				or	convert(varchar(30), policy_exp_date, 103)	like '%' + @p_keywords + '%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then policy_no
													 when 2 then cast(policy_eff_date as sql_variant)
													 when 3 then cast(policy_exp_date as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													    when 1 then policy_no
														when 2 then cast(policy_eff_date as sql_variant)
														when 3 then cast(policy_exp_date as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
