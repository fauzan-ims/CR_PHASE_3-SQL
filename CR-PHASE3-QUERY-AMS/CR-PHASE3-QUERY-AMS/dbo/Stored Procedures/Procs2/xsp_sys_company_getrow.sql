CREATE PROCEDURE dbo.xsp_sys_company_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,name
	from	sys_company
	where	code = @p_code ;
end ;
