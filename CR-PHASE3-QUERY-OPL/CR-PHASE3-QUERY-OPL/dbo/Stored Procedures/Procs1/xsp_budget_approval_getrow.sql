CREATE PROCEDURE dbo.xsp_budget_approval_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	ba.code
			,ba.asset_no
			,ba.status
			,ba.date 'reserv_date'
			,am.application_external_no
			,cm.client_name
			,aa.asset_no
			,aa.asset_name
			,am.marketing_name
	from	budget_approval ba
			inner join dbo.application_asset aa on (aa.asset_no		 = ba.asset_no)
			inner join dbo.application_main am on (am.application_no = aa.application_no)
			inner join dbo.client_main cm on (cm.code				 = am.client_code)
	where	ba.code = @p_code ;
end ;
