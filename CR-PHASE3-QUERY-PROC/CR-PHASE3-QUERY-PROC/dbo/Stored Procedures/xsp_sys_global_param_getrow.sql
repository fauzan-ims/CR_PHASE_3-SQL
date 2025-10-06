--alter by, Rian at 20/02/2023 

CREATE PROCEDURE dbo.xsp_sys_global_param_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,description
			,value
			,is_editable
	from	dbo.sys_global_param 
	where	code = @p_code
end ;
