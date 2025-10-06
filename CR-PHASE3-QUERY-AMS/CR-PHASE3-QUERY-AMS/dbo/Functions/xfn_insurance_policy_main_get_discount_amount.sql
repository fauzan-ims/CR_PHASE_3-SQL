CREATE FUNCTION [dbo].[xfn_insurance_policy_main_get_discount_amount]
(
	@p_policy_main_code		NVARCHAR(50)
	,@p_invoice_code		NVARCHAR(50)
	,@p_fa_code				NVARCHAR(50)
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
	DECLARE @total_buy_amount DECIMAL(18, 2) ;


	SELECT @total_buy_amount = ISNULL(SUM(ipac.initial_discount_amount),0)
	FROM dbo.insurance_policy_asset ipa 
	INNER JOIN dbo.insurance_policy_asset_coverage ipac ON (ipa.code = ipac.register_asset_code)
	WHERE ipa.policy_code = @p_policy_main_code
	AND ipa.invoice_code = @p_invoice_code
	AND ipa.fa_code = @p_fa_code
	--AND ipac.COVERAGE_TYPE = 'NEW'

	return @total_buy_amount ;
end ;
