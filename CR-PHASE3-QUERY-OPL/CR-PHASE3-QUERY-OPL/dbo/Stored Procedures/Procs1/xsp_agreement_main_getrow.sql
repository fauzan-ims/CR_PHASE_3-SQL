CREATE PROCEDURE [dbo].[xsp_agreement_main_getrow]
(
	@p_agreement_no nvarchar(50)
)
as
begin
	declare @outstanding_deferred_income decimal(18, 2)
			,@ovd_amount				 decimal(18, 2)
			,@total_lease_amount		 decimal(18, 2)
			,@current_total_lease_amount decimal(18, 2) ;

	select	@total_lease_amount = sum(lease_rounded_amount)
	from	dbo.agreement_asset
	where	agreement_no	 = @p_agreement_no ;

	select	@current_total_lease_amount = sum(lease_rounded_amount)
	from	dbo.AGREEMENT_ASSET
	where	AGREEMENT_NO	 = @p_agreement_no
			and ASSET_STATUS = 'RENTED' ;

	select	@outstanding_deferred_income = sum(income_amount)
	from	dbo.agreement_asset_interest_income
	where	agreement_no = @p_agreement_no ;

	--(+) raffyanda 20/10/2023 10:37 penambahan kolom ovd_amount
	select	@ovd_amount = sum(obligation_amount - payment_amount)
	from	dbo.agreement_obligation ao
			outer apply
	(
		select	isnull(sum(aop.payment_amount), 0) payment_amount
		from	dbo.agreement_obligation_payment aop
		where	aop.obligation_code = ao.code
	) aop
	where	agreement_no		= @p_agreement_no
			and obligation_type = 'OVDP' 
			and ao.cre_by <> 'MIGRASI'

	select	am.agreement_no
			,am.agreement_external_no
			,am.application_no
			,isnull(apm.application_external_no,am.application_no_external) 'application_external_no'
			,am.agreement_date
			,am.initial_branch_name
			,am.branch_name
			,am.agreement_status
			,am.client_name
			,am.termination_date
			,am.termination_status
			,am.facility_name
			,am.old_agreement_no
			,am.branch_code
			,am.initial_branch_code
			,am.facility_code
			,am.agreement_sub_status
			,am.collection_status
			,am.currency_code
			,am.client_type
			,am.client_no
			,am.tax_scheme_code
			,am.ppn_pct
			,am.pph_pct
			,am.payment_promise_date
			,am.maturity_code
			,case am.is_stop_billing
				 when '1' then 'Yes'
				 else 'No'
			 end 'is_stop_billing'
			,am.is_pending_billing
			,am.periode
			,mb.description 'billing_type'
			,am.credit_term
			,case
				 when am.first_payment_type = 'ADV' then 'ADVANCE'
				 when am.first_payment_type = 'ARR' then 'ARREAR'
				 else ''
			 end 'first_payment_type'
			,am.is_purchase_requirement_after_lease
			,am.lease_option
			,am.round_type
			,am.round_amount
			,am.facility_name
			,apm.application_remarks
			--,ass.lease_rounded_amount
			,am.marketing_name
			,@outstanding_deferred_income 'outstanding_deferred_income'
			,ai.ovd_days
			,am.client_id
			--(+) raffyanda 20/10/2023 10:37 penambahan kolom ovd_amount
			,isnull(@ovd_amount,0)'ovd_amount'
			,@total_lease_amount 'total_lease_amount'
			,@current_total_lease_amount 'current_total_lease_amount'
	from	agreement_main am
			left join dbo.master_billing_type mb on (mb.code		   = am.billing_type)
			left join dbo.application_main apm on (apm.application_no  = am.application_no)
			--left join dbo.agreement_asset ass on (ass.agreement_no	   = am.agreement_no)
			left join dbo.agreement_information ai on (ai.agreement_no = am.agreement_no)
			--left join dbo.agreement_obligation ao on (ao.agreement_no  = am.agreement_no)
	where	am.agreement_no = @p_agreement_no ;
end ;
