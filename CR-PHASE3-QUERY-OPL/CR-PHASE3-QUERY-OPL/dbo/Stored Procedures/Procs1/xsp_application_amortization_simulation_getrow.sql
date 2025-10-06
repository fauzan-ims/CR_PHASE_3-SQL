
CREATE procedure [dbo].[xsp_application_amortization_simulation_getrow]
(
	@p_application_simulation_code nvarchar(50)
	,@p_installment_no			   int
)
as
begin
	select	application_simulation_code
			,installment_no
			,due_date
			,principal_amount
			,installment_amount
			,installment_principal_amount
			,installment_interest_amount
			,os_principal_amount
			,os_interest_amount
	from	application_amortization_simulation
	where	application_simulation_code = @p_application_simulation_code
			and installment_no			= @p_installment_no ;
end ;

