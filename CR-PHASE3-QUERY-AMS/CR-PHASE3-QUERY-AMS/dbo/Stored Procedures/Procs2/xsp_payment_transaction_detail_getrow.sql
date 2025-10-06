CREATE procedure xsp_payment_transaction_detail_getrow
(
	@p_id nvarchar(50)
)
as
begin
	select	id							
			,payment_transaction_code	
			,payment_request_code		
			,orig_curr_code				
			,orig_amount				
			,exch_rate					
			,base_amount				
			,tax_amount								
	from	payment_transaction_detail
	where	id = @p_id ;
end ;
