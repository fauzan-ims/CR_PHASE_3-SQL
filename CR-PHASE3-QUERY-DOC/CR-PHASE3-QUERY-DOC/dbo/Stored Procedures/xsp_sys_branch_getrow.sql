CREATE PROCEDURE dbo.xsp_sys_branch_getrow
(
	@p_branch_code nvarchar(50)
)
as
begin
	select	branch_code
			,branch_name
			,is_custody_branch
			,custody_branch_code
			,custody_branch_name
	from	sys_branch
	where	branch_code = @p_branch_code ;
end ;
