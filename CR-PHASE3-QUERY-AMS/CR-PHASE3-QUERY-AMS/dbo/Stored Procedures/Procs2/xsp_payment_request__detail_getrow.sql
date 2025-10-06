CREATE procedure xsp_payment_request__detail_getrow
(
	@p_id nvarchar(50)
)
as
begin
	select	id							
			,payment_request_code		
			,branch_code				
			,branch_name				
			,gl_link_code				
			,agreement_no				
			,facility_code				
			,facility_name				
			,purpose_loan_code			
			,purpose_loan_name			
			,purpose_loan_detail_code	
			,purpose_loan_detail_name	
			,orig_currency_code			
			,exch_rate					
			,orig_amount				
			,division_code				
			,division_name				
			,department_code			
			,department_name			
			,remarks					
			,is_taxable					
			,tax_amount					
			,tax_pct	
	from	payment_request_detail
	where	id = @p_id ;
end ;
