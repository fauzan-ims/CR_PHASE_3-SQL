CREATE PROCEDURE [dbo].[xsp_application_guarantor_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,application_no
			,guarantor_client_type
			,guarantor_client_code
			,full_name 'existing_client_name'
			,relationship
			,guaranted_pct
			,remarks
			,full_name
			,gender_code
			,mother_maiden_name
			,place_of_birth
			,date_of_birth
			,province_code
			,province_name
			,city_code
			,city_name
			,zip_code
			,zip_code_code
			,zip_name
			,sub_district
			,village
			,address
			,rt
			,rw
			,area_mobile_no
			,mobile_no
			,id_no
			,npwp_no
	from	application_guarantor
	where	id = @p_id ;
end ;

