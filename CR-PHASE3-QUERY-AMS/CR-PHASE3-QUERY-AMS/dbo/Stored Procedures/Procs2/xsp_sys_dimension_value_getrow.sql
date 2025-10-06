
create procedure xsp_sys_dimension_value_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,dimension_code
			,description
			,value
	from	sys_dimension_value
	where	code = @p_code ;
end ;
