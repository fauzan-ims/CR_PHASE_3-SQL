CREATE PROCEDURE dbo.xsp_fin_interface_agreement_amortization_payment_getrow
(
	@p_agreement_no nvarchar(50)
)
as
begin
	select	id
			,am.agreement_external_no
			,am.client_name
			,installment_no
			,payment_date
			,value_date
			,payment_source_type
			,payment_source_no
			,payment_amount
			,principal_amount
			,interest_amount
	from	fin_interface_agreement_amortization_payment fiaap
			left join dbo.agreement_main am on (am.agreement_no = fiaap.agreement_no)
	where	fiaap.agreement_no = @p_agreement_no ;
end ;
