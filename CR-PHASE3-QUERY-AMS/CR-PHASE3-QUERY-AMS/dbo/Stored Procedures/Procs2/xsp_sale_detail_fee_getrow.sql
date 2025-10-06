CREATE PROCEDURE dbo.xsp_sale_detail_fee_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,sale_detail_id
			,fee_code
			,fee_name
			,fee_amount
			,pph_amount
			,ppn_amount
			,master_tax_code
			,master_tax_description
			,master_tax_pph_pct
			,master_tax_ppn_pct
	from	sale_detail_fee
	where	id = @p_id ;
end ;
