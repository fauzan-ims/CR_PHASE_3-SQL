CREATE procedure [dbo].[xsp_inquiry_client_getrow]
(
	@p_client_no nvarchar(50)
)
as
begin
	select	distinct
			cm.client_no
			,cm.client_name
			,isnull(agreement_asset.total_asset, 0) 'total_asset'
			,isnull(amortization.billing_amount, 0) 'billing_amount'
			,isnull(obligation.overdue, 0)			'overdue'
	from	dbo.client_main cm
			outer apply
	(
		select		count(1) 'total_asset'
					,am.client_no
		from		dbo.agreement_asset			  aa
					inner join dbo.agreement_main am on am.agreement_no = aa.agreement_no
		where		am.client_no = cm.client_no
		group by	am.client_no
	)						agreement_asset
			outer apply
	(
		select	sum(aaa.billing_amount) 'billing_amount'
		from	dbo.agreement_asset_amortization aaa
				inner join dbo.agreement_asset	 aa on aa.asset_no	   = aaa.asset_no
				inner join dbo.agreement_main	 am on am.agreement_no = aa.agreement_no
		where	am.client_no = cm.client_no
	) amortization
			outer apply
	(
		select	sum(obligation_amount - payment_amount) 'overdue'
		from	dbo.agreement_obligation	  ao
				inner join dbo.AGREEMENT_MAIN am on am.AGREEMENT_NO = ao.AGREEMENT_NO
				outer apply
		(
			select	isnull(sum(aop.payment_amount), 0) payment_amount
			from	dbo.agreement_obligation_payment aop
			where	aop.obligation_code = ao.code
		)									  aop
		where	am.client_no		= cm.client_no
				and obligation_type = 'OVDP'
				and ao.cre_by		<> 'MIGRASI'
	) obligation
	where	cm.client_no = @p_client_no ;
end ;
