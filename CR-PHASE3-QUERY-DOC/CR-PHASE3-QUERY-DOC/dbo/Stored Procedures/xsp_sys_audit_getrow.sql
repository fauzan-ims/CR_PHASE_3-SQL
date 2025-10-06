CREATE procedure dbo.xsp_sys_audit_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	sa.code
			,branch_code
			,branch_name
			,date
			,type_code
			,sgs.description 'type_name'
			,sa.description
			,status
	from	sys_audit sa
			inner join dbo.sys_general_subcode sgs on sgs.code				= sa.type_code
													  and  sgs.general_code = 'TYAUD'
	where	sa.code = @p_code ;
end ;
