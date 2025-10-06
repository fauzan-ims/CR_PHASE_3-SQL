CREATE PROCEDURE [dbo].[xsp_quotation_review_vendor_getrow]
(
	@p_id bigint
)
as
begin
	select id
		  ,quotation_review_code
		  ,supplier_code
		  ,supplier_name
		  ,supplier_address
		  ,supplier_npwp
		  ,tax_code
		  ,tax_name
		  ,tax_ppn_pct
		  ,tax_pph_pct
		  ,warranty_month
		  ,warranty_part_month
		  ,price_amount
		  ,discount_amount
		  ,nett_price
		  ,total_amount
		  ,offering
		  ,quotation_date
		  ,quotation_expired_date
		  ,unit_available_status
		  ,indent_days
	from dbo.quotation_review_vendor 
	where id = @p_id
end ;
