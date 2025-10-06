CREATE PROCEDURE dbo.xsp_master_public_service_branch_service_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,public_service_branch_code
			,service_code
			,service_fee_amount
			,estimate_finish_day
	from	master_public_service_branch_service
	where	id = @p_id ;
end ;
