CREATE PROCEDURE dbo.xsp_application_financial_analysis_getrows
(
	@p_keywords		 NVARCHAR(50)
	,@p_pagenumber	 INT
	,@p_rowspage	 INT
	,@p_order_by	 INT
	,@p_sort_by		 NVARCHAR(5)
	,@p_application_no NVARCHAR(50)
)
AS
BEGIN
	DECLARE @rows_count INT = 0 ;

	SELECT	@rows_count = COUNT(1)
	FROM	application_financial_analysis
	WHERE	application_no = @p_application_no
			AND (
					periode_year						LIKE '%' + @p_keywords + '%'
					OR	CASE periode_month
							WHEN '01' THEN 'January'
							WHEN '02' THEN 'February'
							WHEN '03' THEN 'March'
							WHEN '04' THEN 'April'
							WHEN '05' THEN 'May'
							WHEN '06' THEN 'June'
							WHEN '07' THEN 'July'
							WHEN '08' THEN 'August'
							WHEN '09' THEN 'September'
							WHEN '10' THEN 'October'
							WHEN '11' THEN 'November'
							ELSE 'December'
						end								like '%' + @p_keywords + '%'
						--or	dsr_pct						like '%' + @p_keywords + '%'
						--or	idir_pct					like '%' + @p_keywords + '%'
						--or	dbr_pct						like '%' + @p_keywords + '%'
				) ;

		select		code
					,periode_year
					,case periode_month
					 	when '01' then 'January'
					 	when '02' then 'February'
					 	when '03' then 'March'
					 	when '04' then 'April'
					 	when '05' then 'May'
					 	when '06' then 'June'
					 	when '07' then 'July'
					 	when '08' then 'August'
					 	when '09' then 'September'
					 	when '10' then 'October'
					 	when '11' then 'November'
					 	else 'December'
					 end 'periode_month'
					--,dsr_pct
					--,idir_pct
					--,dbr_pct
					,isnull(incom.income_amount,0) 'income_amount'
					,isnull(expne.expense_amount,0) 'expense_amount'
					,isnull(incom.income_amount,0) - isnull(expne.expense_amount,0) 'differential'
					,@rows_count 'rowcount'
		from		application_financial_analysis afa
					outer apply (select sum(income_amount) 'income_amount' from dbo.application_financial_analysis_income where application_financial_analysis_code = afa.code) incom
					outer apply (select sum(expense_amount) 'expense_amount' from dbo.application_financial_analysis_expense where application_financial_analysis_code = afa.code) expne
		where		application_no = @p_application_no
					and (
							periode_year						like '%' + @p_keywords + '%'
							or	case periode_month
									when '01' then 'January'
									when '02' then 'February'
									when '03' then 'March'
									when '04' then 'April'
									when '05' then 'May'
									when '06' then 'June'
									when '07' then 'July'
									when '08' then 'August'
									when '09' then 'September'
									when '10' then 'October'
									when '11' then 'November'
									else 'December'
								end								like '%' + @p_keywords + '%'
							--	or	dsr_pct						like '%' + @p_keywords + '%'
							--	or	idir_pct					like '%' + @p_keywords + '%'
							--	or	dbr_pct						like '%' + @p_keywords + '%'
							)
		order by 	case  
						when @p_sort_by = 'asc' then case @p_order_by
														when 1 then cast(periode_year + periode_month as sql_variant)
														when 2 then incom.income_amount
														when 3 then expne.expense_amount
														when 4 then cast(incom.income_amount - expne.expense_amount as sql_variant)
														--when 2 then cast(dsr_pct as sql_variant)
														--when 3 then cast(idir_pct as sql_variant)
														--when 4 then cast(dbr_pct as sql_variant)
						  							end
					end asc 
					,case 
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then cast(periode_year + periode_month as sql_variant)
														when 2 then incom.income_amount
														when 3 then expne.expense_amount
														when 4 then cast(incom.income_amount - expne.expense_amount as sql_variant)
														--when 2 then cast(dsr_pct as sql_variant)
														--when 3 then cast(idir_pct as sql_variant)
														--when 4 then cast(dbr_pct as sql_variant)
						  							end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
