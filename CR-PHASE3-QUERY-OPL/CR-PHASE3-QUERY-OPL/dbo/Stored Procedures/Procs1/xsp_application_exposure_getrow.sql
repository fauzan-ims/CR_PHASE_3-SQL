CREATE procedure dbo.xsp_application_exposure_getrow
(
	@p_application_no nvarchar(50)
)
as
begin
	declare @amountFinanceAmount   decimal(18, 2)
			,@osInstallmentAmount  decimal(18, 2)
			,@installmentAmount	   decimal(18, 2)
			,@ovdInstallmentAmount decimal(18, 2) ;

	select	@amountfinanceamount = isnull(sum(amount_finance_amount), 0)
			,@osinstallmentamount = isnull(sum(os_installment_amount), 0)
			,@installmentamount = isnull(sum(installment_amount), 0)
			,@ovdinstallmentamount = isnull(sum(ovd_installment_amount), 0)
	from	dbo.application_exposure
	where	application_no = @p_application_no ;

	select	id
			,application_no
			,relation_type
			,agreement_no
			,agreement_date
			,facility_name
			,amount_finance_amount
			,os_installment_amount
			,installment_amount
			,tenor
			,os_tenor
			,last_due_date
			,ovd_days
			,ovd_installment_amount
			,description
			,max_ovd_days
			,group_name
			,@amountfinanceamount 'amountFinanceAmount'
			,@osinstallmentamount 'osInstallmentAmount'
			,@installmentamount 'installmentAmount'
			,@ovdinstallmentamount 'ovdInstallmentAmount'
	from	dbo.application_exposure
	where	application_no = @p_application_no ;
end ;
