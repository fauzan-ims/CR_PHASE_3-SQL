CREATE PROCEDURE dbo.xsp_master_deskcoll_result_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,result_name
			,is_active
	from	master_deskcoll_result
	where	code = @p_code ;
end ;
