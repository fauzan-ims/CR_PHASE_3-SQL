CREATE PROCEDURE [dbo].[xsp_application_survey_request_getrows]
(
	@p_keywords			 nvarchar(50)
	,@p_pagenumber		 int
	,@p_rowspage		 int
	,@p_order_by		 int
	,@p_sort_by			 nvarchar(5)
	,@p_application_no	 nvarchar(50)
	,@p_approval_summary nvarchar(1) = ''
)
as
begin
	declare @rows_count int = 0 ;
	if (@p_approval_summary <> '')
	begin
		select	@rows_count = count(1)
		from	application_survey_request
		where	application_no = @p_application_no
				and survey_status = 'POST'
				and (
						code												like '%' + @p_keywords + '%'
						or	convert(varchar(30), survey_date, 103)			like '%' + @p_keywords + '%'
						or	survey_status									like '%' + @p_keywords + '%'
						or	survey_remarks									like '%' + @p_keywords + '%'
						or	convert(varchar(30), survey_result_date, 103)	like '%' + @p_keywords + '%'
						or	survey_result_value								like '%' + @p_keywords + '%'
						or	survey_fee_amount								like '%' + @p_keywords + '%'
						or	currency_code									like '%' + @p_keywords + '%'
					) ;

		select		code
					,convert(varchar(30), survey_date, 103) 'survey_date'
					,survey_status
					,survey_remarks
					,convert(varchar(30), survey_result_date, 103) 'survey_result_date'
					,survey_result_value
					,survey_fee_amount
					,currency_code
					,@rows_count 'rowcount'
		from		application_survey_request
		where		application_no = @p_application_no
					and survey_status = 'POST'
					and (
							code												like '%' + @p_keywords + '%'
							or	convert(varchar(30), survey_date, 103)			like '%' + @p_keywords + '%'
							or	survey_status									like '%' + @p_keywords + '%'
							or	survey_remarks									like '%' + @p_keywords + '%'
							or	convert(varchar(30), survey_result_date, 103)	like '%' + @p_keywords + '%'
							or	survey_result_value								like '%' + @p_keywords + '%'
							or	survey_fee_amount								like '%' + @p_keywords + '%'
							or	currency_code									like '%' + @p_keywords + '%'
						)
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
															when 1 then code
															when 2 then cast(survey_date as sql_variant)
															when 3 then survey_remarks
															when 4 then currency_code + cast(survey_fee_amount as nvarchar(50))
															when 5 then cast(survey_result_date as sql_variant)
															when 6 then survey_result_value
															when 7 then survey_status
														end
					end asc
					,case
							when @p_sort_by = 'desc' then case @p_order_by
															when 1 then code
															when 2 then cast(survey_date as sql_variant)
															when 3 then survey_remarks
															when 4 then currency_code + cast(survey_fee_amount as nvarchar(50))
															when 5 then cast(survey_result_date as sql_variant)
															when 6 then survey_result_value
															when 7 then survey_status
														end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
	end
	else
	begin
		select	@rows_count = count(1)
		from	application_survey_request
		where	application_no = @p_application_no
				and (
						code												like '%' + @p_keywords + '%'
						or	convert(varchar(30), survey_date, 103)			like '%' + @p_keywords + '%'
						or	survey_status									like '%' + @p_keywords + '%'
						or	survey_remarks									like '%' + @p_keywords + '%'
						or	convert(varchar(30), survey_result_date, 103)	like '%' + @p_keywords + '%'
						or	survey_result_value								like '%' + @p_keywords + '%'
						or	survey_fee_amount								like '%' + @p_keywords + '%'
						or	currency_code									like '%' + @p_keywords + '%'
					) ;

		select		code
					,convert(varchar(30), survey_date, 103) 'survey_date'
					,survey_status
					,survey_remarks
					,convert(varchar(30), survey_result_date, 103) 'survey_result_date'
					,survey_result_value
					,survey_fee_amount
					,currency_code
					,@rows_count 'rowcount'
		from		application_survey_request
		where		application_no = @p_application_no
					and (
							code												like '%' + @p_keywords + '%'
							or	convert(varchar(30), survey_date, 103)			like '%' + @p_keywords + '%'
							or	survey_status									like '%' + @p_keywords + '%'
							or	survey_remarks									like '%' + @p_keywords + '%'
							or	convert(varchar(30), survey_result_date, 103)	like '%' + @p_keywords + '%'
							or	survey_result_value								like '%' + @p_keywords + '%'
							or	survey_fee_amount								like '%' + @p_keywords + '%'
							or	currency_code									like '%' + @p_keywords + '%'
						)
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
															when 1 then code
															when 2 then cast(survey_date as sql_variant)
															when 3 then survey_remarks
															when 4 then currency_code + cast(survey_fee_amount as nvarchar(50))
															when 5 then cast(survey_result_date as sql_variant)
															when 6 then survey_result_value
															when 7 then survey_status
														end
					end asc
					,case
							when @p_sort_by = 'desc' then case @p_order_by
															when 1 then code
															when 2 then cast(survey_date as sql_variant)
															when 3 then survey_remarks
															when 4 then currency_code + cast(survey_fee_amount as nvarchar(50))
															when 5 then cast(survey_result_date as sql_variant)
															when 6 then survey_result_value
															when 7 then survey_status
														end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;  
	end;
end ;

