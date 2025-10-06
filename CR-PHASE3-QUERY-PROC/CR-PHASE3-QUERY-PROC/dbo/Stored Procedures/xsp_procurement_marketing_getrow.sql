CREATE PROCEDURE [dbo].[xsp_procurement_marketing_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	p.code
			,p.asset_amount
			,p.asset_discount_amount
			--,p.karoseri_amount
			,case	
					when mi.category_type = 'ASSET' then 0
					when mi.category_type = 'ACCESSORIES' then 0
					when mi.category_type = 'KAROSERI' then p.karoseri_amount
					else 0
			end 'karoseri_amount'
			,case	
					when mi.category_type = 'ASSET' then 0
					when mi.category_type = 'ACCESSORIES' then 0
					when mi.category_type = 'KAROSERI' then p.karoseri_discount_amount
					else 0
			end 'karoseri_discount_amount'
			,case	
					when mi.category_type = 'ASSET' then 0
					when mi.category_type = 'ACCESSORIES' then p.accesories_amount
					when mi.category_type = 'KAROSERI' then 0
					else 0
			end 'accesories_amount'
			,case	
					when mi.category_type = 'ASSET' then 0
					when mi.category_type = 'ACCESSORIES' then p.accesories_discount_amount
					when mi.category_type = 'KAROSERI' then 0
					else 0
			end 'accesories_discount_amount'
			--,p.karoseri_discount_amount
			--,p.accesories_amount
			--,p.accesories_discount_amount
			,case	
					when mi.category_type = 'ASSET' then isnull(p.mobilization_amount, 0)
					when mi.category_type = 'ACCESSORIES' then 0
					when mi.category_type = 'KAROSERI' then 0
					else 0
			end 'mobilization_amount'
			--,isnull(p.mobilization_amount, 0)	 'mobilization_amount'
			,p.requestor_name
			,pr.asset_no
			,replace(p.application_no, '.', '/') 'application_no'
			,p.otr_amount
	from	procurement						   p
			inner join dbo.procurement_request pr on (pr.code = p.procurement_request_code)
			inner join ifinbam.dbo.master_item mi on mi.code collate Latin1_General_CI_AS = p.item_code
	where	p.code = @p_code ;
end ;
