CREATE PROCEDURE dbo.xsp_get_list_instalment_amount
(
	@p_agreement_no nvarchar(50)
	,@p_date		datetime
)
as
begin
	if exists
	(
		select	1
		from	dbo.agreement_main
		where	agreement_no			 = @p_agreement_no
				and agreement_sub_status <> 'WO'
	)
	begin
		select	ai.agreement_no
				,ai.billing_no
				,ai.billing_amount - aip.payment_amount 'agreement_amount'
				,ai.billing_amount - aip.payment_amount 'principal_amount'
		from	dbo.agreement_asset_amortization ai
				outer apply
		(
			select	isnull(sum(aip.payment_amount), 0) 'payment_amount'
			from	dbo.agreement_invoice_payment aip
			where	aip.agreement_no   = ai.agreement_no
					and aip.invoice_no = ai.invoice_no
					and aip.asset_no   = ai.asset_no
		) aip
		where	ai.agreement_no							   = @p_agreement_no
				and ai.due_date							   <= @p_date
				and ai.billing_amount - aip.payment_amount > 0 ;
	end ;
end ;
