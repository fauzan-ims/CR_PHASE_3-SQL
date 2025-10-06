CREATE PROCEDURE dbo.xsp_sys_role_group_getrow
(
	@p_code				nvarchar(50)
	,@p_company_code	nvarchar(50)
)
as
begin
	select	company_code
			,code
			,name
			,application_code
	from	sys_role_group
	where	code = @p_code
	and		company_code = @p_company_code ;
end ;
