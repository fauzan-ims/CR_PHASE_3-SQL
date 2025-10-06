CREATE PROCEDURE dbo.xsp_rpt_asset_exchange_list
(
	@p_user_id						nvarchar(50)
	,@p_from_date					datetime		= ''
	,@p_to_date						datetime		= ''
	,@p_date_type					nvarchar(50)	= ''
	,@p_report_type					nvarchar(50)	= ''
	,@p_area_code					nvarchar(50)	= ''
	,@p_branch_code					nvarchar(50)	= ''
	,@p_branch_name					nvarchar(250)	= ''
	,@p_category_code				nvarchar(50)	= ''
	,@p_item_group_code				nvarchar(50)	= ''
	,@p_net_book_value_commercial	nvarchar(50)	= ''
	,@p_net_book_value_fiscal		nvarchar(50)	= ''
)
as
begin
	delete	dbo.rpt_asset_exchange_list_summary
	where	user_id = @p_user_id ;

	declare @code_office_name									nvarchar(100)
			,@initial_office_name								nvarchar(50)
			,@office_full_name									nvarchar(50)
			,@office_code										nvarchar(50)
			,@office_name										nvarchar(250)
			,@barcode											nvarchar(50)
			,@item_name											nvarchar(250)
			,@no_ref_to_gl										nvarchar(250)
			,@tgl_perolehan										datetime
			,@tgl_akhir_penyusutan								nvarchar(10)
			,@tgl_perolehan_stlh_peyusutan						datetime
			,@tgl_perolehan_stlh_penyesuaian					datetime
			,@tgl_akhir_penysusutan_stlh_penyesuaian			datetime
			,@umur_manfaat_ekonomis								nvarchar(50)
			,@umur_manfaat_ekonomis_stlh_penyesuaian			nvarchar(50)
			,@harga_perolehan									decimal(18,2)
			,@nilai_residu										decimal(18,2)
			,@penyesuaian_harga_perolehan						decimal(18,2)
			,@harga_perolehan_setelah_penyesuaian				decimal(18,2)
			,@penyusutan_per_bulan								decimal(18,2)
			,@akumulasi_penyusutan_awal_tahun					decimal(18,2)
			,@peyusutan_tahun_berjalan							decimal(18,2)
			,@penyusutan_penyesuaian							decimal(18,2)
			,@akumulasi_penyusutan_akhir_tahun					decimal(18,2)
			,@nilai_buku_akhir_tahun							decimal(18,2)
			,@umur_manfaat_ekonomis_fiskal						nvarchar(50)
			,@umur_manfaat_ekonomis_fiskal_stlh_pnyesuaian		nvarchar(50)
			,@penyusutan_per_bulan_fiskal						decimal(18,2)
			,@akumulasi_penyusutan_awal_tahun_fiskal			decimal(18,2)
			,@penyusutan_tahun_berjalan_fiskal					decimal(18,2)
			,@penyesuaian_fiskal								decimal(18,2)
			,@akumulasi_penyusutan_akhir_tahun_fiskal			decimal(18,2)
			,@nilai_buku_akhir_tahun_fiskal						decimal(18,2)
			,@selisih_nilai_buku_komersial_dan_fiskal			decimal(18,2)
			,@selisih_penyusutan_komersial_dan_fiskal			decimal(18,2)
			,@penyusutan_tahun_berjalan_nde_fiskal				decimal(18,2)
			,@status											nvarchar(250)
			,@tgl_pertukaran_asset								datetime
			,@kategori_asal										nvarchar(50)
			,@barcode_yang_diberikan							nvarchar(50)
			,@nilai_buku_asset_yang_diberikan_komersial			decimal(18,2)
			,@nilai_buku_asset_yang_diberikan_fiscal			decimal(18,2)
			--  
			,@msg						nvarchar(max) ;

	begin try
		/* declare main cursor */
		declare c_pertukaran_asset cursor local fast_forward read_only for
		
		select top 10	ass.branch_code																																															'ID Office Name'
				,ass.branch_name																																														'Nama Office Name'
				,ass.barcode																																															'Kode Asset (Barcode)'
				,ass.item_name																																															'Nama Aset Tetap'
				,''																																																		'No.Ref to GL'
				,ass.purchase_date																																														'Tanggal Perolehan'
				,ass.depre_period_comm																																													'Tangal Akhir Penyusutan'
				,null																																																	'Tanggal Perolehan setelah Penyesuaian'
				,null																																																	'Tanggal Akhir Penyusutan setelah Penyesuaian'
				,ass.use_life * 12																																														'Umur Manfaat Ekonomis (dalam bulan)'
				,0																																																		'Umur Manfaat Ekonomis (dalam bulan) setelah penyesuian'
				,ass.purchase_price																																														'Harga Perolehan'
				,0																																																		'Nilai Residu'
				,0																																																		'Penyesuaian Harga Perolehan'
				,0																																																		'Harga Perolehan Setelah Penyesuaian'
				,isnull(ass.purchase_price/(ass.use_life * 12),0)																																						'Peyusuan per Bulan'
				,0																																																		'Akumulasi Penyusutan Awal Tahun'
				,12 * isnull(ass.purchase_price/(ass.use_life * 12),0)																																					'Penyusutan Tahun Berjalan'
				,0																																																		'Penyesuaian Penyusutan'
				,0 + (12 * isnull(ass.purchase_price/(ass.use_life * 12),0)) + 0																																		'Akumulasi Penyusutan Akhir Tahun'
				,isnull(ass.purchase_price,0) - (0 + (12 * isnull(ass.purchase_price/(ass.use_life * 12),0)) + 0)																										'Nilai Buku Akhir Tahun'
				,ass.depre_period_fiscal * 12																																											'Umur Manfaat Ekonomis Fiskal (dalam bulan)'
				,0																																																		'Umur Manfaat EKonomis Fiskal Setelah Penyesuaian (dalam bulan)'
				,ass.purchase_price/ (ass.depre_period_fiscal * 12)																																						'Penyusutan per Bulan Fiskal'
				,0																																																		'Akumulasi Penyusutan Awal Tahun Fiskal'
				,12 * (ass.purchase_price/ (ass.depre_period_fiscal * 12))																																				'Penyusutan Tahun Berjalan Fiskal'
				,0																																																		'Penyesuaian Fiskal'
				,0 + (12 * (ass.purchase_price/ (ass.depre_period_fiscal * 12))) + 0																																	'Akumulasi Penyusutan Akhir Tahun Fiskal'
				,ass.purchase_price - (0 + (12 * (ass.purchase_price/ (ass.depre_period_fiscal * 12))) + 0	)																											'Nilai Buku Akhir Tahun Fiskal'
				,isnull(ass.purchase_price,0) - (0 + (12 * isnull(ass.purchase_price/(ass.use_life * 12),0)) + 0) - (ass.purchase_price - (0 + (12 * (ass.purchase_price/ (ass.depre_period_fiscal * 12))) + 0	))		'Selisih Nilai Buku Komersial dan Fiskal'
				,((isnull(ass.purchase_price/(ass.use_life * 12),0)) + (0)) - ((12 * (ass.purchase_price/ (ass.depre_period_fiscal * 12))) + (0))																		'Selisih Penyusutan Komersial dan Fiskal'
				, (1/100) * ((isnull(ass.purchase_price/(ass.use_life * 12),0)) + (0)) - ((12 * (ass.purchase_price/ (ass.depre_period_fiscal * 12))) + (0))															'Penyusutan Tahun Berjalan NDE Fiskal'
				,''																																																		'Status'
				,null																																																	'Tanggal Pertukaran Asset'
				,''																																																		'Kategori Asal'
				,''																																																		'Kode Barcode yang Diberikan'
				,0																																																		'Nilai Buku Aset yang Diberikan Komersial'
				,0																																																		'Nilai Buku Aset yang Diberikan Fiskal'
		from dbo.asset ass

		open c_pertukaran_asset ;

		fetch c_pertukaran_asset
		into @office_code
			,@office_name
			,@barcode
			,@item_name
			,@no_ref_to_gl
			,@tgl_perolehan
			,@tgl_akhir_penyusutan
			,@tgl_perolehan_stlh_penyesuaian
			,@tgl_akhir_penysusutan_stlh_penyesuaian
			,@umur_manfaat_ekonomis
			,@umur_manfaat_ekonomis_stlh_penyesuaian
			,@harga_perolehan
			,@nilai_residu
			,@penyesuaian_harga_perolehan
			,@harga_perolehan_setelah_penyesuaian
			,@penyusutan_per_bulan
			,@akumulasi_penyusutan_awal_tahun
			,@peyusutan_tahun_berjalan
			,@penyusutan_penyesuaian
			,@akumulasi_penyusutan_akhir_tahun
			,@nilai_buku_akhir_tahun
			,@umur_manfaat_ekonomis_fiskal
			,@umur_manfaat_ekonomis_fiskal_stlh_pnyesuaian
			,@penyusutan_per_bulan_fiskal
			,@akumulasi_penyusutan_awal_tahun_fiskal
			,@penyusutan_tahun_berjalan_fiskal
			,@penyesuaian_fiskal
			,@akumulasi_penyusutan_akhir_tahun_fiskal
			,@nilai_buku_akhir_tahun_fiskal
			,@selisih_nilai_buku_komersial_dan_fiskal
			,@selisih_penyusutan_komersial_dan_fiskal
			,@penyusutan_tahun_berjalan_nde_fiskal
			,@status
			,@tgl_pertukaran_asset
			,@kategori_asal
			,@barcode_yang_diberikan
			,@nilai_buku_asset_yang_diberikan_komersial
			,@nilai_buku_asset_yang_diberikan_fiscal

		while @@fetch_status = 0
		begin

			/* insert into table report */
			insert into rpt_asset_exchange_list_summary
			(
				user_id
				,id_office_name1
				,nama_office_name
				,kode_asset
				,nama_aset_tetap
				,no_ref_to_gl
				,tanggal_perolehan
				,tanggal_akhir_penyusutan
				,tanggal_perolehan_setelah_penyesuaian
				,tanggal_akhir_penyusutan_setelah_penyesuaian
				,umur_manfaat_ekonomis
				,umur_manfaat_ekonomis_setelah_penyesuaian
				,harga_perolehan
				,nilai_residu
				,penyesuaian_harga_perolehan
				,harga_perolehan_setelah_penyesuaian
				,peyusutan_per_bulan
				,akumulasi_penyusutan_awal_tahun
				,penyusutan_tahun_berjalan
				,penyesuaian_penyusutan
				,akumulasi_penyusutan_akhir_tahun
				,nilai_buku_akhir_tahun
				,umur_manfaat_ekonomis_fiskal
				,umur_manfaat_ekonomis_fiskal_setelah_penyesuaian
				,penyusutan_per_bulan_fiskal
				,akumulasi_penyusutan_awal_tahun_fiskal
				,penyusutan_tahun_berjalan_fiskal
				,penyesuaian_fiskal
				,akumulasi_penyusutan_akhir_tahun_fiskal
				,nilai_buku_akhir_tahun_fiskal
				,selisih_nilai_buku_komersial_dan_fiskal
				,selisih_penyusutan_komersial_dan_fiskal
				,penyusutan_tahun_berjalan_nde_fiskal
				,status
				,tanggal_pertukaran_aset
				,kategori_asal
				,kode_aset_yang_diberikan
				,nilai_buku_aset_yang_diberikan_komersial
				,nilai_buku_aset_yang_diberikan_fiskal
				--
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
				,@office_code
				,@office_name
				,@barcode
				,@item_name
				,@no_ref_to_gl
				,@tgl_perolehan
				,@tgl_akhir_penyusutan
				,isnull(@tgl_perolehan_stlh_penyesuaian,null)
				,isnull(@tgl_akhir_penysusutan_stlh_penyesuaian,null)
				,@umur_manfaat_ekonomis
				,@umur_manfaat_ekonomis_stlh_penyesuaian
				,@harga_perolehan
				,@nilai_residu
				,@penyesuaian_harga_perolehan
				,@harga_perolehan_setelah_penyesuaian
				,@penyusutan_per_bulan
				,@akumulasi_penyusutan_awal_tahun
				,@peyusutan_tahun_berjalan
				,@penyusutan_penyesuaian
				,@akumulasi_penyusutan_akhir_tahun
				,@nilai_buku_akhir_tahun
				,@umur_manfaat_ekonomis_fiskal
				,@umur_manfaat_ekonomis_fiskal_stlh_pnyesuaian
				,@penyusutan_per_bulan_fiskal
				,@akumulasi_penyusutan_awal_tahun_fiskal
				,@penyusutan_tahun_berjalan_fiskal
				,@penyesuaian_fiskal
				,@akumulasi_penyusutan_akhir_tahun_fiskal
				,@nilai_buku_akhir_tahun_fiskal
				,@selisih_nilai_buku_komersial_dan_fiskal
				,@selisih_penyusutan_komersial_dan_fiskal
				,@penyusutan_tahun_berjalan_nde_fiskal
				,@status
				,isnull(@tgl_pertukaran_asset,null)
				,@kategori_asal
				,@barcode_yang_diberikan
				,@nilai_buku_asset_yang_diberikan_komersial
				,@nilai_buku_asset_yang_diberikan_fiscal
				--
				,''
				,''
				,''
				,''
				,''
				,''
			)


			/* fetch record berikutnya */
			fetch c_pertukaran_asset
			into @office_code
				,@office_name
				,@barcode
				,@item_name
				,@no_ref_to_gl
				,@tgl_perolehan
				,@tgl_akhir_penyusutan
				,@tgl_perolehan_stlh_penyesuaian
				,@tgl_akhir_penysusutan_stlh_penyesuaian
				,@umur_manfaat_ekonomis
				,@umur_manfaat_ekonomis_stlh_penyesuaian
				,@harga_perolehan
				,@nilai_residu
				,@penyesuaian_harga_perolehan
				,@harga_perolehan_setelah_penyesuaian
				,@penyusutan_per_bulan
				,@akumulasi_penyusutan_awal_tahun
				,@peyusutan_tahun_berjalan
				,@penyusutan_penyesuaian
				,@akumulasi_penyusutan_akhir_tahun
				,@nilai_buku_akhir_tahun
				,@umur_manfaat_ekonomis_fiskal
				,@umur_manfaat_ekonomis_fiskal_stlh_pnyesuaian
				,@penyusutan_per_bulan_fiskal
				,@akumulasi_penyusutan_awal_tahun_fiskal
				,@penyusutan_tahun_berjalan_fiskal
				,@penyesuaian_fiskal
				,@akumulasi_penyusutan_akhir_tahun_fiskal
				,@nilai_buku_akhir_tahun_fiskal
				,@selisih_nilai_buku_komersial_dan_fiskal
				,@selisih_penyusutan_komersial_dan_fiskal
				,@penyusutan_tahun_berjalan_nde_fiskal
				,@status
				,@tgl_pertukaran_asset
				,@kategori_asal
				,@barcode_yang_diberikan
				,@nilai_buku_asset_yang_diberikan_komersial
				,@nilai_buku_asset_yang_diberikan_fiscal
		end ;

		/* tutup cursor */
		close c_pertukaran_asset ;
		deallocate c_pertukaran_asset ;

		select ast.regional_code																										'Region Code'
			  ,id_office_name1																											'ID Office Name'
			  ,nama_office_name																											'Nama Office Name'
			  ,kode_asset																												'Kode Asset (Barcode)'
			  ,nama_aset_tetap																											'Nama Aset Tetap'
			  ,no_ref_to_gl																												'No.Ref to GL'
			  ,tanggal_perolehan																										'Tanggal Perolehan'
			  ,tanggal_akhir_penyusutan																									'Tangal Akhir Penyusutan'
			  ,tanggal_perolehan_setelah_penyesuaian																					'Tanggal Perolehan setelah Penyesuaian'
			  ,tanggal_akhir_penyusutan_setelah_penyesuaian																				'Tanggal Akhir Penyusutan setelah Penyesuaian'
			  ,umur_manfaat_ekonomis																									'Umur Manfaat Ekonomis (dalam bulan)'
			  ,umur_manfaat_ekonomis_setelah_penyesuaian																				'Umur Manfaat Ekonomis (dalam bulan) setelah penyesuian'
			  ,harga_perolehan																											'Harga Perolehan'
			  ,nilai_residu																												'Nilai Residu'
			  ,penyesuaian_harga_perolehan																								'Penyesuaian Harga Perolehan'
			  ,harga_perolehan_setelah_penyesuaian																						'Harga Perolehan Setelah Penyesuaian'
			  ,peyusutan_per_bulan																										'Peyusuan per Bulan'
			  ,akumulasi_penyusutan_awal_tahun																							'Akumulasi Penyusutan Awal Tahun'
			  ,penyusutan_tahun_berjalan																								'Penyusutan Tahun Berjalan'
			  ,penyesuaian_penyusutan																									'Penyesuaian Penyusutan'
			  ,akumulasi_penyusutan_akhir_tahun																							'Akumulasi Penyusutan Akhir Tahun'
			  ,nilai_buku_akhir_tahun																									'Nilai Buku Akhir Tahun'
			  ,umur_manfaat_ekonomis_fiskal																								'Umur Manfaat Ekonomis Fiskal (dalam bulan)'
			  ,umur_manfaat_ekonomis_fiskal_setelah_penyesuaian																			'Umur Manfaat EKonomis Fiskal Setelah Penyesuaian (dalam bulan)'
			  ,penyusutan_per_bulan_fiskal																								'Penyusutan per Bulan Fiskal'
			  ,akumulasi_penyusutan_awal_tahun_fiskal																					'Akumulasi Penyusutan Awal Tahun Fiskal'
			  ,penyusutan_tahun_berjalan_fiskal																							'Penyusutan Tahun Berjalan Fiskal'
			  ,penyesuaian_fiskal																										'Penyesuaian Fiskal'
			  ,akumulasi_penyusutan_akhir_tahun_fiskal																					'Akumulasi Penyusutan Akhir Tahun Fiskal'
			  ,nilai_buku_akhir_tahun_fiskal																							'Nilai Buku Akhir Tahun Fiskal'
			  ,selisih_nilai_buku_komersial_dan_fiskal																					'Selisih Nilai Buku Komersial dan Fiskal'
			  ,selisih_penyusutan_komersial_dan_fiskal																					'Selisih Penyusutan Komersial dan Fiskal'
			  ,penyusutan_tahun_berjalan_nde_fiskal																						'Penyusutan Tahun Berjalan NDE Fiskal'
			  ,rpt.status																													'Status'
			  ,tanggal_pertukaran_aset																									'Tanggal Pertukaran Asset'
			  ,kategori_asal																											'Kategori Asal'
			  ,kode_aset_yang_diberikan																									'Kode Barcode yang Diberikan'
			  ,nilai_buku_aset_yang_diberikan_komersial																					'Nilai Buku Aset yang Diberikan Komersial'
			  ,nilai_buku_aset_yang_diberikan_fiskal																					'Nilai Buku Aset yang Diberikan Fiskal'
			  --
			  ,case @p_date_type	when 'RANGE' then 'Range' else 	'Cut Off' end														'Date Type'				
			  ,case @p_report_type  when 'SUMMARY' then 'Summary' else 'Detail' end														'Report Type'
			  ,@p_from_date																												'From Date'				
			  ,@p_to_date																												'To Date'				
			  ,case @p_area_code when '' then 'ALL' else @p_area_code end																'HO/BU/Cabang'
			  ,case @p_branch_code when '' then 'ALL'	else @p_branch_code end															'Office Name'						
			  ,case @p_category_code when '' then 'ALL' else @p_category_code end														'Category'
			  ,case @p_item_group_code when '' then 'ALL' else @p_item_group_code end													'Item Group'
			  ,case @p_net_book_value_commercial when 'ZERO' then 'Nol' when 'MORE' then 'Lebih Dari Nol' else 'ALL'	end				'Nilai Buku'
			  ,case @p_net_book_value_fiscal when 'MORE' then 'Lebih Dari Sama Dengan' when 'LESS' then 'Kurang Dari' else 'ALL' end	'Threshold'
			  
		from dbo.rpt_asset_exchange_list_summary rpt
			 inner join dbo.ASSET ast on ast.barcode = rpt.kode_asset collate SQL_Latin1_General_CP1_CI_AS
		where	user_id = @p_user_id ;

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
