
CREATE procedure [dbo].[xsp_application_financial_analysis_expense_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,application_financial_analysis_code
			,expense_type
			,expense_amount
			,remarks
	from	application_financial_analysis_expense
	where	id = @p_id ;
end ;

