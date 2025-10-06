CREATE PROCEDURE dbo.xsp_client_personal_info_insert_from_upload
(
	@p_code									nvarchar(50)  output
	,@p_client_no							nvarchar(50)  = null
	,@p_full_name							nvarchar(250)
	,@p_mother_maiden_name					nvarchar(250)
	,@p_ktp_no								nvarchar(50)
	,@p_npwp_no								nvarchar(50)
	,@p_place_of_birth						nvarchar(250)
	,@p_date_of_birth						datetime
	,@p_religion_type_code					nvarchar(50)
	,@p_gender_code							nvarchar(50)
	,@p_marriage_type_code					nvarchar(50)
	,@p_area_mobile_no						nvarchar(4)
	,@p_mobile_no							nvarchar(15)
	,@p_dependent_count						int
	--
	,@p_address								nvarchar(4000)
	,@p_province_code						nvarchar(50)
	,@p_province_name						nvarchar(250)
	,@p_city_code							nvarchar(50)
	,@p_city_name							nvarchar(250)
	,@p_zip_code_code						nvarchar(50)
	,@p_zip_code							nvarchar(50)
	,@p_zip_name							nvarchar(250)
	,@p_sub_district						nvarchar(250)
	,@p_village								nvarchar(250)
	,@p_lenght_of_stay						int
	--
	,@p_spouse_name							nvarchar(250)
	,@p_spouse_place_of_birth				nvarchar(250)
	,@p_spouse_date_of_birth				datetime
	,@p_spouse_area_mobile_no				nvarchar(4)
	,@p_spouse_mobile_no					nvarchar(15)
	,@p_spouse_ktp_no						nvarchar(50)
	--
	,@p_reference_name						nvarchar(250)
	,@p_reference_address					nvarchar(4000)
	,@p_reference_area_mobile_no			nvarchar(4)
	,@p_reference_mobile_no					nvarchar(15)
	,@p_reference_ktp_no					nvarchar(50)
	--
	,@p_company_name						nvarchar(250)
	,@p_work_type_code						nvarchar(50)
	,@p_work_address						nvarchar(4000)
	--
	,@p_slik_status_pendidikan_code			nvarchar(50)
	,@p_slik_bid_ush_tmpt_kerja_code		nvarchar(50)
	,@p_slik_pekerjaan_code					nvarchar(50)
	,@p_slik_status_pendidikan_ojk_code		nvarchar(50)
	,@p_slik_bid_ush_tmpt_kerja_ojk_code	nvarchar(50)
	,@p_slik_pekerjaan_ojk_code				nvarchar(50)
	,@p_slik_status_pendidikan_name			nvarchar(250)
	,@p_slik_bid_ush_tmpt_kerja_name		nvarchar(250)
	,@p_slik_pekerjaan_name					nvarchar(250)
	,@p_slik_pnghslan_per_thn_amount		decimal(18, 2)
	,@p_slik_sumber_penghasilan_code		nvarchar(50)
	,@p_slik_sumber_penghasilan_ojk_code	nvarchar(50)
	,@p_slik_sumber_penghasilan_name		nvarchar(250)
	,@p_slik_dati_ii_code					nvarchar(50)
	,@p_slik_dati_ii_ojk_code				nvarchar(50)
	,@p_slik_dati_ii_name					nvarchar(250)
	--
	,@p_sipp_sektor_ekonomi_debtor_code		nvarchar(50)
	,@p_sipp_sektor_ekonomi_debtor_ojk_code nvarchar(50)
	,@p_sipp_sektor_ekonomi_debtor_name		nvarchar(250)
	-- 
	,@p_client_group_code					nvarchar(50)  = null
	,@p_client_group_name					nvarchar(250) = null
	--
	,@p_cre_date							datetime
	,@p_cre_by								nvarchar(15)
	,@p_cre_ip_address						nvarchar(15)
	,@p_mod_date							datetime
	,@p_mod_by								nvarchar(15)
	,@p_mod_ip_address						nvarchar(15)
)
as
begin
	declare @msg		   nvarchar(max)
			,@year		   nvarchar(2)
			,@month		   nvarchar(2)
			,@client_code  nvarchar(50)
			,@client_no	   nvarchar(50)
			,@address_code nvarchar(50) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @client_code output
												,@p_branch_code = ''
												,@p_sys_document_code = ''
												,@p_custom_prefix = 'LCP'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'CLIENT_PERSONAL_INFO'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	if (isnull(@p_client_no, '') = '')
	begin
		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @client_no output
													,@p_branch_code = ''
													,@p_sys_document_code = 'LCP'
													,@p_custom_prefix = ''
													,@p_year = @year
													,@p_month = @month
													,@p_table_name = 'CLIENT_MAIN'
													,@p_run_number_length = 6
													,@p_delimiter = '.'
													,@p_run_number_only = N'0'
													,@p_specified_column = 'CLIENT_NO' ;
	end ;
	else
	begin
		set @client_no = @p_client_no ;
	end ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @address_code output
												,@p_branch_code = ''
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'LAD'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'CLIENT_ADDRESS'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	begin try 
		if (@p_date_of_birth > dbo.xfn_get_system_date())
		begin
			set @msg = 'Date of Birth must be less or equal than System Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		exec dbo.xsp_client_main_insert @p_code							= @client_code
										,@p_client_no					= @client_no
										,@p_client_type					= 'PERSONAL'
										,@p_client_name					= @p_full_name
										,@p_is_validate					= 'T'
										,@p_status_slik_checking		= ''
										,@p_status_dukcapil_checking	= ''
										,@p_client_group_code			= @p_client_group_code
										,@p_client_group_name			= @p_client_group_name
										,@p_cre_date					= @p_cre_date
										,@p_cre_by						= @p_cre_by
										,@p_cre_ip_address				= @p_cre_ip_address
										,@p_mod_date					= @p_mod_date
										,@p_mod_by						= @p_mod_by
										,@p_mod_ip_address				= @p_mod_ip_address ;

		insert into client_personal_info
		(
			client_code
			,full_name
			,alias_name
			,mother_maiden_name
			,place_of_birth
			,date_of_birth
			,religion_type_code
			,gender_code
			,marriage_type_code
			,area_mobile_no
			,mobile_no
			,dependent_count
			,nationality_type_code
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@client_code
			,upper(@p_full_name)
			,upper(@p_full_name)
			,upper(@p_mother_maiden_name)
			,upper(@p_place_of_birth)
			,@p_date_of_birth
			,@p_religion_type_code
			,@p_gender_code
			,@p_marriage_type_code
			,@p_area_mobile_no
			,@p_mobile_no
			,@p_dependent_count
			,'WNI'
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		insert into client_address
		(
			code
			,client_code
			,address
			,province_code
			,province_name
			,city_code
			,city_name
			,zip_code_code
			,zip_code
			,zip_name
			,sub_district
			,village
			,rt
			,rw
			,area_phone_no
			,phone_no
			,is_legal
			,is_collection
			,is_mailing
			,is_residence
			,range_in_km
			,ownership
			,lenght_of_stay
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@address_code
			,@client_code
			,@p_address
			,@p_province_code
			,@p_province_name
			,@p_city_code
			,@p_city_name
			,@p_zip_code_code
			,@p_zip_code
			,@p_zip_name
			,@p_sub_district
			,@p_village
			,'00'
			,'00'
			,@p_area_mobile_no
			,@p_mobile_no
			,'1'
			,'1'
			,'1'
			,'1'
			,0
			,'PRIBADI'
			,@p_lenght_of_stay
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		if (isnull(@p_spouse_ktp_no, '')  <> '')
		begin
		    
		insert into client_relation
		(
			client_code
			,relation_client_code
			,relation_type
			,client_type
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
			,shareholder_pct
			,is_officer
			,officer_signer_type
			,officer_position_type_code
			,officer_position_type_ojk_code
			,officer_position_type_name
			,order_key
			,is_emergency_contact
			,family_type_code
			,reference_type_code
			,is_latest
			,counter
			,shareholder_type
			,dati_ii_code
			,dati_ii_ojk_code
			,dati_ii_name
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@client_code
			,null
			,'FAMILY'
			,'PERSONAL'
			,@p_spouse_name
			,null
			,null
			,@p_spouse_place_of_birth
			,@p_spouse_date_of_birth
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,@p_spouse_area_mobile_no
			,@p_spouse_mobile_no
			,@p_spouse_ktp_no
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
		end 

		if (isnull(@p_reference_ktp_no, '') <> '')
		begin
			insert into client_relation
			(
				client_code
				,relation_client_code
				,relation_type
				,client_type
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
				,shareholder_pct
				,is_officer
				,officer_signer_type
				,officer_position_type_code
				,officer_position_type_ojk_code
				,officer_position_type_name
				,order_key
				,is_emergency_contact
				,family_type_code
				,reference_type_code
				,is_latest
				,counter
				,shareholder_type
				,dati_ii_code
				,dati_ii_ojk_code
				,dati_ii_name
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			values
			(	@client_code
				,null
				,'REFERENCE'
				,'PERSONAL'
				,@p_reference_name
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,@p_reference_address
				,null
				,null
				,@p_reference_area_mobile_no
				,@p_reference_mobile_no
				,@p_reference_ktp_no
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
			) ;
		end ;

		insert into client_personal_work
		(
			client_code
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
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@client_code
			,upper(@p_company_name)
			,'JOB0015'	   -- pertanyaan
			,'SUBJOB0015'  -- pertanyaan
			,null
			,null
			,null
			,null
			,@p_work_type_code
			,''
			,getdate()
			,null
			,''
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,@p_work_address
			,null
			,null
			,'0'
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		insert into client_doc
		(
			client_code
			,doc_type_code
			,document_no
			,doc_status
			,eff_date
			,exp_date
			,is_default
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@client_code
			,'KTP'
			,upper(@p_ktp_no)
			,'EXIST'
			,getdate()
			,null
			,'1'
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		if (isnull(@p_npwp_no, '') <> '')
		begin
			insert into client_doc
			(
				client_code
				,doc_type_code
				,document_no
				,doc_status
				,eff_date
				,exp_date
				,is_default
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			values
			(	@client_code
				,'TAXID'
				,upper(@p_npwp_no)
				,'EXIST'
				,getdate()
				,null
				,'1'
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
			) ;
		end ;

		insert into client_slik
		(
			client_code
			,slik_status_pendidikan_code
			,slik_bid_ush_tmpt_kerja_code
			,slik_pekerjaan_code
			,slik_status_pendidikan_ojk_code
			,slik_bid_ush_tmpt_kerja_ojk_code
			,slik_pekerjaan_ojk_code
			,slik_status_pendidikan_name
			,slik_bid_ush_tmpt_kerja_name
			,slik_pekerjaan_name
			,slik_pnghslan_per_thn_amount
			,slik_sumber_penghasilan_code
			,slik_hub_pelapor_code
			,slik_golongan_debitur_code
			,slik_sumber_penghasilan_ojk_code
			,slik_hub_pelapor_ojk_code
			,slik_golongan_debitur_ojk_code
			,slik_sumber_penghasilan_name
			,slik_hub_pelapor_name
			,slik_golongan_debitur_name
			,slik_perj_pisah_harta
			,slik_mlnggar_bts_maks_krdit
			,slik_mlmpui_bts_maks_krdit
			,slik_is_go_public
			,slik_lemb_pemeringkat_debitur_code
			,slik_lemb_pemeringkat_debitur_ojk_code
			,slik_lemb_pemeringkat_debitur_name
			,slik_tgl_pemeringkatan
			,slik_rating_debitur
			,slik_dati_ii_code
			,slik_dati_ii_ojk_code
			,slik_dati_ii_name
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@client_code
			,@p_slik_status_pendidikan_code
			,@p_slik_bid_ush_tmpt_kerja_code
			,@p_slik_pekerjaan_code
			,@p_slik_status_pendidikan_ojk_code
			,@p_slik_bid_ush_tmpt_kerja_ojk_code
			,@p_slik_pekerjaan_ojk_code
			,@p_slik_status_pendidikan_name
			,@p_slik_bid_ush_tmpt_kerja_name
			,@p_slik_pekerjaan_name
			,@p_slik_pnghslan_per_thn_amount
			,@p_slik_sumber_penghasilan_code
			,null
			,null
			,@p_slik_sumber_penghasilan_ojk_code
			,null
			,null
			,@p_slik_sumber_penghasilan_name
			,null
			,null
			,null
			,null
			,null
			,'0'
			,null
			,null
			,null
			,null
			,0
			,@p_slik_dati_ii_code
			,@p_slik_dati_ii_ojk_code
			,@p_slik_dati_ii_name
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		insert into client_sipp
		(
			client_code
			,sipp_kelompok_debtor_code
			,sipp_kategori_debtor_code
			,sipp_golongan_debtor_code
			,sipp_hub_debtor_dg_pp_code
			,sipp_sektor_ekonomi_debtor_code
			,sipp_kelompok_debtor_ojk_code
			,sipp_kategori_debtor_ojk_code
			,sipp_golongan_debtor_ojk_code
			,sipp_hub_debtor_dg_pp_ojk_code
			,sipp_sektor_ekonomi_debtor_ojk_code
			,sipp_kelompok_debtor_name
			,sipp_kategori_debtor_name
			,sipp_golongan_debtor_name
			,sipp_hub_debtor_dg_pp_name
			,sipp_sektor_ekonomi_debtor_name
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@client_code
			,null
			,null
			,null
			,null
			,@p_sipp_sektor_ekonomi_debtor_code
			,null
			,null
			,null
			,null
			,@p_sipp_sektor_ekonomi_debtor_ojk_code
			,null
			,null
			,null
			,null
			,@p_sipp_sektor_ekonomi_debtor_name
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_code = @client_code ;
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ; 
end ;

