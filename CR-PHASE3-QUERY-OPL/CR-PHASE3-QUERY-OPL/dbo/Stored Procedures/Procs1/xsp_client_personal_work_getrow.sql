CREATE PROCEDURE [dbo].[xsp_client_personal_work_getrow]
(
	@p_id bigint
)
as
begin
	select	id
			,client_code
			,company_name
			,company_business_line
			,company_sub_business_line
			,area_phone_no
			,phone_no
			,area_fax_no
			,fax_no
			,work_type_code
			,work_department_name
			,work_start_date
			,work_end_date
			,work_position
			,province_code
			,province_name
			,city_code
			,city_name
			,zip_code
			,zip_name
			,sub_district
			,village
			,address
			,rt
			,rw
			,is_latest
			,sgs.description 'work_type_desc'
			,sgsb.description 'business_line_desc'
			,sgsd.description 'sub_business_line_desc'
	from	client_personal_work cpw
			left join dbo.sys_general_subcode sgs on (sgs.code			 = cpw.work_type_code)
			left join dbo.sys_general_subcode sgsb on (sgsb.code		 = cpw.company_business_line)
			left join dbo.sys_general_subcode_detail sgsd on (sgsd.code = cpw.company_sub_business_line)
	where	id = @p_id ;
end ;

