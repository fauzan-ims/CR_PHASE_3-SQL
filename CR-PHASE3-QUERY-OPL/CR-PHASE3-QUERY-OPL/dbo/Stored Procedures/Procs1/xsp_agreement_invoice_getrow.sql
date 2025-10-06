CREATE procedure dbo.xsp_agreement_invoice_getrow
(
	@p_invoice_no		 nvarchar(50)
)
as
begin

	select	invoice_no
			,invoice_type
			,invoice_date
			,invoice_due_date
			,invoice_name
			,invoice_status
			,client_no
			,client_name
			,client_address
			,client_province_name
			,client_city_name
			,client_zip_code
			,client_village
			,client_rt
			,client_rw
			,client_area_phone_no
			,client_phone_no
			,total_billing_amount
			,total_discount_amount
			,total_ppn_amount
			,total_pph_amount
			,total_ppn_bm_amount
			,total_amount
			,faktur_no
			,generate_code
			,scheme_code
			,received_reff_no
			,convert(varchar(30), received_reff_date, 103) 'received_reff_date'	
	from	dbo.agreement_invoice
	where	invoice_no = @p_invoice_no
end ;
