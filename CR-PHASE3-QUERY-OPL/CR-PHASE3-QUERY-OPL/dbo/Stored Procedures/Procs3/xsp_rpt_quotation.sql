--created by, Bilal at 28/06/2023 

CREATE PROCEDURE [dbo].[xsp_rpt_quotation]
(
	@p_user_id		   nvarchar(max)
	,@p_application_no nvarchar(50)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	delete dbo.rpt_quotation
	where	user_id = @p_user_id ;

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

	begin try

		create table #rpt_quotation_temp
		(
			user_id							nvarchar(50)	COLLATE Latin1_General_CI_AS
			,application_no					nvarchar(50)	COLLATE Latin1_General_CI_AS
			,report_company					nvarchar(250)	COLLATE Latin1_General_CI_AS
			,report_title					nvarchar(250)	COLLATE Latin1_General_CI_AS
			,report_image					nvarchar(250)	COLLATE Latin1_General_CI_AS
			,tanggal						datetime		
			,surat_no						nvarchar(50)	COLLATE Latin1_General_CI_AS
			,kepada							nvarchar(250)	COLLATE Latin1_General_CI_AS
			,unit_code						nvarchar(50)	COLLATE Latin1_General_CI_AS
			,merk							nvarchar(50)	COLLATE Latin1_General_CI_AS
			,model							nvarchar(50)	COLLATE Latin1_General_CI_AS
			,jenis_bahan_bakar				nvarchar(50)	COLLATE Latin1_General_CI_AS
			,transmisi						nvarchar(250)	COLLATE Latin1_General_CI_AS
			,warna_plat						nvarchar(50)	COLLATE Latin1_General_CI_AS
			,tahun							nvarchar(4)		COLLATE Latin1_General_CI_AS
			,silinder						int				
			,kode_mesin						nvarchar(50)	COLLATE Latin1_General_CI_AS
			,kapasitas						int				
			,muatan							int				
			,tipe_karoseri					nvarchar(50)	COLLATE Latin1_General_CI_AS
			,nilai_sisa						decimal(18,2)	
			,baru_atau_bekas				nvarchar(50)	COLLATE Latin1_General_CI_AS
			,aksesoris						nvarchar(250)	COLLATE Latin1_General_CI_AS
			,periode						int				
			,tanggal_pengiriman				datetime		
			,pemakaian_perbln				int				
			,nilai_sewa_perbln				decimal(18,2)	
			,uang_jaminan					decimal(18,2)	
			,tenggang_waktu					int				
			,lokasi_pengiriman				nvarchar(250)	COLLATE Latin1_General_CI_AS
			,company_address				nvarchar(4000)	COLLATE Latin1_General_CI_AS
			,company_telp					nvarchar(50)	COLLATE Latin1_General_CI_AS
			,company_fax					nvarchar(50)	COLLATE Latin1_General_CI_AS
			,is_kontrak_sewa_termaksuk		nvarchar(1)		COLLATE Latin1_General_CI_AS
			,is_kontrak_sewa_tdk_termaksuk	nvarchar(1)		COLLATE Latin1_General_CI_AS
			,is_harga						nvarchar(1)		COLLATE Latin1_General_CI_AS
			,is_aksesoris					nvarchar(1)		COLLATE Latin1_General_CI_AS
			,is_stnk						nvarchar(1)		COLLATE Latin1_General_CI_AS
			,is_asuransi					nvarchar(1)		COLLATE Latin1_General_CI_AS
			,is_penganti					nvarchar(1)		COLLATE Latin1_General_CI_AS
			,is_perbaikan					nvarchar(1)		COLLATE Latin1_General_CI_AS
			,is_bantuan						nvarchar(1)		COLLATE Latin1_General_CI_AS
			,is_darurat						nvarchar(1)		COLLATE Latin1_General_CI_AS
			,is_lain_lain					nvarchar(1)		COLLATE Latin1_General_CI_AS
			,is_pemeliharaan				nvarchar(1)		COLLATE Latin1_General_CI_AS
			,is_suku_cadang					nvarchar(1)		COLLATE Latin1_General_CI_AS
			,is_oli							nvarchar(1)		COLLATE Latin1_General_CI_AS
			,is_aki							nvarchar(1)		COLLATE Latin1_General_CI_AS
			,is_ban							nvarchar(1)		COLLATE Latin1_General_CI_AS
			,is_konsumen					nvarchar(1)		COLLATE Latin1_General_CI_AS
			,is_komprehensif_termaksuk		nvarchar(1)		COLLATE Latin1_General_CI_AS
			,is_komprehensif_tdk_termasuk	nvarchar(1)		COLLATE Latin1_General_CI_AS
			,is_third_party					nvarchar(1)		COLLATE Latin1_General_CI_AS
			,is_passenger					nvarchar(1)		COLLATE Latin1_General_CI_AS
			,is_personal_passenger			nvarchar(1)		COLLATE Latin1_General_CI_AS
			,is_personal_driver				nvarchar(1)		COLLATE Latin1_General_CI_AS
			,is_pemogokan					nvarchar(1)		COLLATE Latin1_General_CI_AS
			,is_terorisme					nvarchar(1)		COLLATE Latin1_General_CI_AS
			,is_banjir						nvarchar(1)		COLLATE Latin1_General_CI_AS
			,is_gempa						nvarchar(1)		COLLATE Latin1_General_CI_AS
			,is_nilai						nvarchar(1)		COLLATE Latin1_General_CI_AS
			,is_cop							nvarchar(1)		COLLATE Latin1_General_CI_AS
			,keterangan						nvarchar(250)	COLLATE Latin1_General_CI_AS
			--												
			,cre_date						datetime		
			,cre_by							nvarchar(15)	COLLATE Latin1_General_CI_AS
			,cre_ip_address					nvarchar(15)	COLLATE Latin1_General_CI_AS
			,mod_date						datetime
			,mod_by							nvarchar(15)	COLLATE Latin1_General_CI_AS
			,mod_ip_address					nvarchar(15)	COLLATE Latin1_General_CI_AS
		) ;

		select	@branch_code		= branch_code
				,@tanggal			= convert(nvarchar(50), application_date,106)
				,@tenggang_waktu	= credit_term
				,@kepada			= client_name
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

		--select	@company_address = value
		--from	dbo.sys_global_param
		--where	code = 'INVADD' ;

		--select	@company_telp_area = value
		--from	dbo.sys_global_param
		--where	code = 'TELPAREA' ;

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
		from	ifinsys.dbo.sys_branch
		where	code = @ho_branch_code ;

		set @company_telp = @company_telp_area + ' ' + @company_telp_area1

		set @company_fax = @company_fax_area + ' ' + @company_fax_phone

		set @report_title = 'Report Quotation' ;

		declare c_application_asset cursor for
		select	asset_no
		from	dbo.application_asset
		where	application_no = @p_application_no ;

		open c_application_asset ;

		fetch c_application_asset
		into @asset_no ;

		while @@fetch_status = 0
		begin
		
			select	@unit_code				= asv.vehicle_unit_code
					,@merk					= mvm.description
					,@model					= mvmo.description
					,@transmisi				= asv.transmisi
					,@warna_plat			= aas.plat_colour
					,@tahun					= aas.asset_year
					,@tipe_karoseri			= asdkr.description
					,@nilai_sisa			= aas.asset_rv_amount
					,@baru_atau_bekas		= aas.asset_condition
					,@aksesoris				= asdac.description
					,@periode				= aas.periode
					,@tanggal_pengiriman	= aas.request_delivery_date
					,@pemakaian_perbln		= aas.monthly_miles
					,@nilai_sewa_perbln		= aas.lease_rounded_amount
					,@lokasi_pengiriman		= aas.deliver_to_address
					,@nomor_surat			= aas.surat_no
					,@unit_amount			= aas.market_value
					,@aksesoris_amount 		= aas.accessories_amount
					,@karoseri_amount		= aas.karoseri_amount
					,@is_cop				= ama.is_purchase_requirement_after_lease
			from	dbo.application_asset aas 
					left join dbo.application_asset_vehicle asv on (asv.asset_no = aas.asset_no)
					left join dbo.application_main ama on (ama.application_no = aas.application_no)
					left join dbo.master_vehicle_merk mvm on (mvm.code = asv.vehicle_merk_code)
					left join dbo.master_vehicle_model mvmo on (mvmo.code = asv.vehicle_model_code)
					outer apply
					(
						select	asd.description
						from	dbo.application_asset_detail asd
						where	asd.asset_no = aas.asset_no
								and asd.type = 'KAROSERI'
					) asdkr
					outer apply
					(
						select	asd.description
						from	dbo.application_asset_detail asd
						where	asd.asset_no = aas.asset_no
								and asd.type = 'ACCESSORIES'
					) asdac
			where	aas.asset_no = @asset_no ;
			
			select	@is_third_party = case
										  when is_use_tpl = 1 then 'V'
										  else 'X'
									  end
					,@is_passenger = case
										 when is_use_pa_passenger = 1 then 'V'
										 else 'X'
									 end
					,@is_personal_passenger = case
												  when is_use_pa_passenger = 1 then 'V'
												  else 'X'
											  end
					,@is_personal_driver = case
											   when is_use_pa_driver = 1 then 'V'
											   else 'X'
										   end
					,@is_pemogokan = case
										 when is_use_srcc = 1 then 'V'
										 else 'X'
									 end
					,@is_terorisme = case
										 when is_use_ts = 1 then 'V'
										 else 'X'
									 end
					,@is_banjir = case
									  when is_use_flood = 1 then 'V'
									  else 'X'
								  end
					,@is_gempa = case
									 when is_use_earthquake = 1 then 'V'
									 else 'X'
								 end
					,@is_nilai = case
									 when main_coverage_code = 'TLO' then 'V'
									 else 'X'
								 end
			from	dbo.asset_insurance_detail
			where	asset_no = @asset_no ;

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
					
			--select	@maintenence_code = code
			--		,@inflation	  = inflation
			--from	master_budget_maintenance
			--where	unit_code	 = @p_unit_code
			--		and year	 = @p_year
			--		and location = @p_location
			--		and exp_date >= dbo.xfn_get_system_date() ;

			--select	grup.probability_pct
			--		,svc.unit_qty
			--		,svc.unit_cost
			--		,svc.labor_cost
			--		,svc.replacement_type
			--		,svc.replacement_cycle
			--from	dbo.master_budget_maintenance_group_service svc
			--		inner join dbo.master_budget_maintenance_group grup on (grup.code = svc.budget_maintenance_group_code)
			--where	svc.budget_maintenance_code = @maintenence_code
			--		and (
			--				svc.unit_qty		> 0
			--				or	svc.unit_cost	> 0
			--				or	svc.labor_cost	> 0
			--			)
			--		and svc.replacement_cycle	> 0 ;

			insert into #rpt_quotation_temp
			(
				user_id
				,application_no
				,report_company
				,report_title
				,report_image
				,tanggal
				,surat_no
				,kepada
				,unit_code
				,merk
				,model
				,jenis_bahan_bakar
				,transmisi
				,warna_plat
				,tahun
				,silinder
				,kode_mesin
				,kapasitas
				,muatan
				,tipe_karoseri
				,nilai_sisa
				,baru_atau_bekas
				,aksesoris
				,periode
				,tanggal_pengiriman
				,pemakaian_perbln
				,nilai_sewa_perbln
				,uang_jaminan
				,tenggang_waktu
				,lokasi_pengiriman
				,company_address
				,company_telp
				,company_fax
				,is_kontrak_sewa_termaksuk
				,is_kontrak_sewa_tdk_termaksuk
				,is_harga
				,is_aksesoris
				,is_stnk
				,is_asuransi
				,is_penganti
				,is_perbaikan
				,is_bantuan
				,is_darurat
				,is_lain_lain
				,is_pemeliharaan
				,is_suku_cadang
				,is_oli
				,is_aki
				,is_ban
				,is_konsumen
				,is_komprehensif_termaksuk
				,is_komprehensif_tdk_termasuk
				,is_third_party
				,is_passenger
				,is_personal_passenger
				,is_personal_driver
				,is_pemogokan
				,is_terorisme
				,is_banjir
				,is_gempa
				,is_nilai
				,is_cop
				,keterangan
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			values
			(	
				@p_user_id
				,@p_application_no
				,@report_company
				,@report_title
				,@report_image
				,@tanggal
				,@nomor_surat
				,@kepada
				,@unit_code
				,@merk
				,@model
				,@jenis_bahan_bakar
				,@transmisi
				,@warna_plat
				,@tahun
				,@silinder
				,@kode_mesin
				,@kapasitas
				,@muatan
				,@tipe_karoseri
				,@nilai_sisa
				,@baru_atau_bekas
				,@aksesoris
				,@periode
				,@tanggal_pengiriman
				,@pemakaian_perbln
				,@nilai_sewa_perbln
				,@uang_jaminan
				,@tenggang_waktu
				,@lokasi_pengiriman
				,@company_address
				,@company_telp
				,@company_fax
				,@is_kontrak_sewa_termaksuk
				,@is_kontrak_sewa_tdk_termaksuk
				,case when @unit_amount > 0 then 'V'else 'X' end
				,case when @aksesoris_amount + @karoseri_amount > 0 then 'V' else 'X' end
				,case when @registration_amount > 0 then 'V' else 'X' end
				,case when @insurance_amount > 0 then 'V' else 'X' end
				,case when @replacement_amount > 0 then 'V' else 'X' end
				,case when @maintenance_amount > 0 then 'V' else 'X' end
				,@is_bantuan
				,@is_darurat
				,@is_lain_lain
				,@is_pemeliharaan
				,@is_suku_cadang
				,@is_oli
				,@is_aki
				,@is_ban
				,@is_konsumen
				,@is_komprehensif_termaksuk
				,@is_komprehensif_tdk_termasuk
				,@is_third_party		
				,@is_passenger			
				,@is_personal_passenger	
				,@is_personal_driver	
				,@is_pemogokan			
				,@is_terorisme			
				,@is_banjir				
				,@is_gempa				
				,@is_nilai	
				,@is_cop
				,@keterangan
				--
				,@p_cre_date	  
				,@p_cre_by		  
				,@p_cre_ip_address
				,@p_mod_date	  
				,@p_mod_by		  
				,@p_mod_ip_address
			) 

			fetch c_application_asset
			into @asset_no ;
		end ;

		close c_application_asset ;
		deallocate c_application_asset ;
		
		insert into dbo.RPT_QUOTATION
		(
			USER_ID
			,APPLICATION_NO
			,REPORT_COMPANY
			,REPORT_TITLE
			,REPORT_IMAGE
			,REPORT_ADDRESS
			,TANGGAL
			,SURAT_NO
			,KEPADA
			,MERK
			,MODEL
			,JENIS_BAHAN_BAKAR
			,TRANSMISI
			,WARNA_PLAT
			,TAHUN
			,SILINDER
			,KODE_MESIN
			,KAPASITAS
			,MUATAN
			,TIPE_KAROSERI
			,NILAI_SISA
			,BARU_ATAU_BEKAS
			,AKSESORIS
			,PERIODE
			,TANGGAL_PENGIRIMAN
			,PEMAKAIAN_PERBLN
			,NILAI_SEWA_PERBLN
			,UANG_JAMINAN
			,TENGGANG_WAKTU
			,LOKASI_PENGIRIMAN
			,COMPANY_ADDRESS
			,COMPANY_TELP
			,COMPANY_FAX
			,IS_KONTRAK_SEWA_TERMAKSUK
			,IS_KONTRAK_SEWA_TDK_TERMAKSUK
			,IS_HARGA
			,IS_AKSESORIS
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
			,IS_AKI
			,IS_BAN
			,IS_KONSUMEN
			,IS_KOMPREHENSIF_TERMAKSUK
			,IS_KOMPREHENSIF_TDK_TERMASUK
			,IS_THIRD_PARTY
			,IS_PASSENGER
			,IS_PERSONAL_PASSENGER
			,IS_PERSONAL_DRIVER
			,IS_PEMOGOKAN
			,IS_TERORISME
			,IS_BANJIR
			,IS_GEMPA
			,IS_NILAI
			,IS_COP
			,KETERANGAN
			,CRE_DATE
			,CRE_BY
			,CRE_IP_ADDRESS
			,MOD_DATE
			,MOD_BY
			,MOD_IP_ADDRESS
		)
		select	t.user_id
			   ,t.application_no
			   ,t.report_company
			   ,t.report_title
			   ,t.report_image
			   ,@report_address
			   ,t.tanggal
			   ,t.surat_no
			   ,t.kepada
			   ,t.merk
			   ,t.model
			   ,t.jenis_bahan_bakar
			   ,t.transmisi
			   ,t.warna_plat
			   ,t.tahun
			   ,t.silinder
			   ,t.kode_mesin
			   ,t.kapasitas
			   ,t.muatan
			   ,t.tipe_karoseri
			   ,t.nilai_sisa
			   ,t.baru_atau_bekas
			   ,t.aksesoris
			   ,t.periode
			   ,t.tanggal_pengiriman
			   ,t.pemakaian_perbln
			   ,t.nilai_sewa_perbln
			   ,t.uang_jaminan
			   ,t.tenggang_waktu
			   ,t.lokasi_pengiriman
			   ,t.company_address
			   ,t.company_telp
			   ,t.company_fax
			   ,t.is_kontrak_sewa_termaksuk
			   ,t.is_kontrak_sewa_tdk_termaksuk
			   ,t.is_harga
			   ,t.is_aksesoris
			   ,t.is_stnk
			   ,t.is_asuransi
			   ,t.is_penganti
			   ,t.is_perbaikan
			   ,t.is_bantuan
			   ,t.is_darurat
			   ,t.is_lain_lain
			   ,t.is_pemeliharaan
			   ,t.is_suku_cadang
			   ,t.is_oli
			   ,t.is_aki
			   ,t.is_ban
			   ,t.is_konsumen
			   ,t.is_komprehensif_termaksuk
			   ,t.is_komprehensif_tdk_termasuk
			   ,t.is_third_party
			   ,t.is_passenger
			   ,t.is_personal_passenger
			   ,t.is_personal_driver
			   ,t.is_pemogokan
			   ,t.is_terorisme
			   ,t.is_banjir
			   ,t.is_gempa
			   ,t.is_nilai
			   ,t.is_cop
			   ,t.keterangan
			   ,t.cre_date
			   ,t.cre_by
			   ,t.cre_ip_address
			   ,t.mod_date
			   ,t.mod_by
			   ,t.mod_ip_address
		from
				(
					select	*
							,row_number() over (partition by unit_code
												order by application_no asc
											   ) as row_number
					from	#rpt_quotation_temp
				) t where t.row_number=1;

		drop table #rpt_quotation_temp;
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


