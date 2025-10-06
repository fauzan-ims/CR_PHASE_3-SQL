CREATE PROCEDURE [dbo].[xsp_client_relation_getrow]
(
	@p_id bigint
)
as
begin
	select	cr.id
			,cr.client_code
			,cr.relation_client_code
			,cr.relation_type
			,cr.client_type
			,cr.full_name
			,case
				 when cr.relation_client_code is not null then cr.full_name
				 else ''
			 end 'existing_client_name'
			,cr.gender_code
			,cr.mother_maiden_name
			,cr.place_of_birth
			,cr.date_of_birth
			,cr.province_code
			,cr.province_name
			,cr.city_code
			,cr.city_name
			,cr.zip_code
			,cr.zip_code 'zip_code_code'
			,cr.zip_name
			,cr.sub_district
			,cr.village
			,cr.address
			,cr.rt
			,cr.rw
			,cr.area_mobile_no
			,cr.mobile_no
			,cr.id_no
			,cr.npwp_no
			,cr.shareholder_pct
			,cr.is_officer
			,cr.officer_signer_type
			,cr.officer_position_type_code
			,cr.order_key
			,cr.is_emergency_contact
			,cr.family_type_code
			,cr.reference_type_code
			,cr.is_latest
			,cr.counter
			,sgc.description 'family_type_desc'
			,cpi.full_name 'client_name'
			,sgc2.description 'gender_desc'
			,cci.full_name 'client_name_corporate'
			,cr.officer_position_type_code
			,cr.officer_position_type_ojk_code
			,cr.officer_position_type_name
			,shareholder_type
			,cr.dati_ii_code
			,cr.dati_ii_ojk_code
			,cr.dati_ii_name
	from	client_relation cr
			left join dbo.sys_general_subcode sgc on (cr.family_type_code = sgc.code)
			left join dbo.sys_general_subcode sgc2 on (cr.gender_code	  = sgc2.code)
			left join dbo.client_personal_info cpi on (cpi.client_code	  = cr.relation_client_code)
			left join dbo.client_corporate_info cci on (cci.client_code	  = cr.relation_client_code)
	where	id = @p_id ;
end ;

