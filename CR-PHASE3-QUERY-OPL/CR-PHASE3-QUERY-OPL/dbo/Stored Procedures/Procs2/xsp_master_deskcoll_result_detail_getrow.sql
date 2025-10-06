CREATE PROCEDURE dbo.xsp_master_deskcoll_result_detail_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,result_code
			,result_detail_name
			,is_active
	from	master_deskcoll_result_detail
	where	code = @p_code ;
end ;
