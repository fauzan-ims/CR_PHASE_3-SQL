--created by, Rian at 11/05/2023	

CREATE PROCEDURE [dbo].[xsp_application_survey_bank_detail_getrows]
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	--
	,@p_application_survey_bank_id	   nvarchar(15)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.application_survey_bank_detail asbd
	where	asbd.application_survey_bank_id = @p_application_survey_bank_id
			and (
					asbd.COMPANY					like '%' + @p_keywords + '%'
					or	asbd.monthly_amount			like '%' + @p_keywords + '%'
					or	asbd.average				like '%' + @p_keywords + '%'
					or	asbd.mutation_month			like '%' + @p_keywords + '%'
					or	asbd.mutation_year			like '%' + @p_keywords + '%'
				) ;

	select		asbd.id
				,asbd.application_survey_bank_id
				,asbd.company
				,asbd.monthly_amount
				,asbd.average
				-- (+) Ari 2023-09-19 ket : add mutation month & year
				,asbd.mutation_month 
				,asbd.mutation_year
				,@rows_count 'rowcount'
	from		dbo.application_survey_bank_detail asbd
	where		asbd.application_survey_bank_id = @p_application_survey_bank_id
				and (
						asbd.COMPANY					like '%' + @p_keywords + '%'
						or	asbd.monthly_amount			like '%' + @p_keywords + '%'
						or	asbd.average				like '%' + @p_keywords + '%'
						or	asbd.mutation_month			like '%' + @p_keywords + '%'
						or	asbd.mutation_year			like '%' + @p_keywords + '%'
					) 
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then asbd.COMPANY
													 when 2 then asbd.mutation_month
													 when 3 then asbd.mutation_year
													 when 4 then cast(asbd.MONTHLY_AMOUNT as sql_variant)
													 when 5 then cast(asbd.AVERAGE as sql_variant)
													 
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then asbd.COMPANY
														when 2 then asbd.mutation_month
														when 3 then asbd.mutation_year
														when 4 then cast(asbd.MONTHLY_AMOUNT as sql_variant)
														when 5 then cast(asbd.AVERAGE as sql_variant)
														
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
