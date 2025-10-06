CREATE PROCEDURE dbo.xsp_purchase_request_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	pr.code
			,pr.branch_code
			,pr.branch_name
			,pr.request_date
			,pr.request_status
			,pr.description
			,pr.fa_category_code
			,pr.fa_category_name
			,pr.fa_merk_code
			,pr.fa_merk_name
			,pr.fa_model_code
			,pr.fa_model_name
			,pr.fa_type_code
			,pr.fa_type_name
			,pr.result_fa_code
			,pr.result_fa_name
			,pr.result_date
			,am. application_external_no
			,cm.client_name
			,aa.asset_no
			,aa.asset_name
			,aa.application_no
			,pr.unit_from
	from	purchase_request pr
			left join dbo.application_asset aa on (aa.purchase_code = pr.code or aa.purchase_gts_code = pr.code)
			left join dbo.application_main am on (am.application_no = aa.application_no)
			left join dbo.client_main cm on (cm.code				= am.client_code)
	where	pr.code = @p_code ;
end ;
