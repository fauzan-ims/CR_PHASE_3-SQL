CREATE PROCEDURE dbo.xsp_fin_interface_agreement_main_getrow
(
	@p_agreement_no nvarchar(50)
)
as
begin
	select	id
			,agreement_no
			,agreement_external_no
			,branch_code
			,branch_name
			,agreement_date
			,agreement_status
			,agreement_sub_status
			,currency_code
			,termination_date
			,termination_status
			,client_code
			,client_name
			,asset_description
			,collateral_description
			,last_paid_installment_no
			,overdue_period
			,is_remedial
			,is_wo
			,installment_amount
			,installment_due_date
			,overdue_days
			,job_status
			,failed_remarks
	from	fin_interface_agreement_main
	where	agreement_no = @p_agreement_no ;
end ;
