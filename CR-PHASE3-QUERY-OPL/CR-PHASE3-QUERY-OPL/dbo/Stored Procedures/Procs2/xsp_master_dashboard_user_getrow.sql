CREATE PROCEDURE dbo.xsp_master_dashboard_user_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,employee_code
			,employee_name
			,dashboard_code
			,order_key
	from	master_dashboard_user
	where	id = @p_id ;
end ;
