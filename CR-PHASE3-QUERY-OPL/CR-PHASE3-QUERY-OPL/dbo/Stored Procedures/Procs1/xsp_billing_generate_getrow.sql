CREATE PROCEDURE dbo.xsp_billing_generate_getrow
(
	@p_code nvarchar(50)
)
as
begin

	select	bg.code
			,bg.branch_code
			,bg.branch_name
			,bg.date
			,bg.status
			,bg.remark
			,bg.client_no
			,bg.client_name
			,bg.agreement_no
			,bg.asset_no
			,ast.asset_name
			,bg.as_off_date
			,bg.is_eod
			,am.agreement_external_no
	from	billing_generate bg
			left join dbo.agreement_main am on (bg.agreement_no = am.agreement_no)
			left join dbo.agreement_asset ast on (bg.asset_no = ast.asset_no)
	where	bg.code = @p_code ;

end ;
