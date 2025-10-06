--created by, Rian at 11/05/2023	

CREATE PROCEDURE dbo.xsp_application_survey_plan_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	--
	,@p_application_survey_code	   nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.application_survey_plan asp
	where	asp.application_survey_code = @p_application_survey_code
			and (
					asp.description										like '%' + @p_keywords + '%'
					or	asp.ni_amount									like '%' + @p_keywords + '%'
				) ;

	select		asp.id
			   ,asp.application_survey_code
			   ,asp.description
			   ,asp.ni_amount
			   ,@rows_count 'rowcount'
	from		dbo.application_survey_plan asp
	where		asp.application_survey_code = @p_application_survey_code
				and (
					asp.description										like '%' + @p_keywords + '%'
					or	asp.ni_amount									like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then asp.description
													 when 2 then cast(asp.ni_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then asp.description
														when 2 then cast(asp.ni_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
