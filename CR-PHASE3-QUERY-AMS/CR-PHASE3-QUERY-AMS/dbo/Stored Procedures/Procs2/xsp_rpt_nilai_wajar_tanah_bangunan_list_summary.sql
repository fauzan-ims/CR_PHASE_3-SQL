CREATE PROCEDURE dbo.xsp_rpt_nilai_wajar_tanah_bangunan_list_summary
(
	@p_user_id						nvarchar(50)
	,@p_date_type					nvarchar(50) 
	,@p_report_type					nvarchar(50)
	,@p_from_date					datetime
	,@p_to_date						datetime
	,@p_area_code					nvarchar(50) = ''
	,@p_branch_code					nvarchar(50) = ''
	,@p_category_code				nvarchar(50) = ''
	,@p_item_group_code				nvarchar(50) = ''
	,@p_net_book_value_commercial	nvarchar(50) = ''
	,@p_net_book_value_fiscal		nvarchar(50) = ''
)
as
begin
	delete dbo.rpt_nilai_wajar_tanah_bangunan_list_summary
	where	user_id = @p_user_id ;

	declare @code_office_name			nvarchar(100)
			,@initial_office_name		nvarchar(50)
			,@office_full_name			nvarchar(50)
			,@location					nvarchar(50)
			,@cost_center				nvarchar(50)
			,@category_code				nvarchar(50)
			,@category_name				nvarchar(250)
			,@asset_type				nvarchar(250)
			,@purchase_date				datetime
			,@purchase_order_no			nvarchar(50)
			,@barcode					nvarchar(50)
			,@old_barcode				nvarchar(50)
			,@item_group				nvarchar(50)
			,@item_name					nvarchar(250)
			,@merk						nvarchar(250)
			,@type						nvarchar(50)
			,@model						nvarchar(50)
			,@serial_number				nvarchar(50)
			,@nomor_rangka				nvarchar(50)
			,@nomor_mesin				nvarchar(50)
			,@nomor_polisi				nvarchar(250)
			,@manufacturing_years		nvarchar(250)
			,@object_info				nvarchar(50)
			,@nik						nvarchar(50)
			,@name						nvarchar(50)
			,@division					nvarchar(50)
			,@department				nvarchar(50)
			,@position					nvarchar(250)
			,@supplier					nvarchar(250)
			,@original_price			decimal(18, 2)
			,@fa_adjustment_amount		decimal(18, 2)
			,@purchase_price			decimal(18, 2)
			,@start_depre_commercial	datetime
			,@total_depre_commercial	decimal(18, 2)
			,@net_book_value_commercial decimal(18, 2)
			,@start_depre_fiscal		datetime
			,@total_depre_fiscal		decimal(18, 2)
			,@net_book_value_fiscal		decimal(18, 2)
			,@last_so_date				datetime
			,@last_so_condition			nvarchar(50)
			,@status_asset				nvarchar(250)
			,@location_from				nvarchar(250)
			,@tanggal_depre				datetime
			,@depre_or_non_depre		nvarchar(250)
			,@status_in_sistem			nvarchar(250)
			,@remarks					nvarchar(50)
			--  
			,@msg						nvarchar(max) ;

	begin try 
		/* declare main cursor */
		declare c_asset_list cursor local fast_forward read_only for
		select top 10
				ass.branch_code
				--initial_office_name		
				,ass.branch_name
				,ass.location_name
				,ass.cost_center_name
				,ass.category_code
				,ass.category_name
				,ass.type_code
				,ass.purchase_date
				--purchase_order_no			
				,ass.barcode
				--old_barcode				
				,ass.item_code
				,ass.item_name
				,av.merk_name
				,av.type_item_name
				,av.model_name
				,am.serial_no
				,av.chassis_no
				,av.engine_no
				,av.plat_no
				,av.built_year
				--object_info				
				--nik						
				--name						
				,ass.division_name
				,ass.department_name
				--position					
				--supplier					
				,ass.original_price
				--fa_adjustment_amount		
				,ass.purchase_price
				,null --dsc.depreciation_date
				,ass.total_depre_comm
				,ass.net_book_value_comm
				,null --dsf.depreciation_date
				,ass.total_depre_fiscal
				,ass.net_book_value_fiscal
				,ass.last_so_date
				,ass.last_so_condition
				,ass.status
				,ass.location_name
				--tanggal_depre				
				--depre or non depre	
				--status_in_sistem			
				,ass.remarks
		from	dbo.asset										  ass
				left join asset_vehicle							  av on (av.asset_code	 = ass.code)
				left join asset_machine							  am on (am.asset_code	 = ass.code)
				--inner join asset_depreciation_schedule_commercial dsc on (dsc.asset_code = ass.code)
				--inner join asset_depreciation_schedule_fiscal	  dsf on (dsf.asset_code = ass.code) ;

		--where	scum.is_active = case @p_date_type
		--							 when 'all' then scum.is_active
		--							 else @p_date_type
		--						 end ;
		--		cast(cul.login_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
		/* fetch record */
		open c_asset_list ;

		fetch c_asset_list
		into @code_office_name
				--,@initial_office_name		
			 ,@office_full_name
			 ,@location
			 ,@cost_center
			 ,@category_code
			 ,@category_name
			 ,@asset_type
			 ,@purchase_date
				--,@purchase_order_no			
			 ,@barcode
				--,@old_barcode				
			 ,@item_group
			 ,@item_name
			 ,@merk
			 ,@type
			 ,@model
			 ,@serial_number
			 ,@nomor_rangka
			 ,@nomor_mesin
			 ,@nomor_polisi
			 ,@manufacturing_years
				--,@object_info				
				--,@nik						
				--,@name						
			 ,@division
			 ,@department
				--,@position					
				--,@supplier					
			 ,@original_price
				--,@fa_adjustment_amount		
			 ,@purchase_price
			 ,@start_depre_commercial
			 ,@total_depre_commercial
			 ,@net_book_value_commercial
			 ,@start_depre_fiscal
			 ,@total_depre_fiscal
			 ,@net_book_value_fiscal
			 ,@last_so_date
			 ,@last_so_condition
			 ,@status_asset
			 ,@location_from
				--,@tanggal_depre				
				--,@depre_or_non_depre		
				--,@status_in_sistem			
			 ,@remarks ;

		while @@fetch_status = 0
		begin

			/* insert into table report */
			insert into rpt_nilai_wajar_tanah_bangunan_list_summary
			(
				user_id										
				,lokasi
				,alamat
				,status_kepemilikan
				,nama_pemegang_hak
				,nomor_sertifikat
				,tanggal_sertifikat
				,jangka_waktu_awal_kepemilikan
				,jangka_waktu_berakhir_kepemilikan
				,nomor_hak_tanggungan
				,tanggal_tanggungan
				,nama_yang_berhak
				,tanggal_roya
				,tahun_pbb
				,objek_pajak
				,luas
				,kelas
				,njop
				,total_njop
				,nilai_pbb_terutang
				,nilai_pbb_yang_harus_dibayar
				,tanggal_jatuh_tempo_pbb
				,tanggal_bayar_pbb
				,nomor_appraisal
				,tanggal_appraisal
				,kjpp
				,nilai_appraisal
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			values
			(	''
				,@location
				,''
				,''
				,''
				,''
				,null
				,null
				,null
				,''
				,null
				,''
				,''
				,0
				,''
				,0
				,0
				,0
				,0
				,0
				,0
				,null
				,''
				,''
				,null
				,''
				,0
				--
				,''
				,''
				,''
				,''
				,''
				,''
			) ;

			/* fetch record berikutnya */
			fetch c_asset_list
			into @code_office_name
				--,@initial_office_name		
			 ,@office_full_name
			 ,@location
			 ,@cost_center
			 ,@category_code
			 ,@category_name
			 ,@asset_type
			 ,@purchase_date
				--,@purchase_order_no			
			 ,@barcode
				--,@old_barcode				
			 ,@item_group
			 ,@item_name
			 ,@merk
			 ,@type
			 ,@model
			 ,@serial_number
			 ,@nomor_rangka
			 ,@nomor_mesin
			 ,@nomor_polisi
			 ,@manufacturing_years
				--,@object_info				
				--,@nik						
				--,@name						
			 ,@division
			 ,@department
				--,@position					
				--,@supplier					
			 ,@original_price
				--,@fa_adjustment_amount		
			 ,@purchase_price
			 ,@start_depre_commercial
			 ,@total_depre_commercial
			 ,@net_book_value_commercial
			 ,@start_depre_fiscal
			 ,@total_depre_fiscal
			 ,@net_book_value_fiscal
			 ,@last_so_date
			 ,@last_so_condition
			 ,@status_asset
			 ,@location_from
				--,@tanggal_depre				
				--,@depre_or_non_depre		
				--,@status_in_sistem			
			 ,@remarks ;
		end ;

		/* tutup cursor */
		close c_asset_list ;
		deallocate c_asset_list ;

		select	lokasi																													'Lokasi'
				,alamat																													'Alamat'
				,status_kepemilikan																										'Status Kepemilikan'
				,nama_pemegang_hak																										'Nama Pemegan HAK'
				,nomor_sertifikat																										'Nomor Sertifikat'
				,tanggal_sertifikat																										'Tanggal Sertifikat'
				,jangka_waktu_awal_kepemilikan																							'Jangka Waktu Awal Kepemilikan'
				,jangka_waktu_berakhir_kepemilikan																						'Jangka Waktu Berakhir Kepemilikan'
				,nomor_hak_tanggungan																									'Nomor HAK Tanggungan'
				,tanggal_tanggungan																										'Tanggal Tanggungan'
				,nama_yang_berhak																										'Nama Yang Berhak'
				,tanggal_roya																											'Tanggal Roya'
				,tahun_pbb																												'Tahun PBB'
				,objek_pajak																											'Objek Pajak'
				,luas																													'Luas'
				,kelas																													'Kelas'
				,njop																													'NJOP'
				,total_njop																												'Total NJOP'
				,nilai_pbb_terutang																										'Nilai PBB Terutang'
				,nilai_pbb_yang_harus_dibayar																							'Nilai PBB Yang Harus Dibayar'
				,tanggal_jatuh_tempo_pbb																								'Tanggal Jatuh Tempo PBB'
				,tanggal_bayar_pbb																										'Tanggal Bayar PBB'
				,nomor_appraisal																										'Nomor Aprraisal'
				,tanggal_appraisal																										'Tanggal appraisal'
				,kjpp																													'KJPP'
				,nilai_appraisal																										'Nilai Appraisal'
				--
				,case @p_date_type	when 'RANGE' then 'Range' else 	'Cut Off' end														'Date Type'				
				,case @p_report_type  when 'SUMMARY' then 'Summary' else 'Detail' end													'Report Type'
				,@p_from_date																											'From Date'				
				,@p_to_date																												'To Date'				
				,case @p_area_code when '' then 'ALL' else @p_area_code end																'HO/BU/Cabang'
				,case @p_branch_code when '' then 'ALL'	else @p_branch_code end															'Office Name'						
				,case @p_category_code when '' then 'ALL' else @p_category_code end														'Category'
				,case @p_item_group_code when '' then 'ALL' else @p_item_group_code end													'Item Group'
				,case @p_net_book_value_commercial when 'ZERO' then 'Nol' when 'MORE' then 'Lebih Dari Nol' else 'ALL'	end				'Nilai Buku'
				,case @p_net_book_value_fiscal when 'MORE' then 'Lebih Dari Sama Dengan' when 'LESS' then 'Kurang Dari' else 'ALL' end	'Threshold'
		from	dbo.rpt_nilai_wajar_tanah_bangunan_list_summary
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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
