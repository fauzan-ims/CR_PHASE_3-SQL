CREATE PROCEDURE dbo.xsp_application_financial_analysis_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,application_no
			,periode_year
			,periode_month
			,case periode_month
				 when 1 then 'January'
				 when 2 then 'February'
				 when 3 then 'March'
				 when 4 then 'April'
				 when 5 then 'May'
				 when 6 then 'June'
				 when 7 then 'July'
				 when 8 then 'August'
				 when 9 then 'September'
				 when 10 then 'October'
				 when 11 then 'November'
				 when 12 then 'December'
			 end as 'periode_months'
			,isnull(incom.income_amount,0) 'income_amount'
			,isnull(expne.expense_amount,0) 'expense_amount'
			,isnull(incom.income_amount,0) - isnull(expne.expense_amount,0) 'differential'
	from	application_financial_analysis afa
			outer apply (select sum(income_amount) 'income_amount' from dbo.application_financial_analysis_income where application_financial_analysis_code = afa.code) incom
			outer apply (select sum(expense_amount) 'expense_amount' from dbo.application_financial_analysis_expense where application_financial_analysis_code = afa.code) expne
	where	code = @p_code ;
end ;
