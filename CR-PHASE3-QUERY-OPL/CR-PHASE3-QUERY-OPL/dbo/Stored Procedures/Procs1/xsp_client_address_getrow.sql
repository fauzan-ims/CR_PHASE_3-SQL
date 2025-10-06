CREATE PROCEDURE [dbo].[xsp_client_address_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	ca.code
			,ca.client_code
			,ca.address
			,ca.province_code
			,ca.province_name
			,ca.city_code
			,ca.city_name
			,ca.zip_code_code
			,ca.zip_code
			,ca.zip_name
			,ca.sub_district
			,ca.village
			,ca.rt
			,ca.rw
			,ca.area_phone_no
			,ca.phone_no
			,ca.is_legal
			,ca.is_collection
			,ca.is_mailing
			,ca.is_residence
			,ca.range_in_km
			,ca.ownership 'ownership_code'
			,sgs.description 'ownership_desc'
			,ca.lenght_of_stay
	from	client_address ca
			inner join dbo.sys_general_subcode sgs on (sgs.code = ca.ownership)
	where	ca.code = @p_code ;
end ;


