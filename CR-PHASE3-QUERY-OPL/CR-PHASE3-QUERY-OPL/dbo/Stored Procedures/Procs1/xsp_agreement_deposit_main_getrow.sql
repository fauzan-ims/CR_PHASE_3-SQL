CREATE PROCEDURE dbo.xsp_agreement_deposit_main_getrow
(
	@p_code					nvarchar(50)
) as
begin

	select	code
            ,adm.branch_code
            ,adm.branch_name
            ,adm.agreement_no
			,am.agreement_external_no
			,am.client_name
            ,deposit_type
            ,deposit_currency_code
            ,deposit_amount
	from	dbo.agreement_deposit_main  adm
			left join dbo.agreement_main am on (am.agreement_no = adm.agreement_no)
	where	code			= @p_code
end
