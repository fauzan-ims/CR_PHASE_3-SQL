
create procedure xsp_sys_audit_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,audit_code
			,date
			,progress
			,remark
	from	sys_audit_detail
	where	id = @p_id ;
end ;
