
CREATE procedure [dbo].[xsp_sys_corporate_getrow]
(
	@p_client_code nvarchar(50)
)
as
begin
	select	client_code
			,full_name
			,tax_file_no
			,est_date
			,corporate_status
			,business_type
			,subbusiness_type
			,corporate_type
			,business_experience
			,email
			,contact_person_name
			,contact_person_area_phone_no
			,contact_person_phone_no
	from	sys_corporate
	where	client_code = @p_client_code ;
end ;

