CREATE PROCEDURE [dbo].[xsp_supplier_selection_detail_marketing_getrow]
(
	@p_id  bigint
)
as
begin
	select	ssd.id
			,ssd.selection_code
			,ssd.asset_amount
			,ssd.asset_discount_amount
			,ssd.karoseri_amount
			,ssd.karoseri_discount_amount
			,ssd.accesories_amount
			,ssd.accesories_discount_amount
			,isnull(ssd.mobilization_amount,0) 'mobilization_amount'
			,replace(ssd.application_no, '.', '/') 'application_no'
			,pr.asset_no
			,p.requestor_name
			,ssd.otr_amount
	from	dbo.supplier_selection_detail ssd
	left join dbo.quotation_review_detail qrd on qrd.id = ssd.quotation_detail_id
	left join dbo.procurement p on p.code collate Latin1_General_CI_AS = isnull(qrd.reff_no, ssd.reff_no)
	inner join dbo.procurement_request pr on (pr.code = p.procurement_request_code)
	where	ssd.id = @p_id
end ;
