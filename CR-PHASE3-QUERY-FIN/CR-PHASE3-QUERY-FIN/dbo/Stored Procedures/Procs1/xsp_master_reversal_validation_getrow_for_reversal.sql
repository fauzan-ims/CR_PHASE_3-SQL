create PROCEDURE dbo.xsp_master_reversal_validation_getrow_for_reversal
as
begin
	select	id
			,name
			,module_code	   
			,process_name   
			,api_validation
	from	master_reversal_validation
end ;
