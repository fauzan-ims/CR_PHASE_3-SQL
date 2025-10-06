
create procedure xsp_ifinams_interface_additional_request_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,agreement_no
			,asset_no
			,branch_code
			,branch_name
			,invoice_type
			,invoice_date
			,invoice_name
			,client_no
			,client_name
			,client_address
			,client_area_phone_no
			,client_phone_no
			,client_npwp
			,currency_code
			,tax_scheme_code
			,tax_scheme_name
			,billing_no
			,description
			,quantity
			,billing_amount
			,discount_amount
			,ppn_pct
			,ppn_amount
			,pph_pct
			,pph_amount
			,total_amount
			,request_status
			,reff_code
			,reff_name
			,settle_date
			,job_status
			,failed_remarks
	from	ifinams_interface_additional_request
	where	id = @p_id ;
end ;
