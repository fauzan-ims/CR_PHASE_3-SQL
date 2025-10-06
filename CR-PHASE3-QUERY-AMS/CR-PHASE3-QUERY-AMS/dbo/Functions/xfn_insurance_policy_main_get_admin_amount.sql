
CREATE FUNCTION [dbo].[xfn_insurance_policy_main_get_admin_amount]
(
	@p_policy_main_code		nvarchar(50)
	,@p_invoice_code		nvarchar(50)
	,@p_fa_code				nvarchar(50)
)
returns decimal(18, 2)
as
begin
	declare @return_amount			decimal(18, 2)
			,@total_admin_period	decimal(18, 2);

	--if exists
	--(
	--	select	1
	--	from	dbo.insurance_policy_main
	--	where	code					= @p_policy_main_code
	--			and policy_payment_type = 'FTAP'
	--			and invoice_no			= @invoice_code
	--)
	--begin
	--	select	@total_admin_period = sum(admin_fee_amount)
	--	from	dbo.insurance_policy_main_period
	--	where	policy_code		 = @p_policy_main_code
	--			and year_periode = '1' ;
	--end ;
	--else
	begin
		--select	@total_admin_period = sum(admin_fee_amount)
		--from	dbo.insurance_policy_main_period
		--where	policy_code = @p_policy_main_code ;

		select @total_admin_period = sum(ipac.initial_admin_fee_amount) 
		from dbo.insurance_policy_asset_coverage ipac
		inner join dbo.insurance_policy_asset ipa on (ipac.register_asset_code = ipa.code)
		where ipa.policy_code = @p_policy_main_code
		and ipa.invoice_code = @p_invoice_code
		and ipa.fa_code = @p_fa_code
	end ;

	set @return_amount = isnull(@total_admin_period, 0) ;

	return @return_amount ;
end ;
