--created by, Rian at 11/05/2023	

CREATE PROCEDURE dbo.xsp_master_budget_detail_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	--
	,@p_budget_code	   nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.master_budget_detail mbd
	where	mbd.budget_code = @p_budget_code
			and (
					mbd.budget_code										like '%' + @p_keywords + '%'
					or	mbd.cycle										like '%' + @p_keywords + '%'
					or	mbd.base_calculate								like '%' + @p_keywords + '%'
					or	mbd.budget_rate									like '%' + @p_keywords + '%'
					or	convert(varchar(30), mbd.eff_date, 103)			like '%' + @p_keywords + '%'
				) ;

	select		mbd.id
			   ,mbd.budget_code
			   ,convert(varchar(30), mbd.eff_date, 103) 'effective_date'
			   ,mbd.budget_rate
			   ,mbd.base_calculate
			   ,case mbd.cycle	when 'YEARLY' then 'YEARLY & END PERIODE'
								when 'MONTHLY' then 'MONTHLY'
								when 'IN FRONT' then 'IN FRONT'
								when 'END PERIODE' then 'END PERIODE'
			   end 'cycle'
			   ,@rows_count 'rowcount'
	from		dbo.master_budget_detail mbd
	where		mbd.budget_code = @p_budget_code
				and (
						mbd.budget_code										like '%' + @p_keywords + '%'
						or	mbd.cycle										like '%' + @p_keywords + '%'
						or	mbd.base_calculate								like '%' + @p_keywords + '%'
						or	mbd.budget_rate									like '%' + @p_keywords + '%'
						or	convert(varchar(30), mbd.eff_date, 103)			like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then cast(mbd.eff_date as sql_variant)
													 when 2 then mbd.budget_rate
													 when 3 then mbd.base_calculate
													 when 4 then mbd.cycle
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then cast(mbd.eff_date as sql_variant)
														when 2 then mbd.budget_rate
														when 3 then mbd.base_calculate
														when 4 then mbd.cycle
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
