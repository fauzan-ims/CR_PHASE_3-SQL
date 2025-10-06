
CREATE PROCEDURE dbo.xsp_sys_dimension_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,description
			,is_active
			,type
			,table_name
			,column_name
			,primary_column
			,function_name
	from	sys_dimension
	where	code = @p_code ;
end ;
