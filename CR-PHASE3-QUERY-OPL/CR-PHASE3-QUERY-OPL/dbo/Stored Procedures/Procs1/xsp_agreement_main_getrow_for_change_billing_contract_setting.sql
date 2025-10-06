

CREATE PROCEDURE dbo.xsp_agreement_main_getrow_for_change_billing_contract_setting
(
	@p_agreement_no nvarchar(50)
	,@p_asset_no	nvarchar(50)
)
as
begin
	select		am.agreement_no
				,am.agreement_external_no
				,am.client_name
				,ast.billing_to
				,ast.billing_to_name
				,ast.billing_to_area_no
				,ast.billing_to_phone_no
				,ast.billing_to_address
				,ast.billing_to_npwp
				,ast.billing_to_faktur_type
				,ast.deliver_to
				,ast.deliver_to_name
				,ast.deliver_to_area_no
				,ast.deliver_to_phone_no
				,ast.deliver_to_address
				,ast.asset_no
				,ast.asset_name
				,ast.lease_rounded_amount 
				,ast.npwp_name
				,ast.npwp_address
				,ast.pickup_phone_area_no
				,ast.pickup_phone_no
				,ast.pickup_name
				,ast.pickup_address
				,ast.email
				,ast.is_auto_email
				,ast.fa_code
				,ast.fa_name
				,ast.fa_reff_no_01
				,ast.fa_reff_no_02
				,ast.fa_reff_no_03
				,convert(varchar(30), aaa.due_date, 103) 'due_date'
				,ast.is_invoice_deduct_pph
				,ast.is_receipt_deduct_pph
                ,ast.client_nitku
	from	dbo.agreement_main am 
			left join dbo.agreement_asset ast on (ast.agreement_no = am.agreement_no)
			outer apply
			(
				select	min(aaa.due_date) due_date
				from	dbo.agreement_asset_amortization aaa
				where	aaa.agreement_no = ast.agreement_no
						and aaa.asset_no = ast.asset_no
			) aaa
	where	am.agreement_no = @p_agreement_no
			and	ast.asset_no = @p_asset_no
end ;
