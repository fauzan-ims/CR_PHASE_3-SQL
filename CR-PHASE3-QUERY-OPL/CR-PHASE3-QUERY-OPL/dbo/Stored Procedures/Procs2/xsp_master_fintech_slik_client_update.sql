CREATE PROCEDURE dbo.xsp_master_fintech_slik_client_update
(
	@p_fintech_code						 nvarchar(50)
	,@p_slik_status_pendidikan_code		 nvarchar(50)   = null
	,@p_slik_status_pendidikan_ojk_code	 nvarchar(50)   = null
	,@p_slik_status_pendidikan_name		 nvarchar(250)  = null
	,@p_slik_bid_ush_tmpt_kerja_code	 nvarchar(50)   = null
	,@p_slik_bid_ush_tmpt_kerja_ojk_code nvarchar(50)   = null
	,@p_slik_bid_ush_tmpt_kerja_name	 nvarchar(250)  = null
	,@p_slik_pekerjaan_code				 nvarchar(50)   = null
	,@p_slik_pekerjaan_ojk_code			 nvarchar(50)   = null
	,@p_slik_pekerjaan_name				 nvarchar(250)  = null
	,@p_slik_pnghslan_per_thn_amount	 decimal(18, 2)
	,@p_slik_sumber_penghasilan_code	 nvarchar(50)   = null
	,@p_slik_sumber_penghasilan_ojk_code nvarchar(50)   = null
	,@p_slik_sumber_penghasilan_name	 nvarchar(250)  = null
	,@p_slik_hub_pelapor_code			 nvarchar(50)   = null
	,@p_slik_hub_pelapor_ojk_code		 nvarchar(50)   = null
	,@p_slik_hub_pelapor_name			 nvarchar(250)  = null
	,@p_slik_golongan_debitur_code		 nvarchar(50)   = null
	,@p_slik_golongan_debitur_ojk_code	 nvarchar(50)   = null
	,@p_slik_golongan_debitur_name		 nvarchar(250)  = null
	,@p_slik_perj_pisah_harta			 nvarchar(50)   = null
	,@p_slik_mlnggar_bts_maks_krdit		 nvarchar(50)   = null
	,@p_slik_mlmpui_bts_maks_krdit		 nvarchar(50)   = null
	,@p_slik_dati_ii_code				 nvarchar(50)   = null
	,@p_slik_dati_ii_ojk_code			 nvarchar(50)   = null
	,@p_slik_dati_ii_name				 nvarchar(250)  = null
	--
	,@p_slik_sifat_kredit_code							nvarchar(50)  = null
	,@p_slik_sifat_kredit_ojk_code						nvarchar(50)  = null
	,@p_slik_sifat_kredit_name							nvarchar(250) = null
	,@p_slik_jenis_kredit_code							nvarchar(50)  = null
	,@p_slik_jenis_kredit_ojk_code						nvarchar(50)  = null
	,@p_slik_jenis_kredit_name							nvarchar(250) = null
	,@p_slik_skim_akad_pembiayaan_code					nvarchar(50)  = null
	,@p_slik_skim_akad_pembiayaan_ojk_code				nvarchar(50)  = null
	,@p_slik_skim_akad_pembiayaan_name					nvarchar(250) = null
	,@p_slik_kategori_debitur_code						nvarchar(50)  = null
	,@p_slik_kategori_debitur_ojk_code					nvarchar(50)  = null
	,@p_slik_kategori_debitur_name						nvarchar(250) = null
	,@p_slik_jenis_penggunaan_code						nvarchar(50)  = null
	,@p_slik_jenis_penggunaan_ojk_code					nvarchar(50)  = null
	,@p_slik_jenis_penggunaan_name						nvarchar(250) = null
	,@p_slik_orientasi_penggunaan_code					nvarchar(50)  = null
	,@p_slik_orientasi_penggunaan_ojk_code				nvarchar(50)  = null
	,@p_slik_orientasi_penggunaan_name					nvarchar(250) = null
	,@p_slik_sektor_ekonomi_code						nvarchar(50)  = null
	,@p_slik_sektor_ekonomi_ojk_code					nvarchar(50)  = null
	,@p_slik_sektor_ekonomi_name						nvarchar(250) = null
	,@p_slik_jenis_bunga_code							nvarchar(50)  = null
	,@p_slik_jenis_bunga_ojk_code						nvarchar(50)  = null
	,@p_slik_jenis_bunga_name							nvarchar(250) = null
	,@p_slik_kredit_pembiayaan_prog_pemerintah_code		nvarchar(50)  = null
	,@p_slik_kredit_pembiayaan_prog_pemerintah_ojk_code nvarchar(50)  = null
	,@p_slik_kredit_pembiayaan_prog_pemerintah_name		nvarchar(250) = null
	,@p_slik_take_over_dari_code						nvarchar(50)  = null
	,@p_slik_take_over_dari_ojk_code					nvarchar(50)  = null
	,@p_slik_take_over_dari_name						nvarchar(250) = null
	,@p_slik_sumber_dana_code							nvarchar(50)  = null
	,@p_slik_sumber_dana_ojk_code						nvarchar(50)  = null
	,@p_slik_sumber_dana_name							nvarchar(250) = null
	,@p_slik_cara_restrukturasi_code					nvarchar(50)  = null
	,@p_slik_cara_restrukturasi_ojk_code				nvarchar(50)  = null
	,@p_slik_cara_restrukturasi_name					nvarchar(250) = null
	,@p_slik_kondisi_code								nvarchar(50)  = null
	,@p_slik_kondisi_ojk_code							nvarchar(50)  = null
	,@p_slik_kondisi_name								nvarchar(250) = null
	--
	,@p_sipp_kelompok_debtor_code			nvarchar(50)  = null
	,@p_sipp_kelompok_debtor_ojk_code		nvarchar(50)  = null
	,@p_sipp_kelompok_debtor_name			nvarchar(250) = null
	,@p_sipp_kategori_debtor_code			nvarchar(50)  = null
	,@p_sipp_kategori_debtor_ojk_code		nvarchar(50)  = null
	,@p_sipp_kategori_debtor_name			nvarchar(250) = null
	,@p_sipp_golongan_debtor_code			nvarchar(50)  = null
	,@p_sipp_golongan_debtor_ojk_code		nvarchar(50)  = null
	,@p_sipp_golongan_debtor_name			nvarchar(250) = null
	,@p_sipp_hub_debtor_dg_pp_code			nvarchar(50)  = null
	,@p_sipp_hub_debtor_dg_pp_ojk_code		nvarchar(50)  = null
	,@p_sipp_hub_debtor_dg_pp_name			nvarchar(250) = null
	,@p_sipp_sektor_ekonomi_debtor_code		nvarchar(50)  = null
	,@p_sipp_sektor_ekonomi_debtor_ojk_code nvarchar(50)  = null
	,@p_sipp_sektor_ekonomi_debtor_name		nvarchar(250) = null
	--
	,@p_sipp_jenis_pembiayaan_code							   nvarchar(50)	 = null
	,@p_sipp_jenis_pembiayaan_ojk_code						   nvarchar(50)	 = null
	,@p_sipp_jenis_pembiayaan_name							   nvarchar(250) = null
	,@p_sipp_skema_pembiayaan_code							   nvarchar(50)	 = null
	,@p_sipp_skema_pembiayaan_ojk_code						   nvarchar(50)	 = null
	,@p_sipp_skema_pembiayaan_name							   nvarchar(250) = null
	,@p_sipp_tujuan_pembiayaan_code							   nvarchar(50)	 = null
	,@p_sipp_tujuan_pembiayaan_ojk_code						   nvarchar(50)	 = null
	,@p_sipp_tujuan_pembiayaan_name							   nvarchar(250) = null
	,@p_sipp_jenis_barang_atau_jasa_code					   nvarchar(50)	 = null
	,@p_sipp_jenis_barang_atau_jasa_ojk_code				   nvarchar(50)	 = null
	,@p_sipp_jenis_barang_atau_jasa_name					   nvarchar(250) = null
	,@p_sipp_jenis_suku_bunga_code							   nvarchar(50)	 = null
	,@p_sipp_jenis_suku_bunga_ojk_code						   nvarchar(50)	 = null
	,@p_sipp_jenis_suku_bunga_name							   nvarchar(250) = null
	,@p_sipp_mata_uang_code									   nvarchar(50)	 = null
	,@p_sipp_mata_uang_ojk_code								   nvarchar(50)	 = null
	,@p_sipp_mata_uang_name									   nvarchar(250) = null
	,@p_sipp_lokasi_project_code							   nvarchar(50)	 = null
	,@p_sipp_lokasi_project_ojk_code						   nvarchar(50)	 = null
	,@p_sipp_lokasi_project_name							   nvarchar(250) = null
	,@p_sipp_kategori_usaha_keuangan_berkelanjutan_code		   nvarchar(50)	 = null
	,@p_sipp_kategori_usaha_keuangan_berkelanjutan_ojk_code	   nvarchar(50)	 = null
	,@p_sipp_kategori_usaha_keuangan_berkelanjutan_name		   nvarchar(250) = null
	,@p_sipp_kategori_piutang_code							   nvarchar(50)	 = null
	,@p_sipp_kategori_piutang_ojk_code						   nvarchar(50)	 = null
	,@p_sipp_kategori_piutang_name							   nvarchar(250) = null
	,@p_sipp_metode_cadangan_kerugian_penurunan_nilai_code	   nvarchar(50)	 = null
	,@p_sipp_metode_cadangan_kerugian_penurunan_nilai_ojk_code nvarchar(50)	 = null
	,@p_sipp_metode_cadangan_kerugian_penurunan_nilai_name	   nvarchar(250) = null
	--
	,@p_mod_date						 datetime
	,@p_mod_by							 nvarchar(50)
	,@p_mod_ip_address					 nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	master_fintech_slik_client
		set		slik_status_pendidikan_code			= @p_slik_status_pendidikan_code
				,slik_status_pendidikan_ojk_code	= @p_slik_status_pendidikan_ojk_code
				,slik_status_pendidikan_name		= @p_slik_status_pendidikan_name
				,slik_bid_ush_tmpt_kerja_code		= @p_slik_bid_ush_tmpt_kerja_code
				,slik_bid_ush_tmpt_kerja_ojk_code	= @p_slik_bid_ush_tmpt_kerja_ojk_code
				,slik_bid_ush_tmpt_kerja_name		= @p_slik_bid_ush_tmpt_kerja_name
				,slik_pekerjaan_code				= @p_slik_pekerjaan_code
				,slik_pekerjaan_ojk_code			= @p_slik_pekerjaan_ojk_code
				,slik_pekerjaan_name				= @p_slik_pekerjaan_name
				,slik_pnghslan_per_thn_amount		= @p_slik_pnghslan_per_thn_amount
				,slik_sumber_penghasilan_code		= @p_slik_sumber_penghasilan_code
				,slik_sumber_penghasilan_ojk_code	= @p_slik_sumber_penghasilan_ojk_code
				,slik_sumber_penghasilan_name		= @p_slik_sumber_penghasilan_name
				,slik_hub_pelapor_code				= @p_slik_hub_pelapor_code
				,slik_hub_pelapor_ojk_code			= @p_slik_hub_pelapor_ojk_code
				,slik_hub_pelapor_name				= @p_slik_hub_pelapor_name
				,slik_golongan_debitur_code			= @p_slik_golongan_debitur_code
				,slik_golongan_debitur_ojk_code		= @p_slik_golongan_debitur_ojk_code
				,slik_golongan_debitur_name			= @p_slik_golongan_debitur_name
				,slik_perj_pisah_harta				= @p_slik_perj_pisah_harta
				,slik_mlnggar_bts_maks_krdit		= @p_slik_mlnggar_bts_maks_krdit
				,slik_mlmpui_bts_maks_krdit			= @p_slik_mlmpui_bts_maks_krdit
				,slik_dati_ii_code					= @p_slik_dati_ii_code
				,slik_dati_ii_ojk_code				= @p_slik_dati_ii_ojk_code
				,slik_dati_ii_name					= @p_slik_dati_ii_name
				--
				,mod_date							= @p_mod_date
				,mod_by								= @p_mod_by
				,mod_ip_address						= @p_mod_ip_address
		where	fintech_code						= @p_fintech_code ;

		update	master_fintech_slik_contract
		set		slik_sifat_kredit_code								= @p_slik_sifat_kredit_code
				,slik_sifat_kredit_ojk_code							= @p_slik_sifat_kredit_ojk_code
				,slik_sifat_kredit_name								= @p_slik_sifat_kredit_name
				,slik_jenis_kredit_code								= @p_slik_jenis_kredit_code
				,slik_jenis_kredit_ojk_code							= @p_slik_jenis_kredit_ojk_code
				,slik_jenis_kredit_name								= @p_slik_jenis_kredit_name
				,slik_skim_akad_pembiayaan_code						= @p_slik_skim_akad_pembiayaan_code
				,slik_skim_akad_pembiayaan_ojk_code					= @p_slik_skim_akad_pembiayaan_ojk_code
				,slik_skim_akad_pembiayaan_name						= @p_slik_skim_akad_pembiayaan_name
				,slik_kategori_debitur_code							= @p_slik_kategori_debitur_code
				,slik_kategori_debitur_ojk_code						= @p_slik_kategori_debitur_ojk_code
				,slik_kategori_debitur_name							= @p_slik_kategori_debitur_name
				,slik_jenis_penggunaan_code							= @p_slik_jenis_penggunaan_code
				,slik_jenis_penggunaan_ojk_code						= @p_slik_jenis_penggunaan_ojk_code
				,slik_jenis_penggunaan_name							= @p_slik_jenis_penggunaan_name
				,slik_orientasi_penggunaan_code						= @p_slik_orientasi_penggunaan_code
				,slik_orientasi_penggunaan_ojk_code					= @p_slik_orientasi_penggunaan_ojk_code
				,slik_orientasi_penggunaan_name						= @p_slik_orientasi_penggunaan_name
				,slik_sektor_ekonomi_code							= @p_slik_sektor_ekonomi_code
				,slik_sektor_ekonomi_ojk_code						= @p_slik_sektor_ekonomi_ojk_code
				,slik_sektor_ekonomi_name							= @p_slik_sektor_ekonomi_name
				,slik_jenis_bunga_code								= @p_slik_jenis_bunga_code
				,slik_jenis_bunga_ojk_code							= @p_slik_jenis_bunga_ojk_code
				,slik_jenis_bunga_name								= @p_slik_jenis_bunga_name
				,slik_kredit_pembiayaan_prog_pemerintah_code		= @p_slik_kredit_pembiayaan_prog_pemerintah_code
				,slik_kredit_pembiayaan_prog_pemerintah_ojk_code	= @p_slik_kredit_pembiayaan_prog_pemerintah_ojk_code
				,slik_kredit_pembiayaan_prog_pemerintah_name		= @p_slik_kredit_pembiayaan_prog_pemerintah_name
				,slik_take_over_dari_code							= @p_slik_take_over_dari_code
				,slik_take_over_dari_ojk_code						= @p_slik_take_over_dari_ojk_code
				,slik_take_over_dari_name							= @p_slik_take_over_dari_name
				,slik_sumber_dana_code								= @p_slik_sumber_dana_code
				,slik_sumber_dana_ojk_code							= @p_slik_sumber_dana_ojk_code
				,slik_sumber_dana_name								= @p_slik_sumber_dana_name
				,slik_cara_restrukturasi_code						= @p_slik_cara_restrukturasi_code
				,slik_cara_restrukturasi_ojk_code					= @p_slik_cara_restrukturasi_ojk_code
				,slik_cara_restrukturasi_name						= @p_slik_cara_restrukturasi_name
				,slik_kondisi_code									= @p_slik_kondisi_code
				,slik_kondisi_ojk_code								= @p_slik_kondisi_ojk_code
				,slik_kondisi_name									= @p_slik_kondisi_name
				--
				,mod_date											= @p_mod_date
				,mod_by												= @p_mod_by
				,mod_ip_address										= @p_mod_ip_address
		where	fintech_code										= @p_fintech_code ;

		update	master_fintech_silaras_client
		set		sipp_kelompok_debtor_code				= @p_sipp_kelompok_debtor_code
				,sipp_kelompok_debtor_ojk_code			= @p_sipp_kelompok_debtor_ojk_code
				,sipp_kelompok_debtor_name				= @p_sipp_kelompok_debtor_name
				,sipp_kategori_debtor_code				= @p_sipp_kategori_debtor_code
				,sipp_kategori_debtor_ojk_code			= @p_sipp_kategori_debtor_ojk_code
				,sipp_kategori_debtor_name				= @p_sipp_kategori_debtor_name
				,sipp_golongan_debtor_code				= @p_sipp_golongan_debtor_code
				,sipp_golongan_debtor_ojk_code			= @p_sipp_golongan_debtor_ojk_code
				,sipp_golongan_debtor_name				= @p_sipp_golongan_debtor_name
				,sipp_hub_debtor_dg_pp_code				= @p_sipp_hub_debtor_dg_pp_code
				,sipp_hub_debtor_dg_pp_ojk_code			= @p_sipp_hub_debtor_dg_pp_ojk_code
				,sipp_hub_debtor_dg_pp_name				= @p_sipp_hub_debtor_dg_pp_name
				,sipp_sektor_ekonomi_debtor_code		= @p_sipp_sektor_ekonomi_debtor_code
				,sipp_sektor_ekonomi_debtor_ojk_code	= @p_sipp_sektor_ekonomi_debtor_ojk_code
				,sipp_sektor_ekonomi_debtor_name		= @p_sipp_sektor_ekonomi_debtor_name
				--
				,mod_date								= @p_mod_date
				,mod_by									= @p_mod_by
				,mod_ip_address							= @p_mod_ip_address
		where	fintech_code							= @p_fintech_code ;

		update	master_fintech_silaras_contract
		set		sipp_jenis_pembiayaan_code								= @p_sipp_jenis_pembiayaan_code
				,sipp_jenis_pembiayaan_ojk_code							= @p_sipp_jenis_pembiayaan_ojk_code
				,sipp_jenis_pembiayaan_name								= @p_sipp_jenis_pembiayaan_name
				,sipp_skema_pembiayaan_code								= @p_sipp_skema_pembiayaan_code
				,sipp_skema_pembiayaan_ojk_code							= @p_sipp_skema_pembiayaan_ojk_code
				,sipp_skema_pembiayaan_name								= @p_sipp_skema_pembiayaan_name
				,sipp_tujuan_pembiayaan_code							= @p_sipp_tujuan_pembiayaan_code
				,sipp_tujuan_pembiayaan_ojk_code						= @p_sipp_tujuan_pembiayaan_ojk_code
				,sipp_tujuan_pembiayaan_name							= @p_sipp_tujuan_pembiayaan_name
				,sipp_jenis_barang_atau_jasa_code						= @p_sipp_jenis_barang_atau_jasa_code
				,sipp_jenis_barang_atau_jasa_ojk_code					= @p_sipp_jenis_barang_atau_jasa_ojk_code
				,sipp_jenis_barang_atau_jasa_name						= @p_sipp_jenis_barang_atau_jasa_name
				,sipp_jenis_suku_bunga_code								= @p_sipp_jenis_suku_bunga_code
				,sipp_jenis_suku_bunga_ojk_code							= @p_sipp_jenis_suku_bunga_ojk_code
				,sipp_jenis_suku_bunga_name								= @p_sipp_jenis_suku_bunga_name
				,sipp_mata_uang_code									= @p_sipp_mata_uang_code
				,sipp_mata_uang_ojk_code								= @p_sipp_mata_uang_ojk_code
				,sipp_mata_uang_name									= @p_sipp_mata_uang_name
				,sipp_lokasi_project_code								= @p_sipp_lokasi_project_code
				,sipp_lokasi_project_ojk_code							= @p_sipp_lokasi_project_ojk_code
				,sipp_lokasi_project_name								= @p_sipp_lokasi_project_name
				,sipp_kategori_usaha_keuangan_berkelanjutan_code		= @p_sipp_kategori_usaha_keuangan_berkelanjutan_code
				,sipp_kategori_usaha_keuangan_berkelanjutan_ojk_code	= @p_sipp_kategori_usaha_keuangan_berkelanjutan_ojk_code
				,sipp_kategori_usaha_keuangan_berkelanjutan_name		= @p_sipp_kategori_usaha_keuangan_berkelanjutan_name
				,sipp_kategori_piutang_code								= @p_sipp_kategori_piutang_code
				,sipp_kategori_piutang_ojk_code							= @p_sipp_kategori_piutang_ojk_code
				,sipp_kategori_piutang_name								= @p_sipp_kategori_piutang_name
				,sipp_metode_cadangan_kerugian_penurunan_nilai_code		= @p_sipp_metode_cadangan_kerugian_penurunan_nilai_code
				,sipp_metode_cadangan_kerugian_penurunan_nilai_ojk_code	= @p_sipp_metode_cadangan_kerugian_penurunan_nilai_ojk_code
				,sipp_metode_cadangan_kerugian_penurunan_nilai_name		= @p_sipp_metode_cadangan_kerugian_penurunan_nilai_name
				--
				,mod_date												= @p_mod_date
				,mod_by													= @p_mod_by
				,mod_ip_address											= @p_mod_ip_address
		where	fintech_code											= @p_fintech_code ;
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

