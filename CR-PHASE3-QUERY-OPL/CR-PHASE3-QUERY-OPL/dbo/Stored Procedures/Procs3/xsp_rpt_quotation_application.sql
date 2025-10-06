--created by, Jeff at 26/08/2023 

CREATE PROCEDURE dbo.xsp_rpt_quotation_application
(
	@p_user_id		   nvarchar(max)
	,@p_application_no nvarchar(50)
	--
	,@p_cre_date	   DATETIME
	,@p_cre_by		   NVARCHAR(15)
	,@p_cre_ip_address NVARCHAR(15)
	,@p_mod_date	   DATETIME
	,@p_mod_by		   NVARCHAR(15)
	,@p_mod_ip_address NVARCHAR(15)
)
AS
begin
	delete dbo.rpt_quotation_application
	where	user_id = @p_user_id ;

	--delete dbo.rpt_quotation_application_detail
	--where	user_id = @p_user_id ;

	declare @msg							nvarchar(max)
			,@report_company				nvarchar(250)
			,@report_image					nvarchar(250)
			,@report_title					nvarchar(250)
			,@tanggal						datetime
			,@surat_no						nvarchar(50)
			,@kepada						nvarchar(250)
			,@merk							nvarchar(50)
			,@model							nvarchar(50)
			,@jenis_bahan_bakar				nvarchar(50)
			,@transmisi						nvarchar(250)
			,@warna_plat					nvarchar(50)
			,@tahun							nvarchar(4)
			,@silinder						int
			,@kode_mesin					nvarchar(50)
			,@kapasitas						int
			,@muatan						int
			,@tipe_karoseri					nvarchar(50)
			,@nilai_sisa					decimal(18, 2)
			,@baru_atau_bekas				nvarchar(50)
			,@aksesoris						nvarchar(250)
			,@periode						int
			,@tanggal_pengiriman			datetime
			,@pemakaian_perbln				int
			,@nilai_sewa_perbln				decimal(18, 2)
			,@uang_jaminan					decimal(18, 2)
			,@tenggang_waktu				int
			,@lokasi_pengiriman				nvarchar(250)
			,@is_kontrak_sewa_termaksuk		nvarchar(1)
			,@is_kontrak_sewa_tdk_termaksuk nvarchar(1)
			,@is_harga						nvarchar(1)
			,@is_aksesoris					nvarchar(1)
			,@is_stnk						nvarchar(1)
			,@is_asuransi					nvarchar(1)
			,@is_penganti					nvarchar(1)
			,@is_perbaikan					nvarchar(1)
			,@is_bantuan					nvarchar(1)
			,@is_darurat					nvarchar(1)
			,@is_lain_lain					nvarchar(1)
			,@is_pemeliharaan				nvarchar(1) = 'V'
			,@is_suku_cadang				nvarchar(1) = 'V' 
			,@is_oli						nvarchar(1) = 'V' 
			,@is_aki						nvarchar(1) = 'V' 
			,@is_ban						nvarchar(1) = 'V' 
			,@is_konsumen					nvarchar(1) = 'V'  
			,@is_komprehensif_termaksuk		nvarchar(1)
			,@is_komprehensif_tdk_termasuk	nvarchar(1)
			,@is_third_party				nvarchar(1)
			,@is_passenger					nvarchar(1)
			,@is_personal_passenger			nvarchar(1)
			,@is_personal_driver			nvarchar(1)
			,@is_pemogokan					nvarchar(1)
			,@is_terorisme					nvarchar(1)
			,@is_banjir						nvarchar(1)
			,@is_gempa						nvarchar(1)
			,@is_nilai						nvarchar(1)
			,@is_cop						nvarchar(1)
			,@keterangan					nvarchar(250)
			,@year							nvarchar(4)
			,@month							nvarchar(2)
			,@branch_code					nvarchar(10)
			,@asset_no						nvarchar(50)
			,@nomor_surat					nvarchar(50) 
			,@unit_amount					decimal(18,2)
			,@aksesoris_amount 		        decimal(18,2)
			,@karoseri_amount		        decimal(18,2)
			,@registration_amount 			decimal(18,2)
			,@insurance_amount    			decimal(18,2)
			,@replacement_amount  			decimal(18,2)
			,@maintenance_amount  			decimal(18,2)
			,@company_address	 			nvarchar(4000)
			,@company_telp_area	 			nvarchar(50)
			,@company_telp_area1	 		nvarchar(50)
			,@company_telp	 				nvarchar(50)
			,@company_fax	 				nvarchar(50)
			,@unit_code						nvarchar(50)
			,@report_address				nvarchar(250)
			,@ho_branch_code				nvarchar(50)
			,@company_fax_area				nvarchar(5)
			,@company_fax_phone				nvarchar(50)
			,@email_client					nvarchar(50)
			,@nama_head						nvarchar(50)
			,@jabatan						nvarchar(50)
			,@to_phone						nvarchar(50)
			,@nama_user						nvarchar(50)
			,@jabatan_user					nvarchar(50)
			,@pay_own_risk_lessor_amount	decimal(18,2)
			,@pay_own_risk_amount			decimal(18,2)
			,@count_lease_rent				int				= 1
			,@partial_total_loss_pct		decimal(18,2)
			,@partial_total_loss_amount		decimal(18,2)
			,@telp_user						nvarchar(50)
			,@subject						nvarchar(250)
			,@vat_pct						decimal(18,2)
			,@withholding_pct				decimal(18,2)
			,@rv_amount						decimal(18,2)
			,@branch_name					nvarchar(50)
			,@nama_object					nvarchar(250)
			,@insurance_tpl					nvarchar(50)
			,@insurance_pll					nvarchar(50)
			,@insurance_pad 				nvarchar(50)
			,@insurance_pap 				nvarchar(50)
			,@insurance_srccts 				nvarchar(50)
			,@insurance_paseat				nvarchar(50)
			,@claim_pct						nvarchar(50)
			,@claim_amount					nvarchar(50)
			,@billing_type					nvarchar(50)
			,@payment_type					nvarchar(50)
			,@credit_term					nvarchar(50)
			,@remark						nvarchar(250)
			,@marketing_code				nvarchar(50)
			,@is_tbod						nvarchar(1)

	BEGIN TRY

		DECLARE @rpt_quotation_temp TABLE
		(
			USER_ID						nvarchar(50)					COLLATE Latin1_General_CI_AS
			,REPORT_COMPANY				nvarchar(50)					COLLATE Latin1_General_CI_AS
			,REPORT_IMAGE				nvarchar(250)					COLLATE Latin1_General_CI_AS
			,REPORT_TITLE				nvarchar(250)					COLLATE Latin1_General_CI_AS
			,REPORT_ADDRESS				nvarchar(4000)					COLLATE Latin1_General_CI_AS
			,APPLICATION_NO				nvarchar(50)					COLLATE Latin1_General_CI_AS
			,CLIENT_NAME				nvarchar(250)					COLLATE Latin1_General_CI_AS
			,ATTN_NAME					nvarchar(250)					COLLATE Latin1_General_CI_AS
			,PHONE_NO_TO				nvarchar(50)					COLLATE Latin1_General_CI_AS
			,EMAIL						nvarchar(250)					COLLATE Latin1_General_CI_AS
			,SUBJECT					nvarchar(250)					COLLATE Latin1_General_CI_AS
			,FROM_NAME					nvarchar(250)					COLLATE Latin1_General_CI_AS
			,DATE						datetime
			,PHONE_NO_FROM				nvarchar(50)					COLLATE Latin1_General_CI_AS
			,MOBILE_FROM				nvarchar(50)					COLLATE Latin1_General_CI_AS
			,PRODUCT					nvarchar(250)					COLLATE Latin1_General_CI_AS
			,VAT_PCT					decimal(18, 2)
			,WITHHOLDING_TAX			decimal(18, 2)
			,IS_STNK					nvarchar(1)						COLLATE Latin1_General_CI_AS
			,IS_ASURANSI				nvarchar(1)						COLLATE Latin1_General_CI_AS
			,IS_PENGANTI				nvarchar(1)						COLLATE Latin1_General_CI_AS
			,IS_PERBAIKAN				nvarchar(1)						COLLATE Latin1_General_CI_AS
			,IS_BANTUAN					nvarchar(1)						COLLATE Latin1_General_CI_AS
			,IS_DARURAT					nvarchar(1)						COLLATE Latin1_General_CI_AS
			,IS_LAIN_LAIN				nvarchar(1)						COLLATE Latin1_General_CI_AS
			,IS_PEMELIHARAAN			nvarchar(1)						COLLATE Latin1_General_CI_AS
			,IS_SUKU_CADANG				nvarchar(1)						COLLATE Latin1_General_CI_AS
			,IS_OLI						nvarchar(1)						COLLATE Latin1_General_CI_AS
			,IS_PASSENGER				nvarchar(1)						COLLATE Latin1_General_CI_AS
			,IS_PERSONAL_PASSENGER		nvarchar(1)						COLLATE Latin1_General_CI_AS
			,IS_PERSONAL_DRIVER			nvarchar(1)						COLLATE Latin1_General_CI_AS
			,IS_PEMOGOKAN				nvarchar(1)						COLLATE Latin1_General_CI_AS
			,IS_TERORISME				nvarchar(1)						COLLATE Latin1_General_CI_AS
			,IS_BANJIR					nvarchar(1)						COLLATE Latin1_General_CI_AS
			,IS_GEMPA					nvarchar(1)						COLLATE Latin1_General_CI_AS
			,IS_NILAI					nvarchar(1)						COLLATE Latin1_General_CI_AS
			,IS_THIRD_PARTY				nvarchar(1)						COLLATE Latin1_General_CI_AS
			,IS_COP						nvarchar(1)						COLLATE Latin1_General_CI_AS
			,IS_TBOD					nvarchar(1)						COLLATE Latin1_General_CI_AS
			,TPL						decimal(18,2)
			,PPL						decimal(18,2)
			,PA_PASSENGER_AMOUNT		decimal(18,2)
			,PA_PASSENGER_SEAT			int
			,PA_DRIVER_AMOUNT			decimal(18,2)
			,PAY_OWN_RISK_AMOUNT		decimal(18, 2)
			,COUNT_LEASE_RENT			int
			,PAY_OWN_RISK_LESSOR_AMOUNT decimal(18, 2)
			,PARTIAL_TOTAL_LOSS_PCT		decimal(18, 2)
			,PARTIAL_TOTAL_LOSS_AMOUNT	decimal(18, 2)
			,CLAIM_AMOUNT_PCT			decimal(18, 2)
			,CLAIM_AMOUNT_TERBILANG		nvarchar(250)					COLLATE Latin1_General_CI_AS
			,CLAIM_AMOUNT				decimal(18, 2)
			,NAMA_USER					nvarchar(50)					COLLATE Latin1_General_CI_AS
			,JABATAN_USER				nvarchar(50)					COLLATE Latin1_General_CI_AS
			,UNIT_CODE					nvarchar(50)					COLLATE Latin1_General_CI_AS
			,ASSET_NO					nvarchar(50)					COLLATE Latin1_General_CI_AS
			,TYPE_OF_UNIT				nvarchar(500)					COLLATE Latin1_General_CI_AS
			,QUANTITY					int
			,YEAR						nvarchar(4)						COLLATE Latin1_General_CI_AS
			,LEASE_PERIOD				int
			,MONTHLY_LEASED_RENT_AMOUNT decimal(18, 2)
			,RV_AMOUNT					decimal(18, 2)
			,CREDIT_TERM				nvarchar(50)					COLLATE Latin1_General_CI_AS
			,BILLING_TYPE				nvarchar(50)					COLLATE Latin1_General_CI_AS
			,PAYMENT_TYPE				nvarchar(50)					COLLATE Latin1_General_CI_AS
			,REMARK						nvarchar(250)					COLLATE Latin1_General_CI_AS
			,PREVIOUS_CONTRACT_NUMBER	nvarchar(50)					COLLATE Latin1_General_CI_AS
			,CRE_BY						nvarchar(50)					COLLATE Latin1_General_CI_AS
			,CRE_DATE					datetime
			,CRE_IP_ADDRESS				nvarchar(50)					COLLATE Latin1_General_CI_AS
			,MOD_BY						nvarchar(50)					COLLATE Latin1_General_CI_AS
			,MOD_DATE					datetime
			,MOD_IP_ADDRESS				nvarchar(50)					COLLATE Latin1_General_CI_AS
		) ;

		select	@branch_code		= branch_code
				,@tanggal			= convert(nvarchar(50), application_date,106)
				,@tenggang_waktu	= credit_term
				,@kepada			= client_name
				,@email_client		= client_email
				,@to_phone			= client_phone_area+'-'+client_phone_no
				,@subject			= application_remarks	
		from	dbo.application_main
		where	application_no = @p_application_no ;

		delete dbo.rpt_quotation
		where	user_id = @p_user_id ;

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;
		
		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		select	@company_telp_area1 = value
		from	dbo.sys_global_param
		where	code = 'TELP' ;

		select	@company_fax = value
		from	dbo.sys_global_param
		where	code = 'TELP' ;

		select	@ho_branch_code = value
		from	dbo.SYS_GLOBAL_PARAM
		where	code = 'HO' ;

		select	@report_address = address
				,@company_telp_area = area_phone_no
				,@company_telp_area1 = phone_no
				,@company_fax_area = area_fax_no
				,@company_fax_phone = fax_no
				,@branch_name = name
		from	ifinsys.dbo.sys_branch
		where	code = @branch_code;

		select	@nama_user = name
				,@jabatan_user = sps.description
				,@telp_user = sem.AREA_PHONE_NO + '-' + sem.PHONE_NO
		from	ifinsys.dbo.sys_employee_main sem
				inner join ifinsys.dbo.sys_employee_position sep on sem.code			  = sep.emp_code
																	and sep.base_position = '1'
				left join ifinsys.dbo.sys_position sps on sps.code						  = sep.position_code
		where	sem.code = @p_user_id ;

		--select	@nama_head = sbs.signer_name
		--		,@jabatan = spo.description
		--from	ifinsys.dbo.sys_branch_signer sbs
		--		--inner join ifinsys.dbo.sys_employee_position sep on sep.emp_code		  = sbs.emp_code
		--		--													and sep.base_position = '1'
		--		--inner join ifinsys.dbo.sys_position spo on spo.code						  = sep.position_code
		--		outer apply
		--			(
		--				select	*
		--				from	ifinsys.dbo.sys_employee_position sep
		--				where	sep.emp_code		  = sbs.emp_code
		--						and sep.base_position = '1'
		--			) sep
		--		outer apply
		--			(
		--				select	*
		--				from	ifinsys.dbo.sys_position spo
		--				where	spo.code = sep.position_code
		--			) spo
		--where	sbs.signer_type_code = 'SQAP'
		--		and sbs.branch_code	 = @branch_code ;

		select	@marketing_code = marketing_code
		from	application_main
		where	application_no = @p_application_no ;

		select	@nama_head = sem_2.name
				,@jabatan = spo.description
		from	ifinsys.dbo.sys_employee_main sem
				left join ifinsys.dbo.sys_employee_main sem_2 on sem_2.code = sem.head_emp_code
		--		outer apply
				--(
				--	select	*
				--	from	ifinsys.dbo.sys_employee_branch seb
				--	where	sem_2.code		= seb.emp_code
				--			and seb.is_base = '1'
				--) seb
				outer apply
				(
					select	sep.position_code 
					from	ifinsys.dbo.sys_employee_position sep
					where	sep.emp_code		  = sem_2.code
							and sep.base_position = '1'
				) sep
				outer apply
				(
					select	spo.description
					from	ifinsys.dbo.sys_position spo
					where	code = sep.position_code
				) spo
			--seb.branch_code = @branch_code
			--	and 
		where		sem.code	= @marketing_code ;

		set @company_telp = @company_telp_area + ' ' + @company_telp_area1

		set @company_fax = @company_fax_area + ' ' + @company_fax_phone

		set @report_title = 'Report Quotation' ;

		select	@pay_own_risk_lessor_amount = value
		from	dbo.sys_global_param
		where	code = 'PORLA' ;

		select	@pay_own_risk_amount = value
		from	dbo.sys_global_param
		where	code = 'PORA' ;

		select	@partial_total_loss_pct = value
		from	dbo.sys_global_param
		where	code = 'PTLP' ;

		select	@partial_total_loss_amount = value
		from	dbo.sys_global_param
		where	code = 'PTLA' ;

		select	@vat_pct = value
		from	dbo.sys_global_param
		where	code = 'RTAXPPN' ;

		select	@withholding_pct = value
		from	dbo.sys_global_param
		where	code = 'RTAXPPH' ;

		select	@claim_pct = value
		from	dbo.sys_global_param
		where	code = 'LPPCA' ;

		select	@claim_amount = value
		from	dbo.sys_global_param
		where	code = 'LPPCAA' ;

		declare c_application_asset cursor local for
		--select	asset_no
		--from	dbo.application_asset
		--where	application_no = @p_application_no ;

		select		 aas.ASSET_NO
					,asv.vehicle_unit_code
					,asv.merk_desc
					,asv.model_desc
					,asv.transmisi
					,aas.plat_colour
					,aas.asset_year
					,asdkr.description
					,aas.asset_rv_amount
					,aas.asset_condition
					--,asdac.description
					,aas.periode
					,aas.request_delivery_date
					,aas.monthly_miles
					,aas.lease_rounded_amount
					,aas.deliver_to_address
					,aas.surat_no
					,aas.market_value
					,aas.accessories_amount
					,aas.karoseri_amount
					,ama.is_purchase_requirement_after_lease
					,aas.ASSET_RV_AMOUNT
					,aas.asset_name
					,ama.billing_type
					,case
						when ama.first_payment_type ='ADV' then 'Advance'
						when ama.first_payment_type ='ARR' then 'Arrear'
						else ''
					  end
					,ama.credit_term
					,case
						WHEN is_use_tpl = 1 then 'V'
					 	else 'X'
					 END
                    ,case
				  		WHEN IS_USE_PLL = 1 then 'V'
				  		ELSE 'X'
					 END
                    ,case
					   	when is_use_pa_passenger = 1 then 'V'
					   	else 'X'
					 END
                    ,case
						when is_use_pa_driver = 1 then 'V'
						else 'X'
					 END
                    ,case
						when is_use_srcc = 1 then 'V'
						else 'X'
					 END
					,case
						when is_use_ts = 1 then 'V'
						else 'X'
					 END
					,case
						when is_use_flood = 1 then 'V'
						else 'X'
					 END
					,case
						when is_use_earthquake = 1 then 'V'
						else 'X'
					 END
					,case
						when is_tbod = 1 then 'V'
						else 'X'
					 END
					,case
						when main_coverage_code = 'TLO' then 'V'
						else 'X'
					 END
			from	dbo.application_asset aas 
					outer apply
					(
						select	asv.vehicle_unit_code
								,asv.transmisi
								,mvm.description 'merk_desc'
								,mvmo.description 'model_desc'
						from	dbo.application_asset_vehicle asv
								left join dbo.master_vehicle_merk mvm on (mvm.code	  = asv.vehicle_merk_code)
								left join dbo.master_vehicle_model mvmo on (mvmo.code = asv.vehicle_model_code)
						where	asv.asset_no = aas.asset_no
					) asv
					outer apply
					(
						select	is_purchase_requirement_after_lease
								,first_payment_type
								,ama.credit_term
								,mbt.description 'billing_type'
						from	dbo.application_main ama
								left join dbo.master_billing_type mbt on (mbt.code = ama.billing_type)
						where	ama.application_no = aas.application_no
					) ama
					outer apply
					(
						select	*
						from	dbo.asset_insurance_detail aid
						where	aid.asset_no = aas.asset_no
					) aid
							outer apply
					(
						select	top 1 asd.description
						from	dbo.application_asset_detail asd
						where	asd.asset_no = aas.asset_no
								and asd.type = 'karoseri'
								group by asd.description
					) asdkr 
			where	aas.APPLICATION_NO = @p_application_no ;

		open c_application_asset ;

		fetch c_application_asset
		into @asset_no
			 ,@unit_code				 
			 ,@merk					
			 ,@model					
			 ,@transmisi				
			 ,@warna_plat			
			 ,@tahun					
			 ,@tipe_karoseri			
			 ,@nilai_sisa			
			 ,@baru_atau_bekas		
			 --,@aksesoris				
			 ,@periode				
			 ,@tanggal_pengiriman	
			 ,@pemakaian_perbln		
			 ,@nilai_sewa_perbln		
			 ,@lokasi_pengiriman		
			 ,@nomor_surat			
			 ,@unit_amount			
			 ,@aksesoris_amount 		
			 ,@karoseri_amount		
			 ,@is_cop				
			 ,@rv_amount				
			 ,@nama_object			
			 ,@billing_type			
			 ,@payment_type	
			 ,@credit_term
			 ,@is_third_party
			 ,@is_passenger
			 ,@is_personal_passenger
			 ,@is_personal_driver
			 ,@is_pemogokan		
			 ,@is_terorisme	
			 ,@is_banjir	
			 ,@is_gempa		
			 ,@is_tbod
			 ,@is_nilai	;	

		WHILE @@fetch_status = 0
		BEGIN

			select	@replacement_amount = budget_amount
			from	dbo.application_asset_budget
			where	asset_no	  = @asset_no
					and cost_code = N'MBDC.2208.000001' ;

			select	@registration_amount = budget_amount
			from	dbo.application_asset_budget
			where	asset_no	  = @asset_no
					and cost_code = N'MBDC.2301.000001' ;

			select	@maintenance_amount = budget_amount
			from	dbo.application_asset_budget
			where	asset_no	  = @asset_no
					and cost_code = N'MBDC.2211.000003' ;

			select	@insurance_amount = budget_amount
			from	dbo.application_asset_budget
			where	asset_no	  = @asset_no
					and cost_code = N'MBDC.2211.000001' ;

			select top 1
					@insurance_tpl = mbl.coverage_amount--aid.tpl_premium_amount Raffy 19/12/2023 nilai yang diambil dari master, bukan yang diinput 
					,@insurance_pll	 = aid.pll_premium_amount
					,@insurance_paseat = aid.pa_passenger_seat
					,@insurance_pad = aid.pa_driver_amount--aid.pa_driver_premium_amount
					,@insurance_pap = aid.pa_passenger_amount--aid.pa_passenger_premium_amount
					,@insurance_srccts = aid.srcc_premium_amount + aid.ts_premium_amount
			from	dbo.asset_insurance_detail aid
					inner join dbo.application_asset aa on (aa.asset_no = aid.asset_no)
					inner join dbo.master_budget_insurance_rate_liability mbl on (mbl.code = aid.tpl_coverage_code)
			where	aa.application_no = @p_application_no ;

			insert into @rpt_quotation_temp
			(
				USER_ID
				,REPORT_COMPANY
				,REPORT_IMAGE
				,REPORT_TITLE
				,REPORT_ADDRESS
				,APPLICATION_NO
				,ASSET_NO
				,UNIT_CODE
				,CLIENT_NAME
				,ATTN_NAME
				,PHONE_NO_TO
				,EMAIL
				,SUBJECT
				,FROM_NAME
				,DATE
				,PHONE_NO_FROM
				,MOBILE_FROM
				,PRODUCT
				,VAT_PCT
				,WITHHOLDING_TAX
				,IS_STNK
				,IS_ASURANSI
				,IS_PENGANTI
				,IS_PERBAIKAN
				,IS_BANTUAN
				,IS_DARURAT
				,IS_LAIN_LAIN
				,IS_PEMELIHARAAN
				,IS_SUKU_CADANG
				,IS_OLI
				,IS_PASSENGER
				,IS_PERSONAL_PASSENGER
				,IS_PERSONAL_DRIVER
				,IS_PEMOGOKAN
				,IS_TERORISME
				,IS_BANJIR
				,IS_GEMPA
				,IS_NILAI
				,IS_THIRD_PARTY
				,IS_COP
				,IS_TBOD
				,TPL
				,PPL
				,PA_PASSENGER_AMOUNT
				,PA_PASSENGER_SEAT
				,PA_DRIVER_AMOUNT
				,PAY_OWN_RISK_AMOUNT
				,COUNT_LEASE_RENT
				,PAY_OWN_RISK_LESSOR_AMOUNT
				,PARTIAL_TOTAL_LOSS_PCT
				,PARTIAL_TOTAL_LOSS_AMOUNT
				,NAMA_USER
				,JABATAN_USER
				,TYPE_OF_UNIT
				,QUANTITY
				,YEAR
				,LEASE_PERIOD
				,MONTHLY_LEASED_RENT_AMOUNT
				,RV_AMOUNT
				,PREVIOUS_CONTRACT_NUMBER
				,CLAIM_AMOUNT_PCT
				,CLAIM_AMOUNT_TERBILANG
				,CLAIM_AMOUNT
				,CREDIT_TERM
				,BILLING_TYPE
				,PAYMENT_TYPE
				,REMARK
				,CRE_BY
				,CRE_DATE
				,CRE_IP_ADDRESS
				,MOD_BY
				,MOD_DATE
				,MOD_IP_ADDRESS
			)
			values
			(	
				@p_user_id
				,@report_company
				,@report_image
				,@report_title
				,@report_address
				,@p_application_no
				,@asset_no
				,@unit_code
				,@kepada
				,@kepada
				,@to_phone
				,@email_client
				,'Proposal OPL'
				,@nama_user
				,@tanggal
				,@company_telp
				,@telp_user
				,'Operating Lease'
				,@vat_pct
				,@withholding_pct
				,case when @registration_amount > 0 then 'V' else 'X' end
				,case when @insurance_amount > 0 then 'V' else 'X' end
				,case when @replacement_amount > 0 then 'V' else 'X' end
				,case when @maintenance_amount > 0 then 'V' else 'X' end
				,'V'--@is_bantuan
				,CASE when @is_darurat = 'V' THEN @is_darurat ELSE 'X' END 
				,'V'--@is_lain_lain
				,CASE when @is_pemeliharaan = 'V' THEN @is_pemeliharaan ELSE 'X' END
				,CASE WHEN @is_suku_cadang = 'V' THEN @is_suku_cadang ELSE 'X' end
				,CASE WHEN @is_oli = 'V' THEN @is_oli ELSE 'X' end
				,CASE WHEN @is_passenger = 'V' THEN @is_passenger ELSE 'X' end 
				,CASE WHEN @is_personal_passenger = 'V' THEN @is_personal_passenger ELSE 'X' END 
				,CASE WHEN @is_personal_driver = 'V' THEN @is_personal_driver ELSE 'X' end 
				,CASE WHEN @is_pemogokan = 'V' THEN @is_pemogokan ELSE 'X' end 
				,CASE WHEN @is_terorisme = 'V' THEN @is_terorisme ELSE 'X' end 
				,CASE WHEN @is_banjir = 'V' THEN @is_banjir ELSE 'X' end 
				,CASE WHEN @is_gempa = 'V' THEN @is_gempa ELSE 'X' end 
				,CASE WHEN @is_nilai = 'V' THEN @is_nilai ELSE 'X' end 
				,CASE WHEN @is_third_party = 'V' THEN @is_third_party ELSE 'X' end 
				,CASE WHEN @is_cop = 'V' THEN @is_cop ELSE 'X' end 
				,CASE WHEN @is_tbod = 'V' THEN @is_tbod ELSE 'X' end 
				,isnull(@insurance_tpl,'0')
				,isnull(@insurance_pll,'0')
				,isnull(@insurance_pap,'0')
				,@insurance_paseat
				,isnull(@insurance_pad,'0')
				,@pay_own_risk_amount
				,@count_lease_rent
				,@pay_own_risk_lessor_amount
				,@partial_total_loss_pct
				,@partial_total_loss_amount
				,@nama_head
				,@jabatan
				,isnull(@nama_object,'') + ' ' + isnull(@transmisi,'') -- TYPE_OF_UNIT - nvarchar(250)
				,1 -- QUANTITY - int
				,@tahun -- YEAR - nvarchar(4)
				,@periode -- LEASE_PERIOD - int
				,@nilai_sewa_perbln -- MONTHLY_LEASED_RENT_AMOUNT - decimal(18, 2)
				,case
					when @is_cop = 1 then @rv_amount
					else null
				end-- RV_AMOUNT - decimal(18, 2)
				,@branch_name+' area' -- PREVIOUS_CONTRACT_NUMBER - nvarchar(50)
				,@claim_pct
				,dbo.xfn_integer_to_words(@claim_pct)
				,@claim_amount
				,@credit_term
				,@billing_type
				,@payment_type
				,@subject
				,@p_cre_by -- CRE_BY - nvarchar(50)
				,@p_cre_date -- CRE_DATE - datetime
				,@p_cre_ip_address -- CRE_IP_ADDRESS - nvarchar(50)
				,@p_mod_by -- MOD_BY - nvarchar(50)
				,@p_mod_date -- MOD_DATE - datetime
				,@p_mod_ip_address -- MOD_IP_ADDRESS - nvarchar(50)
			) 

			fetch c_application_asset
			INTO @asset_no 
				 ,@unit_code
				 ,@merk					
				 ,@model					
				 ,@transmisi				
				 ,@warna_plat			
				 ,@tahun					
				 ,@tipe_karoseri			
				 ,@nilai_sisa			
				 ,@baru_atau_bekas		
				 --,@aksesoris				
				 ,@periode				
				 ,@tanggal_pengiriman	
				 ,@pemakaian_perbln		
				 ,@nilai_sewa_perbln		
				 ,@lokasi_pengiriman		
				 ,@nomor_surat			
				 ,@unit_amount			
				 ,@aksesoris_amount 		
				 ,@karoseri_amount		
				 ,@is_cop				
				 ,@rv_amount				
				 ,@nama_object			
				 ,@billing_type			
				 ,@payment_type	
				 ,@credit_term
				 ,@is_third_party
				 ,@is_passenger
				 ,@is_personal_passenger
				 ,@is_personal_driver
				 ,@is_pemogokan		
				 ,@is_terorisme	
				 ,@is_banjir	
				 ,@is_gempa		
				 ,@is_tbod
				 ,@is_nilai	;
		end ;

		close c_application_asset ;
		deallocate c_application_asset ;
		
		insert into dbo.RPT_QUOTATION_APPLICATION
		(
			USER_ID
			,REPORT_COMPANY
			,REPORT_IMAGE
			,REPORT_TITLE
			,REPORT_ADDRESS
			,APPLICATION_NO
			,CLIENT_NAME
			,ATTN_NAME
			,PHONE_NO_TO
			,EMAIL
			,SUBJECT
			,FROM_NAME
			,DATE
			,PHONE_NO_FROM
			,MOBILE_FROM
			,PRODUCT
			,VAT_PCT
			,WITHHOLDING_TAX
			,IS_STNK
			,IS_ASURANSI
			,IS_PENGANTI
			,IS_PERBAIKAN
			,IS_BANTUAN
			,IS_DARURAT
			,IS_LAIN_LAIN
			,IS_PEMELIHARAAN
			,IS_SUKU_CADANG
			,IS_OLI
			,IS_PASSENGER
			,IS_PERSONAL_PASSENGER
			,IS_PERSONAL_DRIVER
			,IS_PEMOGOKAN
			,IS_TERORISME
			,IS_BANJIR
			,IS_GEMPA
			,IS_NILAI
			,IS_THIRD_PARTY
			,IS_COP
			,TPL
			,PPL
			,PA_PASSENGER_AMOUNT
			,PA_PASSENGER_SEAT
			,PA_DRIVER_AMOUNT
			,PAY_OWN_RISK_AMOUNT
			,COUNT_LEASE_RENT
			,PAY_OWN_RISK_LESSOR_AMOUNT
			,PARTIAL_TOTAL_LOSS_PCT
			,PARTIAL_TOTAL_LOSS_AMOUNT
			,CLAIM_AMOUNT_PCT
			,CLAIM_AMOUNT_TERBILANG
			,CLAIM_AMOUNT
			,NAMA_USER
			,JABATAN_USER
			,UNIT_CODE
			--(-) raffyanda 10/10/2023 16.37.00.00 pengurangan asset no, agar tidak ada duplikat data
			--,ASSET_NO
			,TYPE_OF_UNIT
			,QUANTITY
			,YEAR
			,LEASE_PERIOD
			,MONTHLY_LEASED_RENT_AMOUNT
			,RV_AMOUNT
			,PREVIOUS_CONTRACT_NUMBER
			,COMPREHENSIVE
			,BILLING_TYPE
			,PAYMENT_TYPE
			,CREDIT_TERM
			,remark
			,CRE_BY
			,CRE_DATE
			,CRE_IP_ADDRESS
			,MOD_BY
			,MOD_DATE
			,MOD_IP_ADDRESS
		)
		select	DISTINCT 
				t.user_id
				,t.report_company
				,t.report_image
				,t.report_title
				,t.report_address
				,t.application_no
				,t.client_name
				,t.attn_name
				,t.phone_no_to
				,t.email
				,t.subject
				,t.from_name
				,t.date
				,t.phone_no_from
				,t.mobile_from
				,t.product
				,t.vat_pct
				,t.withholding_tax
				,IS_STNK
				,IS_ASURANSI
				,IS_PENGANTI
				,IS_PERBAIKAN
				,IS_BANTUAN
				,IS_DARURAT
				,IS_LAIN_LAIN
				,IS_PEMELIHARAAN
				,IS_SUKU_CADANG
				,IS_OLI
				,IS_PASSENGER
				,IS_PERSONAL_PASSENGER
				,IS_PERSONAL_DRIVER
				,IS_PEMOGOKAN
				,IS_TERORISME
				,IS_BANJIR
				,IS_GEMPA
				,IS_NILAI
				,IS_THIRD_PARTY
				,IS_COP
				,t.tpl
				,ppl
				,pa_passenger_amount
				,pa_passenger_seat
				,pa_driver_amount
				,t.pay_own_risk_amount
				,t.count_lease_rent
				,t.pay_own_risk_lessor_amount
				,t.partial_total_loss_pct
				,t.partial_total_loss_amount
				,t.claim_amount_pct
				,t.claim_amount_terbilang
				,t.claim_amount
				,t.nama_user
				,t.jabatan_user
				,t.unit_code
				--,t.asset_no
				--(+) raffyanda 10/10/2023 16.37.00.00 pengurangan asset no, agar tidak ada duplikat data
				,t.type_of_unit
				,jumlah.quantity
				,t.year
				,t.lease_period
				,t.monthly_leased_rent_amount
				,t.rv_amount
				,t.previous_contract_number
				,t3.COMPREHENSIVE
				,t.BILLING_TYPE
				,t.PAYMENT_TYPE
				,t.CREDIT_TERM
				,t.remark
				,t.CRE_BY
				,t.CRE_DATE
				,t.CRE_IP_ADDRESS
				,t.MOD_BY
				,t.MOD_DATE
				,t.MOD_IP_ADDRESS
		from	@rpt_quotation_temp t
		outer apply
				(
					select	sum(t2.quantity) 'quantity'
					from	@rpt_quotation_temp t2
					--(+) raffyanda 10/10/2023 16.37.00.00 penambahan kondisi where agar quantity dapat bertambah sesuai dengan monthly leased rent amount yang sama 
					where	t2.monthly_leased_rent_amount = t.monthly_leased_rent_amount
					and t2.unit_code = t.unit_code
					and t2.year = t.year
					--GROUP BY t2.UNIT_CODE
					--(+) raffyanda 10/10/2023 16.37.00.00 penambahan kondisi where agar quantity dapat bertambah sesuai dengan monthly leased rent amount yang sama 
				) jumlah 
		outer apply (
		select top 1 case
					when IS_THIRD_PARTY='V' then 'COMPREHENSIVE COVERAGE' + ', TPL '+ isnull(dbo.xfn_separator_tiga(tpl), 0) 
					else 'COMPREHENSIVE COVERAGE' + ', TPL 0,00'
				end
				+ 
				case
					when is_passenger='V' then ', PLL '+isnull(dbo.xfn_separator_tiga(ppl),0)
					else ', PPL 0,00'
				end
				+
				case
					when is_personal_passenger='V' then ', PA Passenger '+isnull(dbo.xfn_separator_tiga(pa_passenger_amount),0) + ' - ' + convert(nvarchar(50), isnull(pa_passenger_seat,0)) + ' seat'
					else ', PA Passenger '+'0,00'+ ' - ' + '0' + ' seat'
				end
				+
				case
					when is_personal_driver='V' then ', PA Driver '+isnull(dbo.xfn_separator_tiga(pa_driver_amount),0)
					else ', PA Driver '+'0,00'
				end
				+ case 
					when is_pemogokan='V' then ', SRCC'
					else ''
				end + 
				case
					when is_terorisme ='V' then ', TS'
					else ''
				end + 
				case
					when is_banjir ='V' then ', Flood & Windstorm'
					else ''
				end 	
				+case
					when is_gempa ='V' then ', Earthquake'
					else ''
				end
				+case
					when IS_TBOD ='V' then ', Theft by Own Driver'
					else ''
				end 'COMPREHENSIVE' FROM @rpt_quotation_temp t3 order by COMPREHENSIVE desc) t3
			 


             
		--insert into dbo.RPT_QUOTATION_APPLICATION
		--(
		--	USER_ID
		--	,REPORT_COMPANY
		--	,REPORT_IMAGE
		--	,REPORT_TITLE
		--	,REPORT_ADDRESS
		--	,APPLICATION_NO
		--	,CLIENT_NAME
		--	,ATTN_NAME
		--	,PHONE_NO_TO
		--	,EMAIL
		--	,SUBJECT
		--	,FROM_NAME
		--	,DATE
		--	,PHONE_NO_FROM
		--	,MOBILE_FROM
		--	,PRODUCT
		--	,VAT_PCT
		--	,WITHHOLDING_TAX
		--	,IS_STNK
		--	,IS_ASURANSI
		--	,IS_PENGANTI
		--	,IS_PERBAIKAN
		--	,IS_BANTUAN
		--	,IS_DARURAT
		--	,IS_LAIN_LAIN
		--	,IS_PEMELIHARAAN
		--	,IS_SUKU_CADANG
		--	,IS_OLI
		--	,IS_PASSENGER
		--	,IS_PERSONAL_PASSENGER
		--	,IS_PERSONAL_DRIVER
		--	,IS_PEMOGOKAN
		--	,IS_TERORISME
		--	,IS_BANJIR
		--	,IS_GEMPA
		--	,IS_NILAI
		--	,IS_THIRD_PARTY
		--	,IS_COP
		--	,TPL
		--	,PPL
		--	,PA_PASSENGER_AMOUNT
		--	,PA_PASSENGER_SEAT
		--	,PA_DRIVER_AMOUNT
		--	,PAY_OWN_RISK_AMOUNT
		--	,COUNT_LEASE_RENT
		--	,PAY_OWN_RISK_LESSOR_AMOUNT
		--	,PARTIAL_TOTAL_LOSS_PCT
		--	,PARTIAL_TOTAL_LOSS_AMOUNT
		--	,CLAIM_AMOUNT_PCT
		--	,CLAIM_AMOUNT_TERBILANG
		--	,CLAIM_AMOUNT
		--	,NAMA_USER
		--	,JABATAN_USER
		--	,UNIT_CODE
		--	--(-) raffyanda 10/10/2023 16.37.00.00 pengurangan asset no, agar tidak ada duplikat data
		--	--,ASSET_NO
		--	,TYPE_OF_UNIT
		--	,QUANTITY
		--	,YEAR
		--	,LEASE_PERIOD
		--	,MONTHLY_LEASED_RENT_AMOUNT
		--	,RV_AMOUNT
		--	,PREVIOUS_CONTRACT_NUMBER
		--	,COMPREHENSIVE
		--	,BILLING_TYPE
		--	,PAYMENT_TYPE
		--	,CREDIT_TERM
		--	,remark
		--	,CRE_BY
		--	,CRE_DATE
		--	,CRE_IP_ADDRESS
		--	,MOD_BY
		--	,MOD_DATE
		--	,MOD_IP_ADDRESS
		--)
		--select	DISTINCT 
		--		t.user_id
		--		,t.report_company
		--		,t.report_image
		--		,t.report_title
		--		,t.report_address
		--		,t.application_no
		--		,t.client_name
		--		,t.attn_name
		--		,t.phone_no_to
		--		,t.email
		--		,t.subject
		--		,t.from_name
		--		,t.date
		--		,t.phone_no_from
		--		,t.mobile_from
		--		,t.product
		--		,t.vat_pct
		--		,t.withholding_tax
		--		,isnull(is_stnk.is_stnk,'X')
		--		,isnull(is_asuransi.is_asuransi,'X')
		--		,isnull(is_penganti.is_penganti,'X')
		--		,isnull(is_perbaikan.is_perbaikan,'X')
		--		,isnull(is_bantuan.is_bantuan,'X')
		--		,isnull(is_darurat.is_darurat,'X')
		--		,isnull(is_lain_lain.is_lain_lain,'X')
		--		,isnull(is_pemeliharaan.is_pemeliharaan,'X')
		--		,isnull(is_suku_cadang.is_suku_cadang,'X')
		--		,isnull(is_oli.is_oli,'X')
		--		,isnull(is_passenger.is_passenger,'X')
		--		,isnull(is_personal_passenger.is_personal_passenger,'X')
		--		,isnull(is_personal_driver.is_personal_driver,'X')
		--		,isnull(is_pemogokan.is_pemogokan,'X')
		--		,isnull(is_terorisme.is_terorisme,'X')
		--		,isnull(is_banjir.is_banjir,'X')
		--		,isnull(is_gempa.is_gempa,'X')
		--		,isnull(is_nilai.is_nilai,'X')
		--		,isnull(is_third_party.is_third_party,'X')
		--		,isnull(is_cop.is_cop,0)
		--		,t.tpl
		--		,ppl.pll
		--		,pa_passenger_amount.pa_passenger_amount
		--		,pa_passenger_seat.pa_passenger_seat
		--		,pa_driver_amount.pa_driver_amount
		--		,t.pay_own_risk_amount
		--		,t.count_lease_rent
		--		,t.pay_own_risk_lessor_amount
		--		,t.partial_total_loss_pct
		--		,t.partial_total_loss_amount
		--		,t.claim_amount_pct
		--		,t.claim_amount_terbilang
		--		,t.claim_amount
		--		,t.nama_user
		--		,t.jabatan_user
		--		,t.unit_code
		--		--,t.asset_no
		--		--(+) raffyanda 10/10/2023 16.37.00.00 pengurangan asset no, agar tidak ada duplikat data
		--		,t.type_of_unit
		--		,jumlah.quantity
		--		,t.year
		--		,t.lease_period
		--		,t.monthly_leased_rent_amount
		--		,t.rv_amount
		--		,t.previous_contract_number
		--		,
		--		case
		--			when is_third_party.IS_THIRD_PARTY='V' then 'COMPREHENSIVE COVERAGE' + ', TPL '+ isnull(dbo.xfn_separator_tiga(tpl.tpl), 0) 
		--			else 'COMPREHENSIVE COVERAGE' + ', TPL 0,00'
		--		end
		--		+ 
		--		case
		--			when is_passenger.is_passenger='V' then ', PLL '+isnull(dbo.xfn_separator_tiga(ppl.pll),0)
		--			else ', PPL 0,00'
		--		end
		--		+
		--		case
		--			when is_personal_passenger.is_personal_passenger='V' then ', PA Passenger '+isnull(dbo.xfn_separator_tiga(pa_passenger_amount.pa_passenger_amount),0) + ' - ' + convert(nvarchar(50), isnull(pa_passenger_seat.pa_passenger_seat,0)) + ' seat'
		--			else ', PA Passenger '+'0,00'+ ' - ' + '0' + ' seat'
		--		end
		--		+
		--		case
		--			when is_personal_driver.is_personal_driver='V' then ', PA Driver '+isnull(dbo.xfn_separator_tiga(pa_driver_amount.pa_driver_amount),0)
		--			else ', PA Driver '+'0,00'
		--		end
		--		+ case 
		--			when is_pemogokan.is_pemogokan='V' then ', SRCC'
		--			else ''
		--		end + 
		--		case
		--			when is_terorisme.is_terorisme ='V' then ', TS'
		--			else ''
		--		end + 
		--		case
		--			when is_banjir.is_banjir ='V' then ', Flood & Windstorm'
		--			else ''
		--		end 	
		--		+case
		--			when is_gempa.is_gempa ='V' then ', Earthquake'
		--			else ''
		--		end
		--		,t.BILLING_TYPE
		--		,t.PAYMENT_TYPE
		--		,t.CREDIT_TERM
		--		,t.remark
		--		,t.CRE_BY
		--		,t.CRE_DATE
		--		,t.CRE_IP_ADDRESS
		--		,t.MOD_BY
		--		,t.MOD_DATE
		--		,t.MOD_IP_ADDRESS
		--from	@rpt_quotation_temp t
		--		outer apply
		--		(
		--			select	sum(t2.quantity) 'quantity'
		--			from	@rpt_quotation_temp t2
		--			--(+) raffyanda 10/10/2023 16.37.00.00 penambahan kondisi where agar quantity dapat bertambah sesuai dengan monthly leased rent amount yang sama 
		--			where	t2.monthly_leased_rent_amount = t.monthly_leased_rent_amount
		--			and t2.unit_code = t.unit_code
		--			and t2.year = t.year
		--			--GROUP BY t2.UNIT_CODE
		--			--(+) raffyanda 10/10/2023 16.37.00.00 penambahan kondisi where agar quantity dapat bertambah sesuai dengan monthly leased rent amount yang sama 
		--		) jumlah
		--		outer apply
		--		(
		--			select	top 1 is_stnk
		--			from	@rpt_quotation_temp
		--			where	is_stnk		= 'V'
		--					and user_id = @p_user_id 
		--		)is_stnk
		--		outer apply
		--		(
		--			select	top 1 is_asuransi
		--			from	@rpt_quotation_temp
		--			where	is_asuransi		= 'V'
		--					and user_id = @p_user_id 
		--		)is_asuransi
		--		outer apply
		--		(
		--			select	top 1 is_perbaikan
		--			from	@rpt_quotation_temp
		--			where	is_perbaikan		= 'V'
		--					and user_id = @p_user_id 
		--		)is_perbaikan
		--		outer apply
		--		(
		--			select	top 1 is_penganti
		--			from	@rpt_quotation_temp
		--			where	is_penganti		= 'V'
		--					and user_id = @p_user_id 
		--		)is_penganti
		--		outer apply
		--		(
		--			select	top 1 is_bantuan
		--			from	@rpt_quotation_temp
		--			where	is_bantuan		= 'V'
		--					and user_id = @p_user_id 
		--		)is_bantuan
		--		outer apply
		--		(
		--			select	top 1 is_darurat
		--			from	@rpt_quotation_temp
		--			where	is_darurat		= 'V'
		--					and user_id = @p_user_id 
		--		)is_darurat
		--		outer apply
		--		(
		--			select	top 1 is_lain_lain
		--			from	@rpt_quotation_temp
		--			where	is_lain_lain		= 'V'
		--					and user_id = @p_user_id 
		--		)is_lain_lain
		--		outer apply
		--		(
		--			select	top 1 is_pemeliharaan
		--			from	@rpt_quotation_temp
		--			where	is_pemeliharaan		= 'V'
		--					and user_id = @p_user_id 
		--		)is_pemeliharaan
		--		outer apply
		--		(
		--			select	top 1 is_suku_cadang
		--			from	@rpt_quotation_temp
		--			where	is_suku_cadang		= 'V'
		--					and user_id = @p_user_id 
		--		)is_suku_cadang
		--		outer apply
		--		(
		--			select	top 1 is_oli
		--			from	@rpt_quotation_temp
		--			where	is_oli		= 'V'
		--					and user_id = @p_user_id 
		--		)is_oli
		--		outer apply
		--		(
		--			select	top 1 is_passenger
		--			from	@rpt_quotation_temp
		--			where	is_passenger		= 'V'
		--					and user_id = @p_user_id 
		--		)is_passenger
		--		outer apply
		--		(
		--			select	top 1 is_personal_passenger
		--			from	@rpt_quotation_temp
		--			where	is_personal_passenger		= 'V'
		--					and user_id = @p_user_id 
		--		)is_personal_passenger
		--		outer apply
		--		(
		--			select	top 1 is_personal_driver
		--			from	@rpt_quotation_temp
		--			where	is_personal_driver		= 'V'
		--					and user_id = @p_user_id 
		--		)is_personal_driver
		--		outer apply
		--		(
		--			select	top 1 is_pemogokan
		--			from	@rpt_quotation_temp
		--			where	is_pemogokan		= 'V'
		--					and user_id = @p_user_id 
		--		)is_pemogokan
		--		outer apply
		--		(
		--			select	top 1 is_terorisme
		--			from	@rpt_quotation_temp
		--			where	is_terorisme		= 'V'
		--					and user_id = @p_user_id 
		--		)is_terorisme
		--		outer apply
		--		(
		--			select	top 1 is_banjir
		--			from	@rpt_quotation_temp
		--			where	is_banjir		= 'V'
		--					and user_id = @p_user_id 
		--		)is_banjir
		--		outer apply
		--		(
		--			select	top 1 is_gempa
		--			from	@rpt_quotation_temp
		--			where	is_gempa		= 'V'
		--					and user_id = @p_user_id 
		--		)is_gempa
		--		outer apply
		--		(
		--			select	top 1 is_nilai
		--			from	@rpt_quotation_temp
		--			where	is_nilai		= 'V'
		--					and user_id = @p_user_id 
		--		)is_nilai
		--		outer apply
		--		(
		--			select	top 1 is_third_party
		--			from	@rpt_quotation_temp
		--			where	is_third_party		= 'V'
		--					and user_id = @p_user_id 
		--		)is_third_party
		--		outer apply
		--		(
		--			select	top 1 is_cop
		--			from	@rpt_quotation_temp
		--			where	is_cop		= '1'
		--					and user_id = @p_user_id 
		--		)is_cop
		--		outer apply
		--		(
		--			select	tpl 'tpl' --sum(tpl)
		--			from	@rpt_quotation_temp
		--			where	user_id = @p_user_id 
		--		)tpl
		--		outer apply
		--		(
		--			select	ppl 'pll' --sum(ppl)
		--			from	@rpt_quotation_temp
		--			where	user_id = @p_user_id 
		--		)ppl
		--		outer apply
		--		(
		--			select	pa_passenger_amount 'pa_passenger_amount' --sum(pa_passenger_amount)
		--			from	@rpt_quotation_temp
		--			where	user_id = @p_user_id 
		--		)pa_passenger_amount
		--		outer apply
		--		(
		--			select	isnull(pa_passenger_seat,0) 'pa_passenger_seat'
		--			from	@rpt_quotation_temp
		--			where	user_id = @p_user_id 
		--		)pa_passenger_seat
		--		outer apply
		--		(
		--			select	pa_driver_amount 'pa_driver_amount' --sum(pa_driver_amount)
		--			from	@rpt_quotation_temp
		--			where	user_id = @p_user_id 
		--		)pa_driver_amount
		--		;
			--drop table @rpt_quotation_temp;
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;


