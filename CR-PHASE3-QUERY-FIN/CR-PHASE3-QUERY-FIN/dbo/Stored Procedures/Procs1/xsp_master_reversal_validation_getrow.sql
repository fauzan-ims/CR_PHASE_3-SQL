create PROCEDURE dbo.xsp_master_reversal_validation_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,name
			,module_code	   
			,process_name   
			,api_validation
	from	master_reversal_validation
	where	id = @p_id ;
end ;
