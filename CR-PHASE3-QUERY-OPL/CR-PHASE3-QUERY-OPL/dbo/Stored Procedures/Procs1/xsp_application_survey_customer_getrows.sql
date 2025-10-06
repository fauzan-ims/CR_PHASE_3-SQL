--created by, Rian at 11/05/2023	

CREATE PROCEDURE dbo.xsp_application_survey_customer_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	--
	,@p_application_survey_code	   nvarchar(15)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.application_survey_customer apsc
	where	apsc.application_survey_code = @p_application_survey_code
			and (
					apsc.name							like '%' + @p_keywords + '%'
					or	apsc.business					like '%' + @p_keywords + '%'
					or	apsc.business_location			like '%' + @p_keywords + '%'
					or	apsc.unit						like '%' + @p_keywords + '%'
					or	apsc.additional_info			like '%' + @p_keywords + '%'
				) ;

	select		apsc.id
			   ,apsc.application_survey_code
			   ,apsc.name
			   ,apsc.business
			   ,apsc.business_location
			   ,apsc.unit
			   ,apsc.additional_info
			   ,@rows_count	 'rowcount'
	from		dbo.application_survey_customer apsc
	where		apsc.application_survey_code = @p_application_survey_code
				and (
						apsc.name							like '%' + @p_keywords + '%'
						or	apsc.business					like '%' + @p_keywords + '%'
						or	apsc.business_location			like '%' + @p_keywords + '%'
						or	apsc.unit						like '%' + @p_keywords + '%'
						or	apsc.additional_info			like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then apsc.name
													 when 2 then apsc.business
													 when 3 then apsc.business_location
													 when 4 then cast(apsc.unit as sql_variant)
													 when 5 then apsc.additional_info
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then apsc.name
														when 2 then apsc.business
														when 3 then apsc.business_location
														when 4 then cast(apsc.unit as sql_variant)
														when 5 then apsc.additional_info
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
