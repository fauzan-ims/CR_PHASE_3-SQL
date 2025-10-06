CREATE PROCEDURE [dbo].[xsp_application_main_slik_getrow]
(
	@p_application_no nvarchar(50)
)
as
begin
	select	application_no
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
	from	application_main_slik ams
	where	application_no = @p_application_no ;
end ;

