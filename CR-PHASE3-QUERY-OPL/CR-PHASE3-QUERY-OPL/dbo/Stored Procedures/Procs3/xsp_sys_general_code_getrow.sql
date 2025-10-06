
CREATE PROCEDURE [dbo].[xsp_sys_general_code_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,description
			,is_editable
	from	sys_general_code
	where	code = @p_code ;
end ;
