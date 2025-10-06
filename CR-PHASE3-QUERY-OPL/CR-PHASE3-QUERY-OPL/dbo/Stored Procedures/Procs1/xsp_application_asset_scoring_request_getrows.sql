CREATE PROCEDURE dbo.xsp_application_asset_scoring_request_getrows
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	,@p_asset_no	 nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	application_asset_scoring_request
	where	asset_no = @p_asset_no
			and (
					code												like '%' + @p_keywords + '%'
					or	convert(varchar(30), scoring_date, 103)			like '%' + @p_keywords + '%'
					or	scoring_status									like '%' + @p_keywords + '%'
					or	scoring_remarks									like '%' + @p_keywords + '%'
					or	convert(varchar(30), scoring_result_date, 103)	like '%' + @p_keywords + '%'
					or	scoring_result_value							like '%' + @p_keywords + '%'
					or	scoring_result_grade							like '%' + @p_keywords + '%'
					or	scoring_result_remarks							like '%' + @p_keywords + '%'
				) ;
 
		select		code
					,convert(varchar(30), scoring_date, 103) 'scoring_date'
					,scoring_status
					,scoring_remarks
					,convert(varchar(30), scoring_result_date, 103) 'scoring_result_date'
					,scoring_result_value
					,scoring_result_grade
					,scoring_result_remarks
					,@rows_count 'rowcount'
		from		application_asset_scoring_request
		where		asset_no = @p_asset_no
					and (
							code												like '%' + @p_keywords + '%'
							or	convert(varchar(30), scoring_date, 103)			like '%' + @p_keywords + '%'
							or	scoring_status									like '%' + @p_keywords + '%'
							or	scoring_remarks									like '%' + @p_keywords + '%'
							or	convert(varchar(30), scoring_result_date, 103)	like '%' + @p_keywords + '%'
							or	scoring_result_value							like '%' + @p_keywords + '%'
							or	scoring_result_grade							like '%' + @p_keywords + '%'
							or	scoring_result_remarks							like '%' + @p_keywords + '%'
						) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
											when 1 then code
													when 2 then cast(scoring_date as sql_variant)
													when 3 then scoring_remarks
													when 4 then cast(scoring_result_date as sql_variant)
													when 5 then scoring_result_value
													when 6 then scoring_result_grade
													when 7 then scoring_result_remarks
													when 8 then scoring_status
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
											when 1 then code
													when 2 then cast(scoring_date as sql_variant)
													when 3 then scoring_remarks
													when 4 then cast(scoring_result_date as sql_variant)
													when 5 then scoring_result_value
													when 6 then scoring_result_grade
													when 7 then scoring_result_remarks
													when 8 then scoring_status
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

