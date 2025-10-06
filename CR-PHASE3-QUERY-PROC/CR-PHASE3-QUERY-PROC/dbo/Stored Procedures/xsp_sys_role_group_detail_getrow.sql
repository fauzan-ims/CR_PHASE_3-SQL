CREATE PROCEDURE dbo.xsp_sys_role_group_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,role_group_code
			,role_code
	from	sys_role_group_detail
	where	id = @p_id ;
end ;
