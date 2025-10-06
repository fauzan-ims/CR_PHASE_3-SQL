--created by, Bilal at 06/07/2023 

CREATE PROCEDURE dbo.xsp_rpt_sppa_without_payment_status
(
	@p_user_id				nvarchar(max)
	,@p_sppa_no				nvarchar(50)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin

	delete dbo.rpt_sppa_without_payment_status
	where user_id = @p_user_id ;

	--(untuk data looping)
	delete dbo.rpt_sppa_without_payment_status_detail
	where user_id = @p_user_id ;

	declare	@msg					 nvarchar(max)
			,@report_company		 nvarchar(250)
			,@report_image			 nvarchar(250)
			,@report_title			 nvarchar(250)
			,@report_address		 nvarchar(250)
			,@asuransi_name			 nvarchar(250)
		    ,@nama_pemohon			 nvarchar(250)
		    ,@alamat_pemohon		 nvarchar(4000)
		    ,@no_kontrak			 nvarchar(50)
		    ,@merk					 nvarchar(50)
		    ,@type					 nvarchar(50)
		    ,@tahun					 nvarchar(4)
		    ,@no_polisi				 nvarchar(20)
		    ,@warna					 nvarchar(50)
		    ,@no_rangka				 nvarchar(50)
		    ,@no_mesin				 nvarchar(50)
			,@status_pembayaran		 nvarchar(250)
		    ,@kondisi_pertanggungan  nvarchar(250)
		    ,@jangka_bulan			 int
		    ,@star_periode_jangka	 datetime
		    ,@end_periode_jangka	 datetime
		    ,@pertanggungan_tahun1	 decimal(18, 2)
		    ,@pertanggungan_tahun2	 decimal(18, 2)
		    ,@pertanggungan_tahun3	 decimal(18, 2)
		    ,@pertanggungan_tahun4	 decimal(18, 2)
		    ,@pertanggungan_tahun5	 decimal(18, 2)
		    ,@note					 nvarchar(250)
		    ,@tpl					 decimal(18, 2)
		    ,@pap					 decimal(18, 2)
		    ,@pad					 decimal(18, 2)
		    ,@kendaraan_digunakan    nvarchar(50)
		    ,@status_objek			 nvarchar(50)
		    ,@perlengkapan			 nvarchar(250)
		    ,@produk				 nvarchar(50)
		    ,@stnk_atas_nama		 nvarchar(50)
			,@kota					 nvarchar(50)
			,@tanggal				 datetime
			,@employee_name			 nvarchar(50)
			,@sppa_code				 nvarchar(50)
			,@coverage_short_name	 nvarchar(250)
			,@is_main_cover			 nvarchar(1)
			,@branch_code			 nvarchar(50)
			,@nama					 nvarchar(50)

	begin try

		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select @report_address = value 
		from	dbo.sys_global_param
		where	code = 'COMADD2' ;

		select	@employee_name = sem.name
		from	ifinsys.dbo.sys_employee_main sem
				left join ifinsys.dbo.sys_user_main sum on sem.code = sum.code
		where	sum.code = @p_user_id ;

		select	@branch_code = sppa_branch_code
		from	ifinams.dbo.sppa_main
		where	code = @p_sppa_no ;

		select	@nama = signer_name 
		from	ifinsys.dbo.sys_branch_signer
		where	signer_type_code = 'INSR'
				and branch_code = @branch_code ;

		set	@report_title = 'Permohonan Pertanggungan Asuransi'

		create table #temp
		(
			coverage_short_name nvarchar(250) collate Latin1_General_CI_AS
			,is_main_coverage	nvarchar(1)	 collate Latin1_General_CI_AS
		) ;

		declare c_coverage cursor local fast_forward for
		select		
					mco.coverage_short_name
					,mco.is_main_coverage
		from		dbo.sppa_main sma
					left join dbo.sppa_detail spd on spd.sppa_code						 = sma.code
					left join dbo.sppa_detail_asset_coverage spac on spac.sppa_detail_id = spd.id
					left join dbo.master_coverage mco on spac.coverage_code				 = mco.code
		where		sma.code = @p_sppa_no
		group by	mco.coverage_short_name,mco.IS_MAIN_COVERAGE
		order by	mco.is_main_coverage desc ;

		open c_coverage ;

		fetch c_coverage
		into @coverage_short_name
			 ,@is_main_cover ;

		while @@fetch_status = 0
		begin
			insert into #temp
			values
			(
				@coverage_short_name
				,@is_main_cover
			) ;

			fetch c_coverage
			into @coverage_short_name
				 ,@is_main_cover ;
		end ;

		close c_coverage ;
		deallocate c_coverage ;
		select * from #temp
		insert into dbo.rpt_sppa_without_payment_status
		(
			user_id
			,sppa_no
			,report_company
			,report_title
			,report_image
			,asuransi_name
			,nama_pemohon
			,alamat_pemohon
			,no_kontrak
			,asset_code
			,merk
			,type
			,tahun
			,no_polisi
			,warna
			,no_rangka
			,no_mesin
			,kondisi_pertanggungan
			,jangka_bulan
			,star_periode_jangka
			,end_periode_jangka
			,pertanggungan_tahun1
			,pertanggungan_tahun2
			,pertanggungan_tahun3
			,pertanggungan_tahun4
			,pertanggungan_tahun5
			,note
			,tpl
			,pap
			,pad
			,kendaraan_digunakan
			,status_objek
			,perlengkapan
			,produk
			,stnk_atas_nama
			,kota
			,tanggal
			,employee_name
			,STNK_ALAMAT
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	distinct
				@p_user_id
				,@p_sppa_no
				,@report_company
				,@report_title
				,@report_image
				,mi.insurance_name
				,case
					when isnull(ireg.register_qq_name,'')='' then '-'
					else ireg.register_qq_name
				end
				,@report_address
				,ast.agreement_external_no
				,ast.code
				,avi.merk_name
				,avi.type_item_name
				,avi.built_year
				,avi.plat_no
				,avi.colour
				,avi.chassis_no
				,avi.engine_no
				,coverage.cover
				,ire.year_period
				,dbo.xfn_bulan_indonesia(ire.from_date)
				,dbo.xfn_bulan_indonesia(ire.to_date)
				,isnull(regas.sum_insured_amount,'0')--isnull(tes.sum_insured_amount, '0')
				,isnull(tes2.sum_insured_amount, '0')
				,isnull(tes3.sum_insured_amount, '0')
				,isnull(tes4.sum_insured_amount, '0')
				,isnull(tes5.sum_insured_amount, '0')
				,'Tahun Terakhir +  1 Bulan'
				,isnull(tes6a.sum_insured_amount, '0') + isnull(tes6b.sum_insured_amount, '0') + isnull(tes6c.sum_insured_amount, '0')
				,isnull(tes7.sum_insured_amount, '0')
				,isnull(tes8.sum_insured_amount, '0')
				,'Perusahaan'
				--,isnull(ast.rental_status,'-')
				,'Disewakan'
				,'Terlampir'
				,'Operating Lease'
				,case
					 when isnull(avi.stnk_name, '') = '' then '-'
					 else avi.stnk_name
				 end
				,'Jakarta'--sc.description
				,dbo.xfn_bulan_indonesia(dbo.xfn_get_system_date())
				,@nama
				,isnull(avi.stnk_address,'-')
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.sppa_main sma
				left join dbo.sppa_detail spd on spd.sppa_code = sma.code
				left join dbo.sppa_detail_asset_coverage spac on spac.sppa_detail_id = spd.id
				left join dbo.master_coverage mco on spac.coverage_code = mco.code
				left join dbo.asset ast on ast.code = spd.fa_code
				left join dbo.master_insurance mi on mi.code = sma.insurance_code
				left join dbo.insurance_policy_main ipm on ipm.sppa_code = sma.code
				left join dbo.insurance_policy_asset ipa on ipa.policy_code = ipm.code
				left join dbo.sppa_request sprq on sprq.code = spd.sppa_request_code
				left join dbo.insurance_register ireg on ireg.code = sprq.register_code
				left join ifinopl.dbo.client_relation cci on cci.client_code = ast.client_no
				left join asset_vehicle avi on avi.asset_code = ast.code
				left join dbo.sppa_request spq on spq.sppa_code = sma.code
				left join dbo.insurance_register ire on ire.code = spq.register_code
				left join ifinsys.dbo.sys_branch sb on sb.code = ast.branch_code
				inner join ifinsys.dbo.sys_city sc on (sc.code = sb.city_code)
				OUTER APPLY
				(
					SELECT	iras.SUM_INSURED_AMOUNT
					FROM	dbo.INSURANCE_REGISTER_ASSET iras
					WHERE	iras.REGISTER_CODE = ireg.CODE
					AND		iras.FA_CODE = ast.code
				) regas
				outer apply
				(
					select	spd1.sum_insured_amount*spac.rate_depreciation/100 'sum_insured_amount'
					from	dbo.sppa_detail spd1
					inner join dbo.sppa_detail_asset_coverage spac on spac.sppa_detail_id = spd1.id
					where	spd1.sppa_code	   = sma.code
							and spac.year_periode = 1
				) tes
				outer apply
				(
					select	spd1.sum_insured_amount*spac.rate_depreciation/100 'sum_insured_amount'
					from	dbo.sppa_detail spd1
					inner join dbo.sppa_detail_asset_coverage spac on spac.sppa_detail_id = spd1.id
					where	spd1.sppa_code	   = sma.code
							and spac.year_periode = 2
				) tes2
				outer apply
				(
					select	spd1.sum_insured_amount*spac.rate_depreciation/100 'sum_insured_amount'
					from	dbo.sppa_detail spd1
					inner join dbo.sppa_detail_asset_coverage spac on spac.sppa_detail_id = spd1.id
					where	spd1.sppa_code	   = sma.code
							and spac.year_periode = 3
				) tes3
				outer apply
				(
					select	spd1.sum_insured_amount*spac.rate_depreciation/100 'sum_insured_amount'
					from	dbo.sppa_detail spd1
					inner join dbo.sppa_detail_asset_coverage spac on spac.sppa_detail_id = spd1.id
					where	spd1.sppa_code	   = sma.code
							and spac.year_periode = 4
				) tes4
				outer apply
				(
					select	spd1.sum_insured_amount*spac.rate_depreciation/100 'sum_insured_amount'
					from	dbo.sppa_detail spd1
					inner join dbo.sppa_detail_asset_coverage spac on spac.sppa_detail_id = spd1.id
					where	spd1.sppa_code	   = sma.code
							and spac.year_periode = 5
				) tes5
				outer apply
				(
					select	spd1.sum_insured_amount
					from	dbo.sppa_detail spd1
							left join dbo.sppa_detail_asset_coverage spac2 on spac2.sppa_detail_id = spd1.id
							left join dbo.master_coverage mco on spac2.coverage_code			   = mco.code
					where	spac2.year_periode			= 1
							and mco.COVERAGE_SHORT_NAME = 'TPL100'
							and spd1.sppa_code			= sma.code
							and spd1.FA_CODE = ast.code
				) tes6a
				outer apply
				(
					select	spd1.sum_insured_amount
					from	dbo.sppa_detail spd1
							left join dbo.sppa_detail_asset_coverage spac2 on spac2.sppa_detail_id = spd1.id
							left join dbo.master_coverage mco on spac2.coverage_code			   = mco.code
					where	spac2.year_periode			= 1
							and mco.COVERAGE_SHORT_NAME = 'TPLCAR'
							and spd1.sppa_code			= sma.code
							and spd1.FA_CODE = ast.code
				) tes6b
				outer apply
				(
					select	spd1.sum_insured_amount
					from	dbo.sppa_detail spd1
							left join dbo.sppa_detail_asset_coverage spac2 on spac2.sppa_detail_id = spd1.id
							left join dbo.master_coverage mco on spac2.coverage_code			   = mco.code
					where	spac2.year_periode			= 1
							and mco.COVERAGE_SHORT_NAME = 'TPLBUS'
							and spd1.sppa_code			= sma.code
							and spd1.FA_CODE = ast.code
				) tes6c
				outer apply
				(
					select	spd1.sum_insured_amount
					from	dbo.sppa_detail spd1
							left join dbo.sppa_detail_asset_coverage spac2 on spac2.sppa_detail_id = spd1.id
							left join dbo.master_coverage mco on spac2.coverage_code			   = mco.code
					where	spac2.year_periode			= 1
							and mco.COVERAGE_SHORT_NAME = 'PERSPASS'
							and spd1.sppa_code			= sma.code
				) tes7
				outer apply
				(
					select	spd1.sum_insured_amount
					from	dbo.sppa_detail spd1
							left join dbo.sppa_detail_asset_coverage spac2 on spac2.sppa_detail_id = spd1.id
							left join dbo.master_coverage mco on spac2.coverage_code			   = mco.code
					where	spac2.year_periode			= 1
							and mco.COVERAGE_SHORT_NAME = 'PERSDRI'
							and spd1.sppa_code			= sma.code
				) tes8
				outer apply (
					select stuff((
						   select	', ' + isnull(replace(coverage_short_name, '&', ' dan '), '')
						   from		#temp
						   for xml path('')
					   ), 1, 1, ''
					  ) 'cover'
					  from dbo.MASTER_COVERAGE mco1
					  where mco1.CODE = spac.COVERAGE_CODE
				) coverage
		where	sma.code = @p_sppa_no
				--and ast.RENTAL_STATUS = 'IN USE';

		insert into dbo.rpt_sppa_without_payment_status_detail
		(
			user_id
			,asset_code
			,nama_unit
			,harga_unit
			,perlengkapan
			,aksesoris
			,harga
			,total_harga
		)
		select  @p_user_id
				,ast.code
				,ast.item_name
				,ast.original_price--spd.sum_insured_amount
				,isnull(stuff((
						   select	distinct ', ' + isnull(replace(adjd.adjustment_description,'&',' dan '), '')
						   from	dbo.sppa_main sma
									left join dbo.sppa_detail spd on spd.sppa_code = sma.code
									left join dbo.asset ast1 on ast1.code = spd.fa_code
									left join asset_vehicle avi on avi.asset_code = ast1.code
									left join dbo.adjustment adj on adj.asset_code = ast1.code
									left join dbo.adjustment_detail adjd on adjd.adjustment_code = adj.code
							where sma.code = @p_sppa_no
							and ast1.code = ast.code
							and isnull(adjd.adjustment_description,'') <> ''
						   for xml path('')
					   ), 1, 1, ''
					  ),'-')
				,''
				,jumlah.total
				,ast.original_price+jumlah.total--spd.sum_insured_amount
		from	dbo.sppa_main sma
				left join dbo.sppa_detail spd on spd.sppa_code = sma.code
				left join dbo.asset ast on ast.code = spd.fa_code
				left join asset_vehicle avi on avi.asset_code = ast.code
				left join dbo.adjustment adj on adj.asset_code = ast.code
				left join dbo.adjustment_detail adjd on adjd.adjustment_code = adj.code
				outer apply(
					select isnull(sum(total_adjustment),0) 'total' from dbo.adjustment
					where asset_code = ast.code and status='POST'
				)jumlah
		where sma.code = @p_sppa_no 
		group by ast.code,ast.item_name,ast.ORIGINAL_PRICE,jumlah.total;

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
END
