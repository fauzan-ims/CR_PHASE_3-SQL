create PROCEDURE dbo.xsp_master_public_service_address_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,public_service_code
			,province_code
			,province_name
			,city_code
			,city_name
			,zip_code
			,sub_district
			,village
			,address
			,rt
			,rw
			,is_latest
	from	master_public_service_address
	where	id = @p_id ;
end ;
