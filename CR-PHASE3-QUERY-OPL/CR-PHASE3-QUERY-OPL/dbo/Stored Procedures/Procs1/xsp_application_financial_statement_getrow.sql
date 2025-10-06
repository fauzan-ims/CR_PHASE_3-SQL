CREATE procedure [dbo].[xsp_application_financial_statement_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	declare @detail_count int ;

	select	@detail_count = count(1)
	from	dbo.application_financial_statement_detail
	where	financial_statement_code = @p_code ;

	select	code
			,code 'financial_statement_code'
			,application_code
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
			,@detail_count 'detail_count'
	from	application_financial_statement
	where	code = @p_code ;
end ;

