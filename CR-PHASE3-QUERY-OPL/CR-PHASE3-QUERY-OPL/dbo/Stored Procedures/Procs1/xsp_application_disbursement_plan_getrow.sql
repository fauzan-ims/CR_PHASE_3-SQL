CREATE PROCEDURE [dbo].[xsp_application_disbursement_plan_getrow]
(
	@p_code							  nvarchar(50)
	,@p_application_disbursement_plan nvarchar(50) = null
)
as
begin
	select	code
			,application_no
			,disbursement_to
			,calculate_by
			,disbursement_pct
			,disbursement_amount
			,plan_date
			,remarks
			,remarks 'disbursement_remarks'
			,bank_code
			,bank_name
			,bank_account_no
			,bank_account_name
			,currency_code
	from	application_disbursement_plan
	where	code = isnull(@p_code, @p_application_disbursement_plan) ;
end ;

