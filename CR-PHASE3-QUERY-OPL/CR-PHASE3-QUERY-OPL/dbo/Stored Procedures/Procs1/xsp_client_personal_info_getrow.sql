CREATE PROCEDURE dbo.xsp_client_personal_info_getrow
(
	@p_client_code nvarchar(50)
	,@p_reff_no	   nvarchar(50)
)
as
begin
	select	cpi.client_code
			,cpi.full_name
			,cpi.alias_name
			,cpi.mother_maiden_name
			,cpi.place_of_birth
			,cpi.date_of_birth
			,cpi.religion_type_code
			,cpi.gender_code
			,cpi.email
			,cpi.area_mobile_no
			,cpi.mobile_no
			,cpi.area_mobile_no + ' - ' + cpi.mobile_no 'full_mobile_no'
			,cpi.nationality_type_code
			,cpi.salutation_prefix_code
			,cpi.salutation_postfix_code
			,cpi.education_type_code
			,cpi.marriage_type_code
			,cpi.dependent_count
			,cm.client_no
			,sgspr.description 'salutation_prefix_desc'
			,sgspo.description 'salutation_postfix_desc'
			,sgsed.description 'education_type_desc'
			,sgsma.description 'marriage_type_desc'
			,sgsgr.description 'gender_desc'
			,sgsrl.description 'religion_type_desc'
			,cm.watchlist_status
			,cm.is_validate
			,cm.status_slik_checking
			,cm.status_dukcapil_checking
			,cm.is_red_flag
			,cm.client_group_code
			,cm.client_group_name
			,am.application_status 'plafond_status'
	from	client_main cm 
			left join dbo.application_main am on (
													 am.client_code			 = cm.code
													 and   am.application_no = @p_reff_no
												 )
			left join dbo.client_personal_info cpi on (cpi.client_code		 = cm.code)
			left join dbo.sys_general_subcode sgspr on (sgspr.code			 = cpi.salutation_prefix_code)
			left join dbo.sys_general_subcode sgspo on (sgspo.code			 = cpi.salutation_postfix_code)
			left join dbo.sys_general_subcode sgsed on (sgsed.code			 = cpi.education_type_code)
			left join dbo.sys_general_subcode sgsma on (sgsma.code			 = cpi.marriage_type_code)
			left join dbo.sys_general_subcode sgsgr on (sgsgr.code			 = cpi.gender_code)
			left join dbo.sys_general_subcode sgsrl on (sgsrl.code			 = cpi.religion_type_code)
	where	cm.code = @p_client_code ;
end ;

