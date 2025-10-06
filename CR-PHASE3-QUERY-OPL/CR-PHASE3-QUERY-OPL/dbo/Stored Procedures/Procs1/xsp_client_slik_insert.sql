CREATE PROCEDURE [dbo].[xsp_client_slik_insert]
(
	@p_client_code								nvarchar(50)
	,@p_slik_status_pendidikan_code				nvarchar(50)	= null
	,@p_slik_bid_ush_tmpt_kerja_code			nvarchar(50)	= null
	,@p_slik_pekerjaan_code						nvarchar(50)	= null
	,@p_slik_status_pendidikan_ojk_code			nvarchar(50)	= null
	,@p_slik_bid_ush_tmpt_kerja_ojk_code		nvarchar(50)	= null
	,@p_slik_pekerjaan_ojk_code					nvarchar(50)	= null
	,@p_slik_status_pendidikan_name				nvarchar(250)	= null
	,@p_slik_bid_ush_tmpt_kerja_name			nvarchar(250)	= null
	,@p_slik_pekerjaan_name						nvarchar(250)	= null
	,@p_slik_pnghslan_per_thn_amount			decimal(18, 2)	= null
	,@p_slik_sumber_penghasilan_code			nvarchar(50)	= null
	,@p_slik_hub_pelapor_code					nvarchar(50)	= null
	,@p_slik_golongan_debitur_code				nvarchar(50)	= null
	,@p_slik_sumber_penghasilan_ojk_code		nvarchar(50)	= null
	,@p_slik_hub_pelapor_ojk_code				nvarchar(50)	= null
	,@p_slik_golongan_debitur_ojk_code			nvarchar(50)	= null
	,@p_slik_sumber_penghasilan_name			nvarchar(250)	= null
	,@p_slik_hub_pelapor_name					nvarchar(250)	= null
	,@p_slik_golongan_debitur_name				nvarchar(250)	= null
	,@p_slik_perj_pisah_harta					nvarchar(50)	= null
	,@p_slik_mlnggar_bts_maks_krdit				nvarchar(50)	= null
	,@p_slik_mlmpui_bts_maks_krdit				nvarchar(50)	= null
	,@p_slik_is_go_public						nvarchar(1)		= null
	,@p_slik_lemb_pemeringkat_debitur_code		nvarchar(50)	= null
	,@p_slik_lemb_pemeringkat_debitur_ojk_code	nvarchar(50)	= null
	,@p_slik_lemb_pemeringkat_debitur_name		nvarchar(250)	= null
	,@p_slik_tgl_pemeringkatan					datetime		= null
	,@p_slik_rating_debitur						int				= null
	,@p_slik_dati_ii_code						nvarchar(50)	= null
	,@p_slik_dati_ii_ojk_code					nvarchar(50)	= null
	,@p_slik_dati_ii_name						nvarchar(250)	= null
	--
	,@p_cre_date								datetime
	,@p_cre_by									nvarchar(15)
	,@p_cre_ip_address							nvarchar(15)
	,@p_mod_date								datetime
	,@p_mod_by									nvarchar(15)
	,@p_mod_ip_address							nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if (@p_slik_tgl_pemeringkatan > dbo.xfn_get_system_date())
		begin
			set @msg = 'Tanggal Pemeringkat must be less or equal than System Date';
			raiserror(@msg, 16, -1) ;
		end 

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
		(	@p_client_code
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
			,@p_slik_hub_pelapor_code
			,@p_slik_golongan_debitur_code
			,@p_slik_sumber_penghasilan_ojk_code
			,@p_slik_hub_pelapor_ojk_code
			,@p_slik_golongan_debitur_ojk_code
			,@p_slik_sumber_penghasilan_name
			,@p_slik_hub_pelapor_name
			,@p_slik_golongan_debitur_name
			,@p_slik_perj_pisah_harta
			,@p_slik_mlnggar_bts_maks_krdit
			,@p_slik_mlmpui_bts_maks_krdit
			,@p_slik_is_go_public
			,@p_slik_lemb_pemeringkat_debitur_code
			,@p_slik_lemb_pemeringkat_debitur_ojk_code
			,@p_slik_lemb_pemeringkat_debitur_name
			,@p_slik_tgl_pemeringkatan
			,@p_slik_rating_debitur
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
	end try
	begin catch
		declare  @error int
		set  @error = @@error
	 
		if ( @error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist();
		end ;
		else if ( @error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used();
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message();
		end ;

		raiserror(@msg, 16, -1) ;

		return ; 
	end catch ;
end ;


 

