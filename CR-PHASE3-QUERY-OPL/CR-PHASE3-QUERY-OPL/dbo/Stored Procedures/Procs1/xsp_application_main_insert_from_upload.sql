CREATE PROCEDURE [dbo].[xsp_application_main_insert_from_upload]
(
	@p_application_no				 nvarchar(50) output
	,@p_reff_loan_no				 nvarchar(50)
	,@p_disburse_date				 datetime
	,@p_financing_amount			 decimal(18, 2)
	,@p_tenor						 int
	,@p_fintech_code				 nvarchar(50)
	,@p_application_date			 datetime
	,@p_client_code					 nvarchar(50)
	--
	,@p_cre_date					 datetime
	,@p_cre_by						 nvarchar(15)
	,@p_cre_ip_address				 nvarchar(15)
	,@p_mod_date					 datetime
	,@p_mod_by						 nvarchar(15)
	,@p_mod_ip_address				 nvarchar(15)
)
as
begin
	declare @msg						   nvarchar(max)
			,@system_date  				   datetime
			,@year						   nvarchar(2)
			,@month						   nvarchar(2)
			,@application_no			   nvarchar(50)
			,@application_external_no	   nvarchar(50)
			,@application_asset_no		   nvarchar(50)
			,@branch_code				   nvarchar(50)
			,@branch_name				   nvarchar(250)
			,@facility_code				   nvarchar(50)
			,@purpose_loan_code			   nvarchar(50)
			,@purpose_loan_ojk_code		   nvarchar(50)
			,@purpose_loan_name			   nvarchar(250)
			,@purpose_loan_detail_code	   nvarchar(50)
			,@purpose_loan_detail_ojk_code nvarchar(50)
			,@purpose_loan_detail_name	   nvarchar(250) 
			,@bank_code					   nvarchar(50)
			,@bank_name					   nvarchar(250)
			,@bank_account_no			   nvarchar(50)
			,@bank_account_name			   nvarchar(250)
			,@disbursement_plan_remark	   nvarchar(4000)
			,@currency_code				   nvarchar(3)
			,@payment_schedule_type_code   nvarchar(50)
			,@amort_type_code			   nvarchar(50)
			,@day_in_one_year			   nvarchar(10)
			,@interest_rate_type		   nvarchar(10)
			,@interest_rate_eff			   decimal(9, 6)
			,@interest_rate_flat		   decimal(9, 6)
			,@rounding_type				   nvarchar(50)
			,@rounding_amount			   decimal(18, 2) 
			,@last_due_date				   datetime ;
			
	select	@branch_code					= branch_code
			,@branch_name					= branch_name
			,@facility_code					= facility_code
			,@purpose_loan_code				= purpose_loan_code
			,@purpose_loan_ojk_code			= purpose_loan_ojk_code
			,@purpose_loan_name				= purpose_loan_name
			,@purpose_loan_detail_code		= purpose_loan_detail_code
			,@purpose_loan_detail_ojk_code	= purpose_loan_detail_ojk_code
			,@purpose_loan_detail_name		= purpose_loan_detail_name
			,@bank_code						= mf.bank_code
			,@bank_name						= mf.bank_name
			,@bank_account_no				= mf.bank_account_no
			,@bank_account_name				= mf.bank_account_name
			,@payment_schedule_type_code    = mfm.payment_schedule_type_code 
			,@amort_type_code			    = mfm.amort_type_code			   
			,@day_in_one_year			    = mfm.day_in_one_year			   
			,@interest_rate_type		    = mfm.interest_rate_type		   
			,@interest_rate_eff			    = mfm.interest_rate_eff		
			,@interest_rate_flat		    = mfm.interest_rate_flat	
			,@rounding_type				    = mfm.rounding_type			
			,@rounding_amount			    = mfm.rounding_amount		  
	from	dbo.master_fintech_mou mfm
			inner join dbo.master_fintech mf on (mf.code = mfm.fintech_code)
	where	fintech_code = @p_fintech_code ;

	set @last_due_date = dateadd(month, @p_tenor, @p_disburse_date);
	set @system_date = dbo.xfn_get_system_date();
	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @application_external_no output
												,@p_branch_code = @branch_code
												,@p_sys_document_code = N'LAP'
												,@p_custom_prefix = ''
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'APPLICATION_MAIN'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0'
												,@p_specified_column = 'APPLICATION_EXTERNAL_NO' ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @application_no output
												,@p_branch_code = @branch_code
												,@p_sys_document_code = ''
												,@p_custom_prefix = 'LAP'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'APPLICATION_MAIN'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @application_asset_no output
												,@p_branch_code = @branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'LAA'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'APPLICATION_ASSET'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	begin try 
		select	@currency_code = code
		from	ifinsys.dbo.sys_currency
		where	base_currency = '1' ;
		

		insert into application_main
		(
			application_no
			,branch_code
			,branch_name
			,application_date
			,application_status
			,level_status
			,application_external_no
			,application_remarks
			,branch_region_code
			,branch_region_name
			,plafond_group_code
			,plafond_facility_code
			,package_code
			,marketing_code
			,marketing_name
			,vendor_code
			,agent_code
			,client_code
			,facility_code
			,purpose_loan_code
			,purpose_loan_ojk_code
			,purpose_loan_name
			,purpose_loan_detail_code
			,purpose_loan_detail_ojk_code
			,purpose_loan_detail_name
			,sales_location_code
			,buyback_type
			,currency_code
			,asset_value
			,dp_amount
			,loan_amount
			,capitalize_amount
			,financing_amount
			,golive_date
			,disburse_date
			,agreement_sign_date
			,first_installment_date
			,is_blacklist_area
			,watchlist_status
			,is_blacklist_job
			,return_count
			,entry_type
			,prospect_code
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@application_no
			,@branch_code
			,@branch_name
			,@p_application_date
			,'HOLD'
			,'ENTRY'
			,@application_external_no
			,''
			,@branch_code
			,@branch_name
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,@p_client_code
			,@facility_code
			,@purpose_loan_code
			,@purpose_loan_ojk_code
			,@purpose_loan_name
			,@purpose_loan_detail_code
			,@purpose_loan_detail_ojk_code
			,@purpose_loan_detail_name
			,'SOAPP.INT'
			,'NG'
			,@currency_code
			,0
			,0
			,@p_financing_amount
			,0
			,@p_financing_amount
			,null
			,@p_disburse_date
			,null
			,null
			,'0'
			,'CLEAR'
			,'0'
			,0
			,'APPLICATION'
			,null
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
		
		insert into application_asset
		(
			asset_no
			,application_no
			,asset_type_code
			,asset_name
			,asset_condition
			,market_value
			,asset_value
			,dp_pct
			,dp_amount
			,loan_amount
			,financing_portion_pct
			,is_main_collateral
			,asset_year
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@application_asset_no
			,@application_no
			,'OTHER'
			,'DANA TUNAI'
			,'NEW'
			,@p_financing_amount
			,@p_financing_amount
			,0
			,0
			,@p_financing_amount
			,100
			,'0'
			,year(dbo.xfn_get_system_date())
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		insert into dbo.application_asset_others
		(
			asset_no
			,category_service
			,remarks
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@application_asset_no
			,N'CODTN'  
			,N'DANA TUNAI' 
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		)  
		
		insert into dbo.application_tc
		(
			application_no
			,tenor
			,dp_pct
			,dp_received_by
			,is_dp_paid
			,payment_schedule_type_code
			,amort_type_code
			,day_in_one_year
			,first_payment_type
			,interest_type
			,min_interest_eff_rate
			,min_interest_flat_rate
			,interest_rate_type
			,interest_eff_rate
			,interest_eff_rate_after_rounding
			,interest_flat_rate
			,interest_flat_rate_after_rounding
			,disbursement_date
			,last_due_date
			,residual_value_type
			,residual_value_amount
			,security_deposit_amount
			,is_security_deposit_paid
			,rounding_type
			,rounding_amount
			,floating_benchmark_code
			,floating_benchmark_name
			,floating_margin_rate
			,floating_threshold_rate
			,floating_start_period
			,floating_period_cycle
			,payment_with_code
			,installment_amount
			,number_of_step
			,is_amortization_valid
			,is_first_installment_paid
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@application_no
			,@p_tenor
			,0
			,'s'
			,'0'
			,@payment_schedule_type_code
			,@amort_type_code
			,@day_in_one_year
			,'ARR'
			,'FIXED'
			,0
			,0
			,@interest_rate_type
			,@interest_rate_eff
			,0
			,@interest_rate_flat
			,0
			,@p_disburse_date
			,@last_due_date
			,'NONE'
			,0
			,0
			,'0'
			,@rounding_type
			,@rounding_amount
			,null
			,null
			,0
			,0
			,0
			,0
			,'TRANSFER'
			,@p_financing_amount
			,0
			,'0'
			,'0'
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		exec dbo.xsp_application_tc_update @p_application_no						= @application_no
										   ,@p_tenor								= @p_tenor
										   ,@p_dp_pct								= 0
										   ,@p_dp_received_by						= N's'  
										   ,@p_payment_schedule_type_code			= @payment_schedule_type_code
										   ,@p_amort_type_code						= @amort_type_code		
										   ,@p_day_in_one_year						= @day_in_one_year		
										   ,@p_first_payment_type					= 'ARR'
										   ,@p_interest_type						= 'FIXED'
										   ,@p_min_interest_eff_rate				= 0
										   ,@p_min_interest_flat_rate				= 0
										   ,@p_interest_rate_type					= @interest_rate_type
										   ,@p_interest_eff_rate					= @interest_rate_eff
										   ,@p_interest_eff_rate_after_rounding		= 0  
										   ,@p_interest_flat_rate					= @interest_rate_flat
										   ,@p_interest_flat_rate_after_rounding	= 0  
										   ,@p_disbursement_date					= @p_disburse_date
										   ,@p_last_due_date						= @last_due_date
										   ,@p_residual_value_type					= 'NONE'
										   ,@p_residual_value_amount				= 0
										   ,@p_security_deposit_amount				= 0
										   ,@p_rounding_type						= @rounding_type	
										   ,@p_rounding_amount						= @rounding_amount	
										   ,@p_floating_threshold_rate				= 0
										   ,@p_floating_start_period				= 0  
										   ,@p_floating_period_cycle				= 0  
										   ,@p_payment_with_code					= 'TRANSFER'
										   ,@p_installment_amount					= @p_financing_amount
										   ,@p_number_of_step						= 0  
										   ,@p_floating_margin_rate					= 0  
										   ,@p_floating_benchmark_code				= null
										   ,@p_floating_benchmark_name				= null
										   ,@p_mod_date								= @p_mod_date
										   ,@p_mod_by								= @p_mod_by
										   ,@p_mod_ip_address						= @p_mod_ip_address

		insert into dbo.application_fee
		(
			application_no
			,fee_code
			,currency_code
			,default_fee_rate
			,default_fee_amount
			,fee_amount
			,fee_payment_type
			,fee_paid_amount
			,fee_reduce_disburse_amount
			,fee_capitalize_amount
			,insurance_year
			,remarks
			,is_from_package
			,is_calculated
			,is_fee_paid
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@application_no
				,mfmf.fee_code
				,@currency_code
				,mfmf.fee_rate
				,mfmf.fee_amount
				,case
					 when mfmf.fee_rate > 0 then ((mfmf.fee_rate * @p_financing_amount) / 100.00)
					 else mfmf.fee_amount
				 end
				,'REDUCE'
				,0
				,case
					 when mfmf.fee_rate > 0 then ((mfmf.fee_rate * @p_financing_amount) / 100.00)
					 else mfmf.fee_amount
				 end
				,0
				,0
				,''
				,'0'
				,'1'
				,'0'
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.master_fintech_mou_fee mfmf
				inner join dbo.master_fintech_mou mfm on (mfm.code = mfmf.mou_code)
		where	mfm.fintech_code = @p_fintech_code ;

		insert into dbo.application_charges
		(
			application_no
			,charges_code
			,dafault_charges_rate
			,dafault_charges_amount
			,calculate_by
			,charges_rate
			,charges_amount
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@application_no
				,mfmc.charges_code
				,mfmc.charges_rate
				,mfmc.charges_amount
				,mfmc.calculate_by
				,mfmc.charges_rate
				,mfmc.charges_amount
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.master_fintech_mou_charges mfmc
				inner join dbo.master_fintech_mou mfm on (mfm.code = mfmc.mou_code)
		where	mfm.fintech_code = @p_fintech_code ;

		insert into dbo.application_main_slik
		(
			application_no
			,slik_sifat_kredit_code
			,slik_sifat_kredit_ojk_code
			,slik_sifat_kredit_name
			,slik_jenis_kredit_code
			,slik_jenis_kredit_ojk_code
			,slik_jenis_kredit_name
			,slik_skim_akad_pembiayaan_code
			,slik_skim_akad_pembiayaan_ojk_code
			,slik_skim_akad_pembiayaan_name
			,slik_kategori_debitur_code
			,slik_kategori_debitur_ojk_code
			,slik_kategori_debitur_name
			,slik_jenis_penggunaan_code
			,slik_jenis_penggunaan_ojk_code
			,slik_jenis_penggunaan_name
			,slik_orientasi_penggunaan_code
			,slik_orientasi_penggunaan_ojk_code
			,slik_orientasi_penggunaan_name
			,slik_sektor_ekonomi_code
			,slik_sektor_ekonomi_ojk_code
			,slik_sektor_ekonomi_name
			,slik_jenis_bunga_code
			,slik_jenis_bunga_ojk_code
			,slik_jenis_bunga_name
			,slik_kredit_pembiayaan_prog_pemerintah_code
			,slik_kredit_pembiayaan_prog_pemerintah_ojk_code
			,slik_kredit_pembiayaan_prog_pemerintah_name
			,slik_take_over_dari_code
			,slik_take_over_dari_ojk_code
			,slik_take_over_dari_name
			,slik_sumber_dana_code
			,slik_sumber_dana_ojk_code
			,slik_sumber_dana_name
			,slik_cara_restrukturasi_code
			,slik_cara_restrukturasi_ojk_code
			,slik_cara_restrukturasi_name
			,slik_kondisi_code
			,slik_kondisi_ojk_code
			,slik_kondisi_name
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@application_no
				,slik_sifat_kredit_code
				,slik_sifat_kredit_ojk_code
				,slik_sifat_kredit_name
				,slik_jenis_kredit_code
				,slik_jenis_kredit_ojk_code
				,slik_jenis_kredit_name
				,slik_skim_akad_pembiayaan_code
				,slik_skim_akad_pembiayaan_ojk_code
				,slik_skim_akad_pembiayaan_name
				,slik_kategori_debitur_code
				,slik_kategori_debitur_ojk_code
				,slik_kategori_debitur_name
				,slik_jenis_penggunaan_code
				,slik_jenis_penggunaan_ojk_code
				,slik_jenis_penggunaan_name
				,slik_orientasi_penggunaan_code
				,slik_orientasi_penggunaan_ojk_code
				,slik_orientasi_penggunaan_name
				,slik_sektor_ekonomi_code
				,slik_sektor_ekonomi_ojk_code
				,slik_sektor_ekonomi_name
				,slik_jenis_bunga_code
				,slik_jenis_bunga_ojk_code
				,slik_jenis_bunga_name
				,slik_kredit_pembiayaan_prog_pemerintah_code
				,slik_kredit_pembiayaan_prog_pemerintah_ojk_code
				,slik_kredit_pembiayaan_prog_pemerintah_name
				,slik_take_over_dari_code
				,slik_take_over_dari_ojk_code
				,slik_take_over_dari_name
				,slik_sumber_dana_code
				,slik_sumber_dana_ojk_code
				,slik_sumber_dana_name
				,slik_cara_restrukturasi_code
				,slik_cara_restrukturasi_ojk_code
				,slik_cara_restrukturasi_name
				,slik_kondisi_code
				,slik_kondisi_ojk_code
				,slik_kondisi_name
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.master_fintech_slik_contract
		where	fintech_code = @p_fintech_code ;

		insert into dbo.application_main_sipp
		(
			application_no
			,sipp_jenis_pembiayaan_code
			,sipp_jenis_pembiayaan_ojk_code
			,sipp_jenis_pembiayaan_name
			,sipp_skema_pembiayaan_code
			,sipp_skema_pembiayaan_ojk_code
			,sipp_skema_pembiayaan_name
			,sipp_tujuan_pembiayaan_code
			,sipp_tujuan_pembiayaan_ojk_code
			,sipp_tujuan_pembiayaan_name
			,sipp_jenis_barang_atau_jasa_code
			,sipp_jenis_barang_atau_jasa_ojk_code
			,sipp_jenis_barang_atau_jasa_name
			,sipp_jenis_suku_bunga_code
			,sipp_jenis_suku_bunga_ojk_code
			,sipp_jenis_suku_bunga_name
			,sipp_mata_uang_code
			,sipp_mata_uang_ojk_code
			,sipp_mata_uang_name
			,sipp_lokasi_project_code
			,sipp_lokasi_project_ojk_code
			,sipp_lokasi_project_name
			,sipp_kategori_usaha_keuangan_berkelanjutan_code
			,sipp_kategori_usaha_keuangan_berkelanjutan_ojk_code
			,sipp_kategori_usaha_keuangan_berkelanjutan_name
			,sipp_kategori_piutang_code
			,sipp_kategori_piutang_ojk_code
			,sipp_kategori_piutang_name
			,sipp_metode_cadangan_kerugian_penurunan_nilai_code
			,sipp_metode_cadangan_kerugian_penurunan_nilai_ojk_code
			,sipp_metode_cadangan_kerugian_penurunan_nilai_name
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@application_no
				,sipp_jenis_pembiayaan_code
				,sipp_jenis_pembiayaan_ojk_code
				,sipp_jenis_pembiayaan_name
				,sipp_skema_pembiayaan_code
				,sipp_skema_pembiayaan_ojk_code
				,sipp_skema_pembiayaan_name
				,sipp_tujuan_pembiayaan_code
				,sipp_tujuan_pembiayaan_ojk_code
				,sipp_tujuan_pembiayaan_name
				,sipp_jenis_barang_atau_jasa_code
				,sipp_jenis_barang_atau_jasa_ojk_code
				,sipp_jenis_barang_atau_jasa_name
				,sipp_jenis_suku_bunga_code
				,sipp_jenis_suku_bunga_ojk_code
				,sipp_jenis_suku_bunga_name
				,sipp_mata_uang_code
				,sipp_mata_uang_ojk_code
				,sipp_mata_uang_name
				,sipp_lokasi_project_code
				,sipp_lokasi_project_ojk_code
				,sipp_lokasi_project_name
				,sipp_kategori_usaha_keuangan_berkelanjutan_code
				,sipp_kategori_usaha_keuangan_berkelanjutan_ojk_code
				,sipp_kategori_usaha_keuangan_berkelanjutan_name
				,sipp_kategori_piutang_code
				,sipp_kategori_piutang_ojk_code
				,sipp_kategori_piutang_name
				,sipp_metode_cadangan_kerugian_penurunan_nilai_code
				,sipp_metode_cadangan_kerugian_penurunan_nilai_ojk_code
				,sipp_metode_cadangan_kerugian_penurunan_nilai_name
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.master_fintech_silaras_contract
		where	fintech_code = @p_fintech_code ;
		 
		exec dbo.xsp_application_information_insert @p_application_no			= @application_no
													,@p_workflow_step			= 0 
													,@p_application_flow_code	= null
													,@p_screen_flow_code		= null
													,@p_is_refunded				= 0
													,@p_reff_loan_no			= @p_reff_loan_no
													,@p_cre_date				= @p_cre_date
													,@p_cre_by					= @p_cre_by
													,@p_cre_ip_address			= @p_cre_ip_address
													,@p_mod_date				= @p_mod_date
													,@p_mod_by					= @p_mod_by
													,@p_mod_ip_address			= @p_mod_ip_address

		exec dbo.xsp_application_amortization_calculate @p_application_no  = @application_no
														,@p_mod_date	   = @p_mod_date
														,@p_mod_by		   = @p_mod_by
														,@p_mod_ip_address = @p_mod_ip_address
		
		set @disbursement_plan_remark = 'Disburse for ' + @application_no

		exec dbo.xsp_application_disbursement_plan_insert @p_code					= N''
														  ,@p_application_no		= @application_no
														  ,@p_disbursement_to		= N'SUPPLIER'
														  ,@p_calculate_by			= N'PCT' 
														  ,@p_disbursement_pct		= 100  
														  ,@p_disbursement_amount	= 0 
														  ,@p_plan_date				= @system_date
														  ,@p_remarks				= @disbursement_plan_remark
														  ,@p_bank_code				= @bank_code			
														  ,@p_bank_name				= @bank_name			
														  ,@p_bank_account_no		= @bank_account_no	
														  ,@p_bank_account_name		= @bank_account_name
														  ,@p_cre_date				= @p_cre_date
														  ,@p_cre_by				= @p_cre_by
														  ,@p_cre_ip_address		= @p_cre_ip_address
														  ,@p_mod_date				= @p_mod_date
														  ,@p_mod_by				= @p_mod_by
														  ,@p_mod_ip_address		= @p_mod_ip_address
		

		exec dbo.xsp_application_log_insert  @p_application_no		= @application_no
											,@p_log_date			= @p_cre_date
											,@p_log_description		= N'ENTRY' 
											,@p_cre_date			= @p_cre_date
											,@p_cre_by				= @p_cre_by
											,@p_cre_ip_address		= @p_cre_ip_address
											,@p_mod_date			= @p_mod_date
											,@p_mod_by				= @p_mod_by
											,@p_mod_ip_address		= @p_mod_ip_address 
		 
		 set @p_application_no = @application_no ;

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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;




