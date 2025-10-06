CREATE PROCEDURE dbo.xsp_billing_scheme_detail_getrow
(
	@p_id					bigint
) 
as
begin

	select	bsd.id
			,bsd.scheme_code
			,bsd.agreement_no
			,am.client_name
			,bsd.asset_no
			,ast.asset_name
	from	billing_scheme_detail bsd
			inner join dbo.agreement_main am on (am.agreement_no = bsd.agreement_no)
			inner join dbo.agreement_asset ast on (ast.agreement_no = bsd.agreement_no)
	where	bsd.id = @p_id

end
