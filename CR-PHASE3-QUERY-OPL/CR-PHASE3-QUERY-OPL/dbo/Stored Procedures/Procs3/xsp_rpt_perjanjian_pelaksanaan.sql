--created by, Bilal at 14/07/2023 

CREATE PROCEDURE dbo.xsp_rpt_perjanjian_pelaksanaan
(
	@p_user_id		   NVARCHAR(MAX)
	,@p_application_no NVARCHAR(50)
	,@p_code		   NVARCHAR(50)
	--
	,@p_mod_date	   DATETIME
	,@p_mod_by		   NVARCHAR(15)
	,@p_mod_ip_address NVARCHAR(15)
)
AS
BEGIN
	delete dbo.RPT_PERJANJIAN_PELAKSANAAN
	where	user_id = @p_user_id ;

	--(+)Untuk Data Looping
	delete dbo.rpt_perjanjian_pelaksanaan_lampiran_i
	where	user_id = @p_user_id ;

	delete dbo.rpt_perjanjian_pelaksanaan_lampiran_iii
	where	user_id = @p_user_id ;

	declare @msg								nvarchar(max)
			,@report_company					nvarchar(250)
			,@report_image						nvarchar(250)
			,@report_title						nvarchar(250)
			,@agreement_external_no				nvarchar(50)
			,@agreement_date					datetime
			,@client_name						nvarchar(250)
			,@main_contract_no					nvarchar(50)
			,@application_date					datetime
			,@lokasi_penyerahan					nvarchar(4000)
			,@lokasi_pengambilan				nvarchar(4000)
			,@jangka_waktu						int
			,@from_jangka_waktu					datetime
			,@end_jangka_waktu					datetime
			,@jenis_kendaraan					nvarchar(250)
			,@jumlah							int
			,@tahun								nvarchar(4)
			,@harga_sewa_keseluruhan			decimal(18, 2)
			,@harga_sewa_perbulan				decimal(18, 2)
			,@tanggal_bayar						nvarchar(4000)
			,@tanggal_sewa_satu					nvarchar(4000)
			,@star_sewa_berikutnya				datetime
			,@end_sewa_berikutnya				datetime
			,@metode_pembayaran					nvarchar(50)
			,@persen_denda						decimal(9, 6)
			,@jarak_tempu						int
			,@biaya_kilometer					decimal(18, 2)
			,@golive_date						datetime
			,@employee_lessor					nvarchar(50)
			,@jabatan_lessor					nvarchar(50)
			,@pic_lessee						nvarchar(50)
			,@hari								nvarchar(50)
			,@day								nvarchar(50)
			,@month								nvarchar(50)
			,@year								nvarchar(250)
			,@tanggal							datetime
			,@no_induk							nvarchar(50)
			,@no_pelaksanaan					nvarchar(50)
			,@no_agreement						nvarchar(50)
			,@tanggal_perjanjian				DATETIME
			,@nama_lessee						NVARCHAR(250)
			,@nama_barang						NVARCHAR(250)
			,@no_rangka							NVARCHAR(50)
			,@no_mesin							NVARCHAR(50)
			,@spesifikasi						NVARCHAR(250)
			,@aksesoris							NVARCHAR(250)
			,@application_external_no			NVARCHAR(50)
			,@client_address					NVARCHAR(4000)
			,@main_contract_date				DATETIME
			,@min_due_date						DATETIME
			,@max_due_date						DATETIME
			,@min_due_day						INT
			,@periode							INT
			,@monthly_miles						INT
			,@deliver_to_address				NVARCHAR(4000)
			,@pickup_address					NVARCHAR(4000)
			,@asset_name						NVARCHAR(250)
			,@asset_year						NVARCHAR(4)
			,@credit_term						NVARCHAR(50)
			,@credit_term_2						INT
			,@billing_type						INT
			,@charges_pct						DECIMAL(9, 6)
			,@insurance_tpl						DECIMAL(18, 2)
			,@insurance_pad						DECIMAL(18, 2)
			,@insurance_pap						DECIMAL(18, 2)
			,@insurance_srccts					DECIMAL(18, 2)
			,@et_pct							DECIMAL(9, 6)
			,@report_company_address			NVARCHAR(4000)
			,@multi_asset_count					INT
			,@tanggal_pembayaran_awal_dan_akhir NVARCHAR(250)
			,@ppn_pct							DECIMAL(9, 6)
			,@asset_no							NVARCHAR(50)
			,@count_karoseri					INT	 
			,@count_aksesoris					INT	
			,@karoseri							NVARCHAR(250)
			,@jumlah_barang						INT
			,@bast_date							DATETIME
			,@pct_unit							DECIMAL(9,6)
			,@agreement_no						NVARCHAR(50)
			,@jabatan_signer					NVARCHAR(50)
			,@code_jabatan_signer				NVARCHAR(50)
			,@branch_code						NVARCHAR(50)
			,@agreement_sign_date				NVARCHAR(50)
			,@client_company_name				nvarchar(50)
			,@agreement_date_realization		datetime
			,@tanggal_awal_bayar				datetime
            ,@no_polisi							nvarchar(10)
			,@sewa_per_bulan					decimal(18,2)
			,@jangka_waktu_from					datetime
			,@jangka_waktu_to					datetime
			,@jadwal_Pembayaran_to				datetime
			,@jadwal_pembayaran_from			datetime
            ,@lokasi							nvarchar(4000)
			,@is_srcc							nvarchar(1)
			,@is_ts								nvarchar(1)
			,@is_flood_windstorm				nvarchar(1)
			,@is_earthquake						nvarchar(1)
			 
	begin try
		begin
			exec dbo.xsp_create_agreement_no @p_code = @p_code
											 ,@p_mod_date = @p_mod_date
											 ,@p_mod_by = @p_mod_by
											 ,@p_mod_ip_address = @p_mod_ip_address ;
		end ;

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		select	@report_company_address = value
		from	dbo.sys_global_param
		where	code = 'INVADD' ;

		set @report_title = 'PERJANJIAN PELAKSANAAN' ;

		select	@ppn_pct = value
		from	dbo.sys_global_param
		where	code = ('RTAXPPN') ;

		select distinct
				@multi_asset_count = count(asset_name)
		from	dbo.application_asset
		where	realization_code = @p_code ;

		select	@application_external_no = application_external_no
				,@application_date = application_date
				,@client_name = client_name
				,@periode = periode
				--,@client_address = client_address
				,@credit_term_2 = am.credit_term
				,@billing_type = mbt.multiplier
				,@branch_code = am.branch_code
		from	dbo.application_main am
				inner join dbo.master_billing_type mbt on (mbt.code = am.billing_type)
		where	application_no = @p_application_no ;

		select	@main_contract_no = main_contract_no
				,@main_contract_date = main_contract_date
		from	dbo.application_extention
		where	application_no = @p_application_no ;
		
		select	@count_karoseri = count(1)
		from	dbo.application_asset_detail aad
				inner join dbo.application_asset aa on (aa.asset_no = aad.asset_no)
		where	aa.realization_code = @p_code
				and aad.type		= 'KAROSERI' ;

		select	@count_aksesoris = count(1)
		from	dbo.application_asset_detail aad
				inner join dbo.application_asset aa on (aa.asset_no = aad.asset_no)
		where	aa.realization_code = @p_code
				and aad.type		= 'ACCESSORIES' ;

		select	@karoseri = aad.description
		from	dbo.application_asset_detail aad
				inner join dbo.application_asset aa on (aa.asset_no = aad.asset_no)
		where	aa.realization_code = @p_code
				and aad.type		= 'KAROSERI' ;

		select	@aksesoris = aad.description
		from	dbo.application_asset_detail aad
				inner join dbo.application_asset aa on (aa.asset_no = aad.asset_no)
		where	aa.realization_code = @p_code
				and aad.type		= 'ACCESSORIES' ;

		select	@harga_sewa_keseluruhan = sum(aam.billing_amount)
		from	application_amortization aam
				inner join dbo.application_asset aa on (aa.asset_no = aam.asset_no)
		where	aa.realization_code = @p_code ;

		select	@jumlah = count(1)
		from	dbo.realization_detail
		where	realization_code = @p_code ;

		select	@no_agreement = agreement_external_no
		from	dbo.realization
		where	code = @p_code ;

		select	@report_company = value
		from	sys_global_param
		where	code = 'COMP2' ;

		select	@star_sewa_berikutnya = due_date
		from	dbo.application_amortization
		where	installment_no	   = 2
				and application_no = @p_application_no ;

		--select	@harga_sewa_keseluruhan = sum(aam.billing_amount)
		--		,@min_due_date = min(aam.due_date)
		--		,@max_due_date = max(aam.due_date)
		--		,@min_due_day = day(min(aam.due_date))
		--from	application_amortization aam
		--		inner join dbo.application_asset aa on (aa.asset_no = aam.asset_no)
		--where	aa.realization_code = @p_code ;

		select	@harga_sewa_keseluruhan = sum(aam.billing_amount)
				--,@min_due_date = min(period.period_date)
				--,@max_due_date = max(period.period_due_date)
				,@min_due_day = day(min(aam.due_date))
		from	application_amortization aam
				inner join dbo.application_asset aa on (aa.asset_no = aam.asset_no)
		--		outer apply
		--(
		--	select	*
		--	from	dbo.xfn_due_date_period_application(aa.ASSET_NO, aam.INSTALLMENT_NO)
		--) period
		where	aa.realization_code = @p_code ;

		select	@bast_date = aa.bast_date
		from	application_amortization aam
				inner join dbo.application_asset aa on (aa.asset_no = aam.asset_no)
		where	aa.realization_code = @p_code ;

		select	@harga_sewa_perbulan = sum(lease_rounded_amount)
				,@monthly_miles = max(monthly_miles)
		from	dbo.application_asset
		where	realization_code = @p_code ;

		select top 1
				@deliver_to_address = deliver_to_address
				,@pickup_address = pickup_address
				,@asset_name = asset_name
				,@asset_year = asset_year
				,@no_rangka = fa_reff_no_02 
				,@no_mesin = fa_reff_no_03
				--,@agreement_no = agreement_no
		from	dbo.application_asset
		where	realization_code = @p_code ;

		select	@agreement_no = agreement_no
				,@agreement_date_realization = agreement_date
		from	dbo.realization
		where	code = @p_code ;

		--select		top 1
		--			@tanggal_awal_bayar = handover_bast_date
		--from		agreement_asset
		--where		handover_bast_date is not null
		--			and agreement_no = @agreement_no
		--order by	handover_bast_date asc ;

		--select	@spesifikasi = stuff((
		--								 select ', ' + isnull(replace(asd.description, '&', ' dan '), '')
		--								 from	dbo.application_asset aps
		--										inner join dbo.application_asset_detail asd on (asd.asset_no = aps.asset_no)
		--								 where	aps.application_no = @p_application_no
		--								 for xml path('')
		--							 ), 1, 1, ''
		--							) ;

		--select	@charges_pct = charges_rate
		--from	dbo.application_charges
		--where	application_no	 = @p_application_no
		--		and charges_code = 'OVDP' ;

		--select	@et_pct = charges_rate
		--from	dbo.application_charges
		--where	application_no	 = @p_application_no
		--		and charges_code = 'CETP' ;
				
		--select	@pct_unit = charges_rate
		--from	dbo.application_charges
		--where	application_no	 = @p_application_no
		--		and charges_code = 'CRTA' ;

		-- Louis Kamis, 29 Agustus 2024 17.27.00 -- ambil charges dari main contract charges
		select	@charges_pct = mcc.new_charges_rate
		from	dbo.main_contract_charges mcc
				inner join dbo.application_extention ae on (ae.main_contract_no = mcc.main_contract_no)
		where	application_no	 = @p_application_no
				and charges_code = 'OVDP' ;

		select	@et_pct = mcc.new_charges_rate
		from	dbo.main_contract_charges mcc
				inner join dbo.application_extention ae on (ae.main_contract_no = mcc.main_contract_no)
		where	application_no	 = @p_application_no
				and charges_code = 'CETP' ;

		select	@pct_unit = mcc.new_charges_rate
		from	dbo.main_contract_charges mcc
				inner join dbo.application_extention ae on (ae.main_contract_no = mcc.main_contract_no)
		where	application_no	 = @p_application_no
				and charges_code = 'LRAP' ; 

		select	@golive_date = golive_date
		from	dbo.application_main
		where	application_no = @p_application_no ;

		select	 top 1 @credit_term =inv.invoice_due_date
		from	invoice inv
		inner join invoice_detail ind on ind.invoice_no = inv.invoice_no
		where	ind.agreement_no = @agreement_no;
		select @agreement_no

		select	@agreement_sign_date = agreement_sign_date
				,@agreement_date = agreement_date
		from	agreement_main
		where	agreement_no = @agreement_no;

		select	@min_due_date = min(period.period_date)
				,@max_due_date = max(period.period_due_date)
		from	dbo.AGREEMENT_ASSET asat
				inner join dbo.agreement_asset_amortization aaa on aaa.ASSET_NO = asat.ASSET_NO
																   and aaa.AGREEMENT_NO = asat.AGREEMENT_NO
				outer apply
				(
					select	*
					from	dbo.xfn_due_date_period(asat.ASSET_NO, aaa.BILLING_NO)
				) period
		where	aaa.AGREEMENT_NO = @agreement_no ;

		select	@tanggal_awal_bayar = min(period.period_due_date)
		from	dbo.agreement_asset asat
				inner join dbo.agreement_asset_amortization aaa on aaa.ASSET_NO = asat.ASSET_NO
																   and aaa.AGREEMENT_NO = asat.AGREEMENT_NO
				outer apply
				(
					select	*
					from	dbo.xfn_due_date_period(asat.ASSET_NO, aaa.BILLING_NO)
				) period
		where	aaa.AGREEMENT_NO = @agreement_no;

		select	@client_address = cad.address
		from	dbo.agreement_main am
				left join dbo.client_main cm on (cm.client_no		 = am.client_no)
				left join dbo.client_address cad on (cad.client_code = cm.code and cad.IS_LEGAL='1')
		where	am.agreement_no = @agreement_no ;

		--select	@client_name = case
		--						   when ama.client_type = 'CORPORATE' then name_shareholder.full_name
		--						   else ama.client_name
		--					   end
		--		,@client_address = case
		--							   when ama.client_type = 'CORPORATE' then name_shareholder.ADDRESS
		--							   else cad.address
		--						   end
		--		,@client_company_name = case
		--							   when ama.client_type = 'CORPORATE' then name_shareholder.CLIENT_NAME
		--							   else null
		--						   end
		--from	dbo.agreement_main ama
		--		left join client_main cmin on cmin.CLIENT_NO = ama.CLIENT_NO
		--		left join dbo.client_address cad on cad.CLIENT_CODE = cmin.CODE and cad.is_legal='1'
		--		outer apply
		--			(
		--				select	top 1
		--						cre.full_name
		--						,cre.address
		--						,cma.client_name
		--				from	ifinopl.dbo.client_relation cre
		--						inner join dbo.client_main cma on cma.code = cre.client_code
		--				where	cre.RELATION_TYPE = 'SHAREHOLDER'
		--						and cma.client_no = ama.client_no
		--			) name_shareholder
		--where	ama.APPLICATION_NO = @p_application_no;

		select top 1
				@insurance_tpl		= mb.coverage_amount--aid.tpl_premium_amount
				,@insurance_pad		= aid.pa_driver_amount--aid.pa_driver_premium_amount
				,@insurance_pap		= aid.pa_passenger_amount--aid.pa_passenger_premium_amount
				,@insurance_srccts	= aid.srcc_premium_amount + aid.ts_premium_amount
				,@is_srcc			= aid.is_use_srcc
				,@is_ts				= aid.is_use_ts
				,@is_flood_windstorm= aid.is_use_flood
				,@is_earthquake		= aid.is_use_earthquake
		FROM	dbo.asset_insurance_detail aid
				INNER JOIN dbo.application_asset aa ON (aa.asset_no = aid.asset_no)
				INNER JOIN dbo.master_budget_insurance_rate_liability mb ON (mb.code = aid.tpl_coverage_code)
		WHERE	aa.realization_code = @p_code ;

		--select @insurance_tpl = max(aid.tpl_premium_amount)
		--		,@insurance_pad = max(aid.pa_driver_premium_amount)
		--		,@insurance_pap = max(aid.pa_passenger_premium_amount)
		--		,@insurance_srccts = max(aid.srcc_premium_amount + aid.ts_premium_amount)
		--from	dbo.asset_insurance_detail aid
		--		inner join dbo.application_asset aa on (aa.asset_no = aid.asset_no)
		--where	aa.realization_code = @p_code ;

		set @tanggal_bayar = 'Setiap tanggal ' + cast(@bast_date as nvarchar(50)) + ' setiap bulannya' ;
		set @tanggal_sewa_satu = convert(nvarchar(50), dateadd(day, @credit_term_2, @min_due_date), 3) + ' yaitu ' + cast(@credit_term_2 as nvarchar(50)) + ' Hari Kalender setelah tanggal Jatuh Tempo Pemakaian' ;
		set @tanggal_pembayaran_awal_dan_akhir = isnull(convert(nvarchar(50), dbo.xfn_bulan_indonesia(@bast_date), 3),'') + ' s/d ' + case
																																			when @bast_date is null then ''
																																			else convert(nvarchar(50), dbo.xfn_bulan_indonesia(isnull(@max_due_date,'')), 3) 
																																	  end;

		--if @harga_sewa_keseluruhan < 1000000000
		--begin
		--set @jabatan_signer = 'Dept. Head Operating Lease' ;
		--select	@employee_lessor = signer_name
		--from	ifinsys.dbo.sys_branch_signer
		--where	signer_type_code = 'HEADOPR'
		--		and BRANCH_CODE = @branch_code;
		if @harga_sewa_keseluruhan <= 1000000000
		begin
			select	@employee_lessor = sbs.signer_name 
					,@jabatan_signer = spo.description
			from	ifinsys.dbo.sys_branch_signer sbs
			inner join ifinsys.dbo.sys_employee_position sep on sep.emp_code = sbs.emp_code and sep.base_position='1'
			inner join ifinsys.dbo.sys_position spo on spo.code = sep.position_code
			where	sbs.signer_type_code = 'HEADOPR'
					and sbs.branch_code = @branch_code ;
		end

		if @harga_sewa_keseluruhan > 1000000000 and @harga_sewa_keseluruhan <= 5000000000
		begin
			select	@employee_lessor = sbs.signer_name 
					,@jabatan_signer = spo.description
			from	ifinsys.dbo.sys_branch_signer sbs
			inner join ifinsys.dbo.sys_employee_position sep on sep.emp_code = sbs.emp_code and sep.base_position='1'
			inner join ifinsys.dbo.sys_position spo on spo.code = sep.position_code
			where	sbs.signer_type_code = 'HEADMKT'
					and sbs.branch_code = @branch_code ;
		end

		if @harga_sewa_keseluruhan > 5000000000
		begin
			select	@employee_lessor = sbs.signer_name 
					,@jabatan_signer = spo.description
			from	ifinsys.dbo.sys_branch_signer sbs
			inner join ifinsys.dbo.sys_employee_position sep on sep.emp_code = sbs.emp_code and sep.base_position='1'
			inner join ifinsys.dbo.sys_position spo on spo.code = sep.position_code
			where	sbs.signer_type_code = 'VSPM'
					and sbs.branch_code = @branch_code ;
		end
		--end

		--if @harga_sewa_keseluruhan >= 1000000000  and @harga_sewa_keseluruhan < 5000000000
		--begin
		--	set @jabatan_signer = 'Direktur Operating Lease' ;
		--	select	@employee_lessor = signer_name
		--	from	ifinsys.dbo.sys_branch_signer
		--	where	signer_type_code = 'DEPTHEAD'
		--			and BRANCH_CODE = @branch_code;
		--end
		--select @main_contract_date,cast(day(@main_contract_date) as nvarchar(20)) + ' ' +dbo.fn_bulaninword(datepart(month,@main_contract_date))+ ' ' +cast(year(@main_contract_date) as nvarchar(20))


		set @tanggal_awal_bayar = dateadd(day,@credit_term_2,@min_due_date) ;

		insert into dbo.rpt_perjanjian_pelaksanaan
		(
			user_id
			,application_no
			,report_company
			,report_title
			,report_image
			,agreement_external_no
			,agreement_date
			,client_name
			,main_contract_no
			,application_date
			,lokasi_penyerahan
			,lokasi_pengambilan
			,jangka_waktu
			,from_jangka_waktu
			,end_jangka_waktu
			,jenis_kendaraan
			,jumlah
			,tahun
			,harga_sewa_keseluruhan
			,harga_sewa_perbulan
			,tanggal_bayar
			,tanggal_sewa_satu
			,star_sewa_berikutnya
			,end_sewa_berikutnya
			,metode_pembayaran
			,persen_denda
			,jarak_tempu
			,biaya_kilometer
			,golive_date
			,employee_lessor
			,jabatan_lessor
			,pic_lessee
			,hari
			,day
			,month
			,year
			,tanggal
			,client_address
			,credit_term
			,billing_type
			,insurance_tpl
			,insurance_pad
			,insurance_pap
			,insurance_srccts
			,et_penalty
			,report_company_address
			,tanggal_pembayaran_awal_dan_akhir
			,ppn_pct
			,no_rangka
			,no_mesin
			,karoseri
			,aksesoris
			,pct_unit
			,AGREEMENT_SIGN_DATE
			,company_name
			,top_date
			,tanggal_bayar_awal
			,IS_SRCC
			,IS_TS
			,IS_FLOOD_WINDSTORM
			,IS_EARTHQUAKE
		)
		values
		(	@p_user_id --user_id 
			,@p_application_no --application_no 
			,'PT. Dipo Star Finance' --report_company
			,@report_title --report_title
			,@report_title --report_image
			,@no_agreement --agreement_external_no
			,cast(day(isnull(@agreement_date,@agreement_date_realization)) as nvarchar(20)) + ' ' +dbo.fn_bulaninword(datepart(month,isnull(@agreement_date,@agreement_date_realization)))+ ' ' +cast(year(isnull(@agreement_date,@agreement_date_realization)) as nvarchar(20))--agreement_date
			--,cast(day(@application_date) as nvarchar(20)) + ' ' +dbo.fn_bulaninword(datepart(month,@application_date))+ ' ' +cast(year(@application_date) as nvarchar(20))--agreement_date
			,@client_name --client_name
			,@main_contract_no --main_contract_no
			,cast(day(@main_contract_date) as nvarchar(20)) + ' ' +dbo.fn_bulaninword(datepart(month,@main_contract_date))+ ' ' +cast(year(@main_contract_date) as nvarchar(20)) --application_date
			,'Terlampir' --lokasi_penyerahan
			,'Terlampir' --lokasi_pengambilan
			,@periode --jangka_waktu
			,cast(day(@bast_date) as nvarchar(20)) + ' ' +dbo.fn_bulaninword(datepart(month,@bast_date))+ ' ' +cast(year(@bast_date) as nvarchar(20)) --from_jangka_waktu
			,case
				when @bast_date is null then ''
				else cast(day(@max_due_date) as nvarchar(20)) + ' ' +dbo.fn_bulaninword(datepart(month,@max_due_date))+ ' ' +cast(year(@max_due_date) as nvarchar(20)) --end_jangka_waktu
			end
			,case
				 when @jumlah > 1 then 'Terlampir'
				 else @asset_name
			 end --jenis_kendaraan
			,@jumlah --jumlah (select count application asset)
			,case
				 when @jumlah > 1 then 'Terlampir'
				 else @asset_year
			 end --tahun
			,@harga_sewa_keseluruhan --harga_sewa_keseluruhan
			,@harga_sewa_perbulan --harga_sewa_perbulan
			,case
				 when @jumlah > 1 then 'Terlampir'
				 else @tanggal_bayar
			 end --tanggal_bayar
			,case
				 when @jumlah > 1 then 'Terlampir'
				 else @tanggal_sewa_satu
			 end --tanggal_sewa_satu
			,convert(nvarchar(50), @star_sewa_berikutnya, 3) --star_sewa_berikutnya
			,convert(nvarchar(50), @max_due_date, 3) --end_sewa_berikutnya
			,'' --metode_pembayaran
			,@charges_pct --persen_denda
			,@monthly_miles * @periode --jarak_tempu
			,0 --biaya_kilometer
			,isnull(dbo.xfn_bulan_indonesia(isnull(@agreement_date,@agreement_date_realization)),'-') --golive_date
			,@employee_lessor --employee_lessor (select sys branch signer)
			,@jabatan_signer --jabatan_lessor
			,'' --pic_lessee
			,case 
				when datename(weekday,dbo.xfn_get_system_date()) = 'Monday' then 'Senin'--hari
				when datename(weekday,dbo.xfn_get_system_date()) = 'Tuesday' then 'Selasa'--hari
				when datename(weekday,dbo.xfn_get_system_date()) = 'Wednesday' then 'Rabu'--hari
				when datename(weekday,dbo.xfn_get_system_date()) = 'Thursday' then 'Kamis'--hari
				when datename(weekday,dbo.xfn_get_system_date()) = 'Friday' then 'Jumat'--hari
				when datename(weekday,dbo.xfn_get_system_date()) = 'Sunday' then 'Minggu'--hari
				else 'Sabtu'
			end
			,dbo.Terbilang(day(dbo.xfn_get_system_date())) --day
			,dbo.fn_bulaninword(month(dbo.xfn_get_system_date())) --month
			,dbo.Terbilang(year(dbo.xfn_get_system_date())) --year
			,convert(nvarchar(30),dbo.xfn_get_system_date(),103) --tanggal
			,@client_address --client_address
			,@credit_term_2--dbo.xfn_bulan_indonesia(@credit_term)
			,@billing_type
			,isnull(@insurance_tpl,0)
			,isnull(@insurance_pad,0)
			,isnull(@insurance_pap,0)
			,isnull(@insurance_srccts,0)
			,@et_pct
			,@report_company_address
			,case
				 when @jumlah > 1 then 'Terlampir'
				 else @tanggal_pembayaran_awal_dan_akhir
			 end
			,@ppn_pct
			,case
				 when @jumlah > 1 then 'Terlampir'
				 else @no_rangka
			 end
			,case
				 when @jumlah > 1 then 'Terlampir'
				 else @no_mesin 
			 end
			,case
				 when @count_karoseri > 1 then 'Terlampir'
				 else @karoseri
			 end
			,case
				 when @count_aksesoris > 1 then 'Terlampir'
				 else @aksesoris
			 end
			 ,@pct_unit
			 ,isnull(dbo.xfn_bulan_indonesia(@agreement_date),'-')--isnull(dbo.xfn_bulan_indonesia(isnull(@agreement_sign_date,@application_date)),'-')
			 ,@client_company_name
			 ,@credit_term_2
			 ,isnull(dbo.xfn_bulan_indonesia(@tanggal_awal_bayar),'')
			 ,@is_srcc
			 ,@is_ts
			 ,@is_flood_windstorm
			 ,@is_earthquake
		) ;

		SELECT @max_due_date = max(period.period_due_date)
		FROM	dbo.agreement_asset asat with (nolock)
		inner join dbo.agreement_asset_amortization aaa with (nolock) on aaa.asset_no = asat.asset_no
														   AND aaa.AGREEMENT_NO = asat.AGREEMENT_NO
		inner join dbo.agreement_main am on am.agreement_no = aaa.agreement_no 
		outer apply
		(
			select	period_due_date
			from	dbo.xfn_due_date_period(asat.asset_no, aaa.billing_no)
		) period
		WHERE	am.APPLICATION_NO = @p_application_no ;

		SELECT @min_due_date = min(period.period_due_date)
		FROM	dbo.agreement_asset asat with (nolock)
		inner join dbo.agreement_asset_amortization aaa with (nolock) on aaa.asset_no = asat.asset_no
														   AND aaa.AGREEMENT_NO = asat.AGREEMENT_NO
		inner join dbo.agreement_main am on am.agreement_no = aaa.agreement_no 
		outer apply
		(
			select	period_due_date
			from	dbo.xfn_due_date_period(asat.asset_no, aaa.billing_no)
		) period
		WHERE	am.APPLICATION_NO = @p_application_no ;



		declare curr_perjanjian_pelaksanaan_lampiran_i cursor local FAST_FORWARD read_only for
		select	ae.main_contract_no -- no_induk				 
				,am.application_external_no -- no_pelaksanaan		 
				,am.application_date -- tanggal_perjanjian	 
				,am.client_name -- nama_lessee			 
				,apss.asset_name -- nama_barang			 
				,apss.asset_year -- tahun				 
				,isnull(aas.fa_reff_no_02,apss.fa_reff_no_02) -- no_rangka			 
				,isnull(aas.fa_reff_no_03,apss.fa_reff_no_03) -- no_mesin				 
				,stuff((
										 select ', ' + isnull(replace(asd.description, '&', ' dan '), '')
										 from	application_asset_detail asd
										 where	asd.asset_no = apss.asset_no AND asd.type = 'KAROSERI'
										 for xml path('')
									 ), 1, 1, ''
									) 		 
				,'' -- aksesoris
				,isnull(aas.asset_no, apss.asset_no)
				,rz.agreement_external_no
				,isnull(aas.fa_reff_no_01, apss.fa_reff_no_01)
				,apss.lease_rounded_amount
				,isnull(aas.handover_bast_date, apss.handover_bast_date)
				,@max_due_date 
                ,@min_due_date
				,@max_due_date
				,isnull(aas.deliver_to_address, apss.deliver_to_address)
		from	dbo.realization rz
				inner join dbo.application_main am on (am.application_no	  = rz.application_no)
				inner join dbo.application_extention ae on (ae.application_no = rz.application_no)
				inner join dbo.application_asset apss on (apss.realization_code = rz.code)
				left join dbo.agreement_asset aas on (aas.agreement_no = apss.agreement_no and aas.asset_no = apss.asset_no)
		where	rz.code = @p_code;
		
		open curr_perjanjian_pelaksanaan_lampiran_i ;

		fetch next from curr_perjanjian_pelaksanaan_lampiran_i
		into @no_induk
			 ,@no_pelaksanaan
			 ,@tanggal_perjanjian
			 ,@nama_lessee
			 ,@nama_barang
			 ,@tahun
			 ,@no_rangka
			 ,@no_mesin
			 ,@spesifikasi
			 ,@aksesoris
			 ,@asset_no
			 ,@no_agreement
			 ,@no_polisi
			 ,@sewa_per_bulan
			 ,@jangka_waktu_from
			 ,@jangka_waktu_to
			 ,@jadwal_Pembayaran_to
			 ,@jadwal_pembayaran_from
			 ,@lokasi

		while @@fetch_status = 0
		begin
			insert into dbo.rpt_perjanjian_pelaksanaan_lampiran_i
			(
				user_id
				,report_company
				,report_title
				,report_image
				,no_induk
				,no_pelaksanaan
				,tanggal_perjanjian
				,nama_lessee
				,nama_barang
				,tahun
				,no_rangka
				,no_mesin
				,spesifikasi
				,aksesoris
				,no_polisi
				,sewa_per_bulan
				,jangka_waktu_from
				,jangka_waktu_to
				,jadwal_Pembayaran_to
				,jadwal_pembayaran_from
			)
			values
			(	@p_user_id -- user_id
				,@report_company -- report_company
				,@report_title -- report_title
				,@report_image -- report_image
				,@no_induk -- no_induk
				,@no_agreement -- no_pelaksanaan
				,dbo.xfn_bulan_indonesia(isnull(@agreement_date,@agreement_date_realization)) -- tanggal_perjanjian
				,@nama_lessee -- nama_lessee
				,@nama_barang -- nama_barang
				,@tahun -- tahun
				,@no_rangka -- no_rangka
				,@no_mesin -- no_mesin
				,@spesifikasi -- spesifikasi
				,@aksesoris -- aksesoris
				,@no_polisi
				,@sewa_per_bulan
				,@jangka_waktu_from
				,@jangka_waktu_to
				,@jadwal_Pembayaran_to
				,@jadwal_pembayaran_from
			) ;

			insert into dbo.rpt_perjanjian_pelaksanaan_lampiran_iii
			(
				user_id
				,report_company
				,report_title
				,report_image
				,no_induk
				,no_pelaksanaan
				,tanggal_perjanjian
				,nama_lessee
				,nama_barang
				,tahun
				,no_rangka
				,no_mesin
				,spesifikasi
				,aksesoris
				,no_polisi
				,tanggal_bast
				,lokasi_penyerahan_pengembalian
				,employee_lessor
			)
			values
			(	@p_user_id
				,@report_company
				,@report_title
				,@report_image
				,@no_induk
				,@no_agreement
				,dbo.xfn_bulan_indonesia(isnull(@agreement_date,@agreement_date_realization))
				,@nama_lessee
				,@nama_barang
				,@tahun
				,@no_rangka
				,@no_mesin
				,@spesifikasi
				,@aksesoris
				,@no_polisi
				,@jangka_waktu_from
				,@lokasi
				,@employee_lessor
				--
			) ;
			

			select	@tanggal_pembayaran_awal_dan_akhir = convert(nvarchar(50), @star_sewa_berikutnya, 3) + ' s/d ' + convert(nvarchar(50), @max_due_date, 3)
					,@tanggal_sewa_satu = convert(nvarchar(50), dateadd(day, @credit_term_2, @min_due_date), 3) + ' yaitu ' + cast(@credit_term_2 as nvarchar(50)) + ' Hari Kalender setelah tanggal Jatuh Tempo Pemakaian' 
					,@tanggal_bayar = 'Setiap tanggal ' + cast(@min_due_day as nvarchar(50)) + ' setiap bulannya'
			from	application_amortization
			where asset_no = @asset_no 

			insert into dbo.rpt_perjanjian_pelaksanaan_jadwal_pembayaran
			(
				user_id
				,report_company
				,report_title
				,report_image
				,tanggal_bayar
				,tanggal_sewa_satu
				,tanggal_pembayaran_awal_dan_akhir
				,credit_term
			)
			values
			(	@p_user_id
				,@report_company
				,@report_title
				,@report_image
				,@tanggal_bayar -- TANGGAL_BAYAR  
				,@tanggal_sewa_satu -- TANGGAL_SEWA_SATU
				,@tanggal_pembayaran_awal_dan_akhir -- TANGGAL_PEMBAYARAN_AWAL_DAN_AKHIR
				,@credit_term_2 -- CREDIT_TERM
			) 

			fetch next from curr_perjanjian_pelaksanaan_lampiran_i
			into @no_induk
				 ,@no_pelaksanaan
				 ,@tanggal_perjanjian
				 ,@nama_lessee
				 ,@nama_barang
				 ,@tahun
				 ,@no_rangka
				 ,@no_mesin
				 ,@spesifikasi
				 ,@aksesoris
				 ,@asset_no
				 ,@no_agreement
				 ,@no_polisi
				 ,@sewa_per_bulan
				 ,@jangka_waktu_from
				 ,@jangka_waktu_to
				 ,@jadwal_Pembayaran_to
				 ,@jadwal_pembayaran_from
				 ,@lokasi
		end ;

		close curr_perjanjian_pelaksanaan_lampiran_i ;
		deallocate curr_perjanjian_pelaksanaan_lampiran_i ;
		
		select	@jumlah_barang = count(NAMA_BARANG)
		from	dbo.rpt_perjanjian_pelaksanaan_lampiran_i
		where	user_id = @p_user_id ;

		if @jumlah_barang>1
			update dbo.RPT_PERJANJIAN_PELAKSANAAN set JENIS_KENDARAAN='Terlampir' where user=@p_user_id;

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
