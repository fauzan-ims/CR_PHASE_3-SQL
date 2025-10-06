CREATE PROCEDURE dbo.xsp_insurance_payment_schedule_renewal_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	ipsr.code
			,ipm.branch_name
			,ipsr.payment_renual_status
			,ipsr.policy_code
			,ipsr.year_period
			,ipsr.policy_eff_date
			,ipsr.policy_exp_date
			,ipsr.sell_amount
			,ipsr.discount_amount
			,ipsr.buy_amount
			,ipsr.adjustment_sell_amount
			,ipsr.adjustment_discount_amount
			,ipsr.adjustment_buy_amount
			,ipsr.total_amount
			,ipsr.ppn_amount
			,ipsr.pph_amount
			,ipsr.total_payment_amount
			,ipsr.payment_request_code
			,ipm.policy_no
			--,ipm.fa_code 'asset_no'
			--,aa.item_name 'asset_name'
	from	insurance_payment_schedule_renewal ipsr
			inner join dbo.insurance_policy_main ipm on (ipm.code = ipsr.policy_code)
			--inner join dbo.asset aa on (aa.code					  = ipm.fa_code)
	where	ipsr.code = @p_code ;
end ;
