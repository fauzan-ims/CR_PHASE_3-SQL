
CREATE procedure [dbo].[xsp_application_amortization_getrow]
(
	@p_application_no  nvarchar(50)
	,@p_installment_no int
)
as
begin
	select	application_no
			,installment_no
			,due_date
			,principal_amount
			,installment_amount
			,installment_principal_amount
			,installment_interest_amount
			,os_principal_amount
	from	application_amortization
	where	application_no	   = @p_application_no
			and installment_no = @p_installment_no ;
end ;

