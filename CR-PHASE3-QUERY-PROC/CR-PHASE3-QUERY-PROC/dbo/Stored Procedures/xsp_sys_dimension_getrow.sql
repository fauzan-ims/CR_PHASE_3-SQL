create PROCEDURE dbo.xsp_sys_dimension_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,description
			,type
			,table_name
			,column_name
			,primary_column
			,function_name
			,is_active
	from	sys_dimension
	where	code = @p_code ;
end ;
