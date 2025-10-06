CREATE procedure dbo.xsp_insurance_policy_main_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	ipm.code
			,ipm.sppa_code
			,ipm.branch_code
			,ipm.branch_name
			,ipm.policy_status
			,ipm.policy_payment_status
			,ipm.insured_name
			,ipm.insured_qq_name
			,case ipm.policy_payment_type
				 when 'FTFP' then 'Full Tenor Full Payment'
				 when 'FTAP' then 'Full Tenor Annually Payment'
				 else 'Annually Tenor Annually Payment'
			 end							'policy_payment_type'
			,ipm.object_name
			--,ipm.sum_insured
			,ipm.insurance_code
			,ipm.insurance_type
			,ipm.currency_code
			,ipm.cover_note_no
			,ipm.cover_note_date
			,ipm.policy_no
			,ipm.policy_eff_date
			,ipm.policy_exp_date
			,ipm.file_name
			,ipm.paths
			,ipm.invoice_no
			,ipm.invoice_date
			,ipm.from_year
			,ipm.to_year
			,ipm.total_premi_buy_amount
			,ipm.total_discount_amount
			,ipm.total_net_premi_amount
			,ipm.stamp_fee_amount
			,ipm.admin_fee_amount
			,ipm.total_adjusment_amount
			,ipm.is_policy_existing
			,ipm.endorsement_count
			,mi.insurance_name
			--,dbo.xfn_get_ppn(total_discount_amount) 'ppn_amount'
			--,dbo.xfn_get_pph(total_discount_amount) 'pph_amount'
			,isnull(coverage.ppn_amount, 0) 'ppn_amount'
			,isnull(coverage.pph_amount, 0) 'pph_amount'
			,ipm.source_type
			,ipm.faktur_no
			,ipm.faktur_date
	from	insurance_policy_main		   ipm
			left join dbo.master_insurance mi on (mi.code = ipm.insurance_code)
			outer apply
	(
		select	sum(initial_discount_ppn)  'ppn_amount'
				,sum(initial_discount_pph) 'pph_amount'
		from	dbo.insurance_policy_asset_coverage	  ipac
				inner join dbo.insurance_policy_asset ipa on (ipa.code = ipac.register_asset_code)
		where	ipa.policy_code		   = ipm.code
				--and (ipac.COVERAGE_TYPE = 'NEW' or ipac.COVERAGE_TYPE is null)
				and ipac.sppa_code = ipm.sppa_code
	)									   coverage
	where	ipm.code = @p_code ;
end ;
