
CREATE PROCEDURE dbo.xsp_sys_todo_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,todo_name
			,link_address
			,query
			,is_active
	from	dbo.sys_todo
	where	code = @p_code ;
end ;
