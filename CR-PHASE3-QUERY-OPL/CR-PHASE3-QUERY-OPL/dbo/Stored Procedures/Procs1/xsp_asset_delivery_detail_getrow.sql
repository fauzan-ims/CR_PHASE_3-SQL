CREATE PROCEDURE dbo.xsp_asset_delivery_detail_getrow
(
	@p_id bigint
)
as
begin
	select	adde.id
			,adde.delivery_code
			,adde.asset_no 
			,aa.asset_name
			,aa.asset_year
			,aa.asset_condition
			,aa.fa_code
			,aa.fa_name
			,am.agreement_external_no
			,cm.client_name
	from	asset_delivery_detail adde
			inner join dbo.application_asset aa on (aa.asset_no = adde.asset_no)
			inner join dbo.application_main am on (am.application_no = aa.application_no)
			inner join dbo.client_main cm on (cm.code = am.client_code)
	where	adde.id = @p_id ;
end ;
