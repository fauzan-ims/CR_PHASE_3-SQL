CREATE PROCEDURE [dbo].[xsp_application_main_getrow_by_client]
(
	@p_client_no nvarchar(50)
)
as
begin
	select	am.application_external_no --'agreement no'
			,am.branch_name
			,convert(varchar(30), am.application_date, 103) 'application_date'
			--
			,tc.tenor
			,am.currency_code --'currency'
			--
			,mf.description 'facility_name'--'facility' -- join ke master
			,am.purpose_loan_name 'purpose_loan_name'--'purpose loan' -- join ke master
			,am.purpose_loan_detail_name 'purpose_loan_detail_name'--'purpose loan detail' -- join ke master
			--
			,am.asset_value
			,am.dp_amount
			,tc.dp_pct --'dp pct'
			--
			,am.loan_amount
			,am.capitalize_amount
			,am.financing_amount
			--
			,tc.first_payment_type -- casting advance/ arrear
			,tc.interest_type
			,tc.interest_rate_type
			--
			,tc.interest_eff_rate_after_rounding 'eff_rate'
			,tc.interest_flat_rate_after_rounding 'flat_rate'
			,tc.installment_amount
	from	application_main am
			left join dbo.application_tc tc on (tc.application_no = am.application_no)
			left join dbo.master_facility mf on (mf.code = am.facility_code)
			left join dbo.client_main cm on (cm.code			 = am.client_code)
	where	am.client_code = @p_client_no ; -- pakai client_no dari cms
end ;

