--CREATED by ALIV on 16/05/2023
CREATE procedure xsp_ifinproc_interface_handover_request_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,code				
			,branch_code		
			,branch_name		
			,status				
			,transaction_date	
			,type				
			,remark				
			,fa_code			
			,fa_name			
			,handover_from		
			,handover_to		
			,unit_condition		
			,reff_no			
			,reff_name			
			,handover_address	
			,handover_phone_area
			,handover_phone_no	
			,handover_eta_date	
			,handover_code		
			,handover_bast_date	
			,handover_remark	
			,handover_status	
			,asset_status		
			,settle_date		
			,job_status			
			,failed_remarks	
	from	ifinproc_interface_handover_request
	where	id = @p_id ;
end ;
