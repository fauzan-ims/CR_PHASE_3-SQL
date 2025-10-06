create procedure xsp_payment_request_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code						
			,branch_code				
			,branch_name				
			,payment_branch_code		
			,payment_branch_name		
			,payment_source				
			,payment_request_date		
			,payment_source_no			
			,payment_status				
			,payment_currency_code		
			,payment_amount				
			,payment_to					
			,payment_remarks			
			,to_bank_name				
			,to_bank_account_name		
			,to_bank_account_no			
			,payment_transaction_code	
			,tax_type					
			,tax_file_no				
			,tax_payer_reff_code		
			,tax_file_name				
	from	payment_request
	where	code = @p_code ;
end ;
