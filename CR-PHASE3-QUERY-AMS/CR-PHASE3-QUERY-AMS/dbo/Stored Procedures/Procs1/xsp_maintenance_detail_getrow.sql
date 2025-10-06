CREATE PROCEDURE dbo.xsp_maintenance_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,maintenance_code
			,service_code
			,service_name
			--,service_type
			,file_name
			,path
	from	maintenance_detail
	where	id = @p_id ;
end ;
