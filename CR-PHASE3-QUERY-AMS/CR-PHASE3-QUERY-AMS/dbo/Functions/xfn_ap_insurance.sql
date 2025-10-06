create FUNCTION [dbo].[xfn_ap_insurance]
(
	@p_policy_main_code nvarchar(50)
	,@p_invoice_code	nvarchar(50)
	,@p_fa_code			nvarchar(50)
)
returns decimal(18, 2)
as
begin
	declare @total_buy_amount decimal(18, 2) ;

	begin
		select	@total_buy_amount = isnull(sum(ipac.buy_amount), 0)
		from	dbo.insurance_policy_asset					   ipa
				inner join dbo.insurance_policy_asset_coverage ipac on (ipa.code = ipac.register_asset_code)
		where	ipa.policy_code		 = @p_policy_main_code
				and ipa.invoice_code = @p_invoice_code
				and ipa.fa_code		 = @p_fa_code ;
	end ;

	return @total_buy_amount ;
end ;
