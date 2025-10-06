CREATE PROCEDURE [dbo].[xsp_master_insurance_address_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,insurance_code
			,province_code
			,province_name
			,city_code
			,city_name 'city_desc'
			,zip_code
			,zip_name
			,sub_district
			,village
			,address
			,rt
			,rw
			,is_latest
	from	master_insurance_address
	where	id = @p_id ;
end ;


