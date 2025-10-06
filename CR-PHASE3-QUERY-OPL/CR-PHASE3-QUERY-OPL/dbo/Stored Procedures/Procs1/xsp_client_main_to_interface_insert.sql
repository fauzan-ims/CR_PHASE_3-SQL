CREATE PROCEDURE dbo.xsp_client_main_to_interface_insert
(
	@p_client_code	   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into dbo.opl_interface_client_main
		(
			code
			,client_type
			,client_no
			,client_name
			,client_group_code
			,client_group_name
			,is_validate
			,is_red_flag
			,watchlist_status
			,status_slik_checking
			,status_dukcapil_checking
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	code
				,client_type
				,client_no
				,client_name
				,client_group_code
				,client_group_name
				,is_validate
				,is_red_flag
				,watchlist_status
				,status_slik_checking
				,status_dukcapil_checking
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.client_main
		where	code = @p_client_code ;
		
		insert into dbo.opl_interface_client_personal_info
		(
			client_code
			,full_name
			,alias_name
			,mother_maiden_name
			,place_of_birth
			,date_of_birth
			,religion_type_code
			,gender_code
			,email
			,area_mobile_no
			,mobile_no
			,nationality_type_code
			,salutation_prefix_code
			,salutation_postfix_code
			,education_type_code
			,marriage_type_code
			,dependent_count
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	client_code
				,full_name
				,alias_name
				,mother_maiden_name
				,place_of_birth
				,date_of_birth
				,religion_type_code
				,gender_code
				,email
				,area_mobile_no
				,mobile_no
				,nationality_type_code
				,salutation_prefix_code
				,salutation_postfix_code
				,education_type_code
				,marriage_type_code
				,dependent_count
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.client_personal_info
		where	client_code = @p_client_code ;
		
		insert into dbo.opl_interface_client_personal_work
		(
			client_code
			,work_type_code
			,company_name
			,company_business_line
			,company_sub_business_line
			,area_phone_no
			,phone_no
			,area_fax_no
			,fax_no
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
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	client_code
				,work_type_code
				,company_name
				,company_business_line
				,company_sub_business_line
				,area_phone_no
				,phone_no
				,area_fax_no
				,fax_no
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
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.client_personal_work
		where	client_code = @p_client_code ;
		
		insert into dbo.opl_interface_client_corporate_info
		(
			client_code
			,full_name
			,est_date
			,corporate_status_code
			,business_line_code
			,sub_business_line_code
			,corporate_type_code
			,business_experience_year
			,email
			,website
			,area_mobile_no
			,mobile_no
			,area_fax_no
			,fax_no
			,contact_person_name
			,contact_person_area_phone_no
			,contact_person_phone_no
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	client_code
				,full_name
				,est_date
				,corporate_status_code
				,business_line_code
				,sub_business_line_code
				,corporate_type_code
				,business_experience_year
				,email
				,website
				,area_mobile_no
				,mobile_no
				,area_fax_no
				,fax_no
				,contact_person_name
				,contact_person_area_phone_no
				,contact_person_phone_no
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.client_corporate_info
		where	client_code = @p_client_code ;
		
		insert into dbo.opl_interface_client_corporate_notarial
		(
			code
			,client_code
			,notarial_document_code
			,document_no
			,document_date
			,notary_name
			,skmenkumham_doc_no
			,suggest_by
			,modal_dasar
			,modal_setor
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	code
				,client_code
				,notarial_document_code
				,document_no
				,document_date
				,notary_name
				,skmenkumham_doc_no
				,suggest_by
				,modal_dasar
				,modal_setor
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.client_corporate_notarial
		where	client_code = @p_client_code ;
		
		insert into dbo.opl_interface_client_address
		(
			code
			,client_code
			,address
			,province_code
			,province_name
			,city_code
			,city_name
			,zip_code
			,zip_code_code
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
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	code
				,client_code
				,address
				,province_code
				,province_name
				,city_code
				,city_name
				,zip_code
				,zip_code_code
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
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.client_address
		where	client_code = @p_client_code ;
		
		insert into dbo.opl_interface_client_asset
		(
			client_code
			,asset_type_code
			,asset_name
			,asset_value
			,reff_no
			,location
			,remarks
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	client_code
				,asset_type_code
				,asset_name
				,asset_value
				,reff_no
				,location
				,remarks
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.client_asset
		where	client_code = @p_client_code ;
		
		insert into dbo.opl_interface_client_bank
		(
			code
			,client_code
			,currency_code
			,bank_code
			,bank_name
			,bank_branch
			,bank_account_no
			,bank_account_name
			,is_default
			,is_auto_debet_bank
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	code
				,client_code
				,currency_code
				,bank_code
				,bank_name
				,bank_branch
				,bank_account_no
				,bank_account_name
				,is_default
				,is_auto_debet_bank
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.client_bank
		where	client_code = @p_client_code ;
		
		insert into dbo.opl_interface_client_bank_book
		(
			client_code
			,periode_year
			,periode_month
			,client_bank_code
			,opening_balance_amount
			,ending_balance_amount
			,total_cr_mutation_amount
			,total_db_mutation_amount
			,freq_credit_mutation
			,freq_debet_mutation
			,average_cr_mutation_amount
			,average_db_mutation_amount
			,average_balance_amount
			,highest_balance_amount
			,lowest_balance_amount
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	client_code
				,periode_year
				,periode_month
				,client_bank_code
				,opening_balance_amount
				,ending_balance_amount
				,total_cr_mutation_amount
				,total_db_mutation_amount
				,freq_credit_mutation
				,freq_debet_mutation
				,average_cr_mutation_amount
				,average_db_mutation_amount
				,average_balance_amount
				,highest_balance_amount
				,lowest_balance_amount
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.client_bank_book
		where	client_code = @p_client_code ;
		
		insert into dbo.opl_interface_client_doc
		(
			client_code
			,doc_type_code
			,document_no
			,doc_status
			,eff_date
			,exp_date
			,is_default
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	client_code
				,doc_type_code
				,document_no
				,doc_status
				,eff_date
				,exp_date
				,is_default
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.client_doc
		where	client_code = @p_client_code ;
		  
		insert into dbo.opl_interface_client_relation
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
			,shareholder_type
			,shareholder_pct
			,is_officer
			,officer_signer_type
			,officer_position_type_code
			,order_key
			,is_emergency_contact
			,family_type_code
			,reference_type_code
			,is_latest
			,counter
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
		select	client_code
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
				,shareholder_type
				,shareholder_pct
				,is_officer
				,officer_signer_type
				,officer_position_type_code
				,order_key
				,is_emergency_contact
				,family_type_code
				,reference_type_code
				,is_latest
				,counter
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
		from	dbo.client_relation
		where	client_code = @p_client_code ;

		insert into dbo.opl_interface_client_kyc
		(
			client_code
			,ao_remark
			,ao_source_fund
			,result_status
			,result_remark
			,kyc_officer_code
			,kyc_officer_name
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	client_code
				,ao_remark
				,ao_source_fund
				,result_status
				,result_remark
				,kyc_officer_code
				,kyc_officer_name
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
		from	dbo.client_kyc
		where	client_code = @p_client_code ;

		insert into dbo.opl_interface_client_kyc_detail
		(
			client_code
			,member_type
			,member_code
			,member_name
			,is_pep
			,remarks_pep
			,is_slik
			,remarks_slik
			,is_dtto
			,remarks_dtto
			,is_proliferasi
			,remarks_proliferasi
			,is_npwp
			,remarks_npwp
			,is_dukcapil
			,remarks_dukcapil
			,is_jurisdiction
			,remarks_jurisdiction
			,remarks
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	client_code
				,member_type
				,member_code
				,member_name
				,is_pep
				,remarks_pep
				,is_slik
				,remarks_slik
				,is_dtto
				,remarks_dtto
				,is_proliferasi
				,remarks_proliferasi
				,is_npwp
				,remarks_npwp
				,is_dukcapil
				,remarks_dukcapil
				,is_jurisdiction
				,remarks_jurisdiction
				,remarks
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
		from	dbo.client_kyc_detail
		where	client_code = @p_client_code ;

		insert into dbo.opl_interface_client_log
		(
			client_code
			,log_date
			,log_remarks
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	client_code
				,log_date
				,log_remarks
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.client_log
		where	client_code = @p_client_code ;
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



