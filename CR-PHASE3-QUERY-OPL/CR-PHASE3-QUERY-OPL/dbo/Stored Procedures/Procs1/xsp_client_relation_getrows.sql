CREATE PROCEDURE [dbo].[xsp_client_relation_getrows]
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_client_code	  nvarchar(50)
	,@p_relation_type nvarchar(15) = ''
	,@p_is_latest	  nvarchar(1)  = ''
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	client_relation cr
			left join dbo.sys_general_subcode sgc on (cr.family_type_code = sgc.code)
			left join dbo.sys_general_subcode sgc2 on (cr.gender_code	  = sgc2.code)
			left join dbo.client_personal_info cpi on (cpi.client_code	  = cr.relation_client_code)
			left join dbo.client_corporate_info cci on (cci.client_code	  = cr.relation_client_code)
	where	cr.client_code		 = @p_client_code
			and cr.relation_type = case @p_relation_type
										when '' then cr.relation_type
										else @p_relation_type
									end
			and cr.is_latest	 = case @p_is_latest
										when '' then cr.is_latest
										else @p_is_latest
									end
			and (
				cr.client_code						like '%' + @p_keywords + '%'
				or	cr.relation_client_code			like '%' + @p_keywords + '%'
				or	cr.relation_type				like '%' + @p_keywords + '%'
				or	cr.client_type					like '%' + @p_keywords + '%'
				or	cr.full_name					like '%' + @p_keywords + '%'
				or	cr.gender_code					like '%' + @p_keywords + '%'
				or	cr.mother_maiden_name			like '%' + @p_keywords + '%'
				or	cr.place_of_birth				like '%' + @p_keywords + '%'
				or	cr.date_of_birth				like '%' + @p_keywords + '%'
				or	cr.province_code				like '%' + @p_keywords + '%'
				or	cr.province_name				like '%' + @p_keywords + '%'
				or	cr.city_code					like '%' + @p_keywords + '%'
				or	cr.city_name					like '%' + @p_keywords + '%'
				or	cr.zip_code						like '%' + @p_keywords + '%'
				or	cr.zip_name						like '%' + @p_keywords + '%'
				or	cr.sub_district					like '%' + @p_keywords + '%'
				or	cr.village						like '%' + @p_keywords + '%'
				or	cr.address						like '%' + @p_keywords + '%'
				or	cr.rt							like '%' + @p_keywords + '%'
				or	cr.rw							like '%' + @p_keywords + '%'
				or	cr.area_mobile_no				like '%' + @p_keywords + '%'
				or	cr.mobile_no					like '%' + @p_keywords + '%'
				or	cr.id_no						like '%' + @p_keywords + '%'
				or	cr.npwp_no						like '%' + @p_keywords + '%'
				or	cr.shareholder_pct				like '%' + @p_keywords + '%'
				or	cr.shareholder_type				like '%' + @p_keywords + '%'
				or	case cr.is_officer
						when '1' then 'Yes'
						else 'No'
					end								like '%' + @p_keywords + '%'
				or	cr.officer_signer_type			like '%' + @p_keywords + '%'
				or	cr.officer_position_type_code	like '%' + @p_keywords + '%'
				or	cr.officer_position_type_ojk_code	like '%' + @p_keywords + '%'
				or	cr.officer_position_type_name	like '%' + @p_keywords + '%'
				or	cr.order_key					like '%' + @p_keywords + '%'
				or	case cr.is_emergency_contact
						when '1' then 'Yes'
						else 'No'
					end								like '%' + @p_keywords + '%'
				or	cr.family_type_code				like '%' + @p_keywords + '%'
				or	cr.reference_type_code			like '%' + @p_keywords + '%'
				or	case cr.is_latest
						when '1' then 'Yes'
						else 'No'
					end								like '%' + @p_keywords + '%'
				) ;

	select		cr.id
				,cr.client_code
				,cr.relation_client_code
				,cr.relation_type
				,cr.client_type
				,cr.full_name
				,cr.gender_code
				,cr.mother_maiden_name
				,cr.place_of_birth
				,cr.date_of_birth
				,cr.province_code
				,cr.province_name
				,cr.city_code
				,cr.city_name
				,cr.zip_code
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
				,cr.shareholder_type
				,cr.client_type
				,cr.counter
				,case cr.is_officer
						when '1' then 'Yes'
						else 'No'
					end 'is_officer'
				,cr.officer_signer_type
				,cr.officer_position_type_code
				,cr.officer_position_type_ojk_code
				,cr.officer_position_type_name
				,cr.order_key
				,case cr.is_emergency_contact
						when '1' then 'Yes'
						else 'No'
					end 'is_emergency_contact'
				,cr.family_type_code
				,cr.reference_type_code
				,case cr.is_latest
						when '1' then 'Yes'
						else 'No'
					end 'is_latest'
				,sgc.description 'family_type_desc'
				,cpi.full_name 'client_name'
				,sgc2.description 'gender_desc'
				,cci.full_name 'client_name_corporate'
				,@rows_count 'rowcount'
	from		client_relation cr
				left join dbo.sys_general_subcode sgc on (cr.family_type_code = sgc.code)
				left join dbo.sys_general_subcode sgc2 on (cr.gender_code	  = sgc2.code)
				left join dbo.client_personal_info cpi on (cpi.client_code	  = cr.relation_client_code)
				left join dbo.client_corporate_info cci on (cci.client_code	  = cr.relation_client_code)
	where		cr.client_code		 = @p_client_code
				and cr.relation_type = case @p_relation_type
											when '' then cr.relation_type
											else @p_relation_type
										end
				and cr.is_latest	 = case @p_is_latest
											when '' then cr.is_latest
											else @p_is_latest
										end
				and (
					cr.client_code						like '%' + @p_keywords + '%'
					or	cr.relation_client_code			like '%' + @p_keywords + '%'
					or	cr.relation_type				like '%' + @p_keywords + '%'
					or	cr.client_type					like '%' + @p_keywords + '%'
					or	cr.full_name					like '%' + @p_keywords + '%'
					or	cr.gender_code					like '%' + @p_keywords + '%'
					or	cr.mother_maiden_name			like '%' + @p_keywords + '%'
					or	cr.place_of_birth				like '%' + @p_keywords + '%'
					or	cr.date_of_birth				like '%' + @p_keywords + '%'
					or	cr.province_code				like '%' + @p_keywords + '%'
					or	cr.province_name				like '%' + @p_keywords + '%'
					or	cr.city_code					like '%' + @p_keywords + '%'
					or	cr.city_name					like '%' + @p_keywords + '%'
					or	cr.zip_code						like '%' + @p_keywords + '%'
					or	cr.zip_name						like '%' + @p_keywords + '%'
					or	cr.sub_district					like '%' + @p_keywords + '%'
					or	cr.village						like '%' + @p_keywords + '%'
					or	cr.address						like '%' + @p_keywords + '%'
					or	cr.rt							like '%' + @p_keywords + '%'
					or	cr.rw							like '%' + @p_keywords + '%'
					or	cr.area_mobile_no				like '%' + @p_keywords + '%'
					or	cr.mobile_no					like '%' + @p_keywords + '%'
					or	cr.id_no						like '%' + @p_keywords + '%'
					or	cr.npwp_no						like '%' + @p_keywords + '%'
					or	cr.shareholder_pct				like '%' + @p_keywords + '%'
					or	cr.shareholder_type				like '%' + @p_keywords + '%'
					or	case cr.is_officer
							when '1' then 'Yes'
							else 'No'
						end								like '%' + @p_keywords + '%'
					or	cr.officer_signer_type			like '%' + @p_keywords + '%'
					or	cr.officer_position_type_code	like '%' + @p_keywords + '%'
					or	cr.officer_position_type_ojk_code	like '%' + @p_keywords + '%'
					or	cr.officer_position_type_name	like '%' + @p_keywords + '%'
					or	cr.order_key					like '%' + @p_keywords + '%'
					or	case cr.is_emergency_contact
							when '1' then 'Yes'
							else 'No'
						end								like '%' + @p_keywords + '%'
					or	cr.family_type_code				like '%' + @p_keywords + '%'
					or	cr.reference_type_code			like '%' + @p_keywords + '%'
					or	case cr.is_latest
							when '1' then 'Yes'
							else 'No'
						end								like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then cr.client_code
														when 2 then cr.relation_client_code
														when 3 then cr.relation_type
														when 4 then cr.client_type
														when 5 then cr.full_name
														when 6 then cr.gender_code
														when 7 then cr.mother_maiden_name
														when 8 then cr.place_of_birth
														when 9 then cr.province_code
														when 10 then cr.province_name
														when 11 then cr.city_code
														when 12 then cr.city_name
														when 13 then cr.zip_code
														when 14 then cr.zip_name
														when 15 then cr.sub_district
														when 16 then cr.village
														when 17 then cr.address
														when 18 then cr.rt
														when 19 then cr.rw
														when 20 then cr.area_mobile_no
														when 21 then cr.mobile_no
														when 22 then cr.id_no
														when 23 then cr.npwp_no
														when 24 then cr.is_officer
														when 25 then cr.officer_signer_type
														when 26 then cr.officer_position_type_name
														when 27 then cr.is_emergency_contact
														when 28 then cr.family_type_code
														when 29 then cr.reference_type_code
														when 30 then cr.is_latest
														when 31 then cast(cr.counter as sql_variant)
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then cr.client_code
														when 2 then cr.relation_client_code
														when 3 then cr.relation_type
														when 4 then cr.client_type
														when 5 then cr.full_name
														when 6 then cr.gender_code
														when 7 then cr.mother_maiden_name
														when 8 then cr.place_of_birth
														when 9 then cr.province_code
														when 10 then cr.province_name
														when 11 then cr.city_code
														when 12 then cr.city_name
														when 13 then cr.zip_code
														when 14 then cr.zip_name
														when 15 then cr.sub_district
														when 16 then cr.village
														when 17 then cr.address
														when 18 then cr.rt
														when 19 then cr.rw
														when 20 then cr.area_mobile_no
														when 21 then cr.mobile_no
														when 22 then cr.id_no
														when 23 then cr.npwp_no
														when 24 then cr.is_officer
														when 25 then cr.officer_signer_type
														when 26 then cr.officer_position_type_name
														when 27 then cr.is_emergency_contact
														when 28 then cr.family_type_code
														when 29 then cr.reference_type_code
														when 30 then cr.is_latest
														when 31 then cast(cr.counter as sql_variant)
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;

