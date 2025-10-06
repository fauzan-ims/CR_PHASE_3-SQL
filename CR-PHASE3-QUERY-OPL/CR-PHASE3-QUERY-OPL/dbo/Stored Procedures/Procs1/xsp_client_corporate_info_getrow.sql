CREATE PROCEDURE dbo.xsp_client_corporate_info_getrow
(
	@p_client_code nvarchar(50)
	,@p_reff_no	   nvarchar(50)
)
as
begin
	select	cci.client_code
			,cci.full_name
			,cci.est_date
			,cci.corporate_status_code
			,cci.business_line_code
			,cci.sub_business_line_code
			,cci.corporate_type_code
			,cci.business_experience_year
			,cci.email
			,cci.website
			,cci.area_mobile_no
			,cci.mobile_no
			,cci.area_mobile_no + ' - ' + cci.mobile_no 'full_mobile_no'
			,cci.area_fax_no
			,cci.fax_no
			,cci.area_fax_no + ' - ' + cci.fax_no 'full_fax_no'
			,cci.contact_person_name
			,cci.contact_person_area_phone_no
			,cci.contact_person_phone_no
			,cci.contact_person_area_phone_no + ' - ' + cci.contact_person_phone_no 'full_contact_person_phone_no'
			,cm.client_no
			,cm.is_validate
			,cm.watchlist_status
			,sgs.description 'corporate_status_desc'
			,sgsb.description 'business_line_desc'
			,sgsd.description 'sub_business_line_desc'
			,sgst.description 'corporate_type_desc'
			,cm.is_red_flag
			,cm.client_group_code
			,cm.client_group_name
			,am.application_status 'plafond_status'
	from	client_main cm 
			left join dbo.application_main am on (
													 am.client_code			 = cm.code
													 and   am.application_no = @p_reff_no
												 )
			left join dbo.client_corporate_info cci on (cci.client_code		 = cm.code)
			left join dbo.sys_general_subcode sgs on (sgs.code				 = cci.corporate_status_code)
			left join dbo.sys_general_subcode sgst on (sgst.code			 = cci.corporate_type_code)
			left join dbo.sys_general_subcode sgsb on (sgsb.code			 = cci.business_line_code)
			left join dbo.sys_general_subcode_detail sgsd on (sgsd.code		 = cci.sub_business_line_code)
	where	cm.code = @p_client_code ;
end ;

