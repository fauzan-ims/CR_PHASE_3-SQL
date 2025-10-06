CREATE PROCEDURE [dbo].[xsp_quotation_review_detail_marketing_getrow]
(
	@p_id bigint 
)
as
begin
	select	qrd.quotation_review_code
			,qrd.id
			,qrd.asset_amount
			,qrd.asset_discount_amount
			,qrd.karoseri_amount
			,qrd.karoseri_discount_amount
			,qrd.accesories_amount
			,qrd.accesories_discount_amount
			,isnull(qrd.mobilization_amount,0) 'mobilization_amount'
			,pr.asset_no
			,replace(qrd.application_no, '.', '/') 'application_no'
			,p.requestor_name
			,qrd.otr_amount
	from	dbo.quotation_review_detail qrd
	inner join dbo.procurement p on p.code collate Latin1_General_CI_AS = qrd.reff_no
	inner join dbo.procurement_request pr on (pr.code = p.procurement_request_code)
	where	qrd.id = @p_id
end ;
