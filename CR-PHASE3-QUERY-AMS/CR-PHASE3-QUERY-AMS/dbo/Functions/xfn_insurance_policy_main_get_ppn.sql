CREATE FUNCTION [dbo].[xfn_insurance_policy_main_get_ppn]
(
	@p_policy_main_code		nvarchar(50)
	,@p_invoice_code		nvarchar(50)
	,@p_fa_code				nvarchar(50)
)
returns decimal(18, 2)
as
begin
declare @return_amount				 decimal(18, 2)


		select @return_amount =	isnull(sum(ipac.initial_discount_ppn),0)
		from	dbo.insurance_policy_asset_coverage	  ipac
				inner join dbo.insurance_policy_asset ipa on ipa.code = ipac.register_asset_code
		where ipa.policy_code = @p_policy_main_code
		and ipa.invoice_code = @p_invoice_code
		and ipa.fa_code = @p_fa_code
		--AND ipac.COVERAGE_TYPE = 'NEW'

	return @return_amount ;
end ;
