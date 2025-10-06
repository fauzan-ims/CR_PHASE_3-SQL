--CREATED by ALIV on 16/05/2023
create procedure xsp_ifinproc_interface_additional_invoice_request_getrow
(
	@p_id bigint
)
as
begin
	select	
			id						
			,branch_code			
			,branch_name			
			,date					
			,invoice_type			
			,invoice_name			
			,invoice_date			
			,invoice_due_date		
			,fa_code				
			,fa_name				
			,client_no				
			,client_name			
			,client_address			
			,client_area_phone_no	
			,client_phone_no		
			,client_npwp			
			,total_billing_amount	
			,total_discount_amount	
			,total_ppn_amount		
			,total_pph_amount		
			,total_amount			
			,currency				
			,reff_no				
			,reff_name						
	from	ifinproc_interface_additional_invoice_request
	where	id = @p_id ;
end ;
