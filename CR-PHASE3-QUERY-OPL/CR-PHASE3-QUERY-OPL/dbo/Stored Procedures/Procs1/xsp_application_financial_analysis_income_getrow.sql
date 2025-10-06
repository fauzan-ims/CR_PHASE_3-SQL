
CREATE procedure [dbo].[xsp_application_financial_analysis_income_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,application_financial_analysis_code
			,income_type_code
			,income_amount
			,net_income_pct
			,net_income_amount
			,remarks
	from	application_financial_analysis_income
	where	id = @p_id ;
end ;

