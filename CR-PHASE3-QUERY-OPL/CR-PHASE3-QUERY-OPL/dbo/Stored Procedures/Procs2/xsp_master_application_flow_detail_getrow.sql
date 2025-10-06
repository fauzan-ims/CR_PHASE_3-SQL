
create PROCEDURE dbo.xsp_master_application_flow_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,application_flow_code
			,workflow_code
			,is_approval
			,order_key
	from	master_application_flow_detail
	where	id = @p_id ;
end ;
