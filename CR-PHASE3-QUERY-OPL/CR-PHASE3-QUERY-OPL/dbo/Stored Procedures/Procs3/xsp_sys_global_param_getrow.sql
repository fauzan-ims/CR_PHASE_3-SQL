CREATE PROCEDURE dbo.xsp_sys_global_param_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,description
			,value
			,value 'file_size'
			,is_editable
	from	dbo.sys_global_param
	where	code = @p_code ;
end ;
