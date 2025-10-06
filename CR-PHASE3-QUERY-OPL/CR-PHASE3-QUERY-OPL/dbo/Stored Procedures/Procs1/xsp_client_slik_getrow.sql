CREATE PROCEDURE [dbo].[xsp_client_slik_getrow]
(
	@p_client_code nvarchar(50)
)
as
begin
	select	client_code
			,slik_status_pendidikan_code
			,slik_bid_ush_tmpt_kerja_code
			,slik_pekerjaan_code
			,slik_pnghslan_per_thn_amount
			,slik_sumber_penghasilan_code
			,slik_hub_pelapor_code
			,slik_golongan_debitur_code
			,slik_perj_pisah_harta
			,slik_mlnggar_bts_maks_krdit
			,slik_mlmpui_bts_maks_krdit
			,slik_is_go_public
			,slik_lemb_pemeringkat_debitur_code
			,slik_tgl_pemeringkatan
			,slik_rating_debitur
			,slik_dati_ii_code
			,cs.slik_status_pendidikan_ojk_code
			,cs.slik_bid_ush_tmpt_kerja_ojk_code
			,cs.slik_pekerjaan_ojk_code
			,cs.slik_sumber_penghasilan_ojk_code
			,cs.slik_hub_pelapor_ojk_code
			,cs.slik_golongan_debitur_ojk_code
			,cs.slik_lemb_pemeringkat_debitur_ojk_code
			,cs.slik_dati_ii_ojk_code
			,cs.slik_status_pendidikan_name 			  
			,cs.slik_bid_ush_tmpt_kerja_name			  
			,cs.slik_pekerjaan_name						  
			,cs.slik_sumber_penghasilan_name			  
			,cs.slik_hub_pelapor_name					  
			,cs.slik_golongan_debitur_name				  
			,cs.slik_lemb_pemeringkat_debitur_name		  
			,cs.slik_dati_ii_name						  
			,cm.client_type
	from	client_slik cs
			inner join dbo.client_main cm on (cm.code = cs.client_code)
	where	client_code = @p_client_code ;
end ;

