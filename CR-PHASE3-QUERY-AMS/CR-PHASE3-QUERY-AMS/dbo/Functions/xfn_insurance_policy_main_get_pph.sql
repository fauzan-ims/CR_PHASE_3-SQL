
CREATE FUNCTION [dbo].[xfn_insurance_policy_main_get_pph] -- special case pakai 2 param
(
	@p_policy_main_code		nvarchar(50)
	,@p_invoice_code		nvarchar(50)
	,@p_fa_code				nvarchar(50)
)
returns decimal(18, 2)
as
begin
	-- Hari - 19.Jul.2023 05:21 PM --	khusus for get pph amount by insurance_invoice code
	declare @return_amount				 decimal(18, 2)


		select @return_amount =	isnull(sum(ipac.initial_discount_pph),0)
		from	dbo.insurance_policy_asset_coverage	  ipac
				inner join dbo.insurance_policy_asset ipa on ipa.code = ipac.register_asset_code
		where ipa.policy_code = @p_policy_main_code
			and ipa.invoice_code = @p_invoice_code
			and ipa.fa_code = @p_fa_code

	return @return_amount ;
end ;
