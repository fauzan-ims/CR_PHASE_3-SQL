CREATE PROCEDURE [dbo].[xsp_application_main_sipp_getrow]
(
	@p_application_no nvarchar(50)
)
as
begin
	select	application_no
			,sipp_tujuan_pembiayaan_code
			,sipp_tujuan_pembiayaan_ojk_code						
			,sipp_tujuan_pembiayaan_name							
			,sipp_skema_pembiayaan_code								
			,sipp_skema_pembiayaan_ojk_code							
			,sipp_skema_pembiayaan_name						
			,sipp_jenis_barang_atau_jasa_code						
			,sipp_jenis_barang_atau_jasa_ojk_code					
			,sipp_jenis_barang_atau_jasa_name					
			,sipp_jenis_suku_bunga_code								
			,sipp_jenis_suku_bunga_ojk_code							
			,sipp_jenis_suku_bunga_name						
			,sipp_mata_uang_code									
			,sipp_mata_uang_ojk_code								
			,sipp_mata_uang_name								
			,sipp_lokasi_project_code								
			,sipp_lokasi_project_ojk_code							
			,sipp_lokasi_project_name							
			,sipp_kategori_usaha_keuangan_berkelanjutan_code		   
			,sipp_kategori_usaha_keuangan_berkelanjutan_ojk_code	   
			,sipp_kategori_usaha_keuangan_berkelanjutan_name		   
			,sipp_kategori_piutang_code								
			,sipp_kategori_piutang_ojk_code							
			,sipp_kategori_piutang_name							
			,sipp_metode_cadangan_kerugian_penurunan_nilai_code		 
			,sipp_metode_cadangan_kerugian_penurunan_nilai_ojk_code  
			,sipp_metode_cadangan_kerugian_penurunan_nilai_name
	from	application_main_sipp ams
	where	application_no = @p_application_no ;
end ;


