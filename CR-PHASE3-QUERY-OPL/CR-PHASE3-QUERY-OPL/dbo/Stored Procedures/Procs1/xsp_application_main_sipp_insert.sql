CREATE PROCEDURE dbo.xsp_application_main_sipp_insert
(
	@p_application_no											nvarchar(50) = null
	,@p_sipp_tujuan_pembiayaan_code								nvarchar(50) =  null
	,@p_sipp_tujuan_pembiayaan_ojk_code							nvarchar(50) =  null
	,@p_sipp_tujuan_pembiayaan_name								nvarchar(250) =  null
	,@p_sipp_skema_pembiayaan_code								nvarchar(50) =  null
	,@p_sipp_skema_pembiayaan_ojk_code							nvarchar(50) =  null
	,@p_sipp_skema_pembiayaan_name								nvarchar(250) =  null
	,@p_sipp_jenis_barang_atau_jasa_code						nvarchar(50) =  null
	,@p_sipp_jenis_barang_atau_jasa_ojk_code					nvarchar(50) =  null
	,@p_sipp_jenis_barang_atau_jasa_name						nvarchar(250) =  null
	,@p_sipp_jenis_suku_bunga_code								nvarchar(50) =  null
	,@p_sipp_jenis_suku_bunga_ojk_code							nvarchar(50) =  null
	,@p_sipp_jenis_suku_bunga_name								nvarchar(250) =  null
	,@p_sipp_mata_uang_code										nvarchar(50) =  null
	,@p_sipp_mata_uang_ojk_code									nvarchar(50) =  null
	,@p_sipp_mata_uang_name										nvarchar(250) =  null
	,@p_sipp_lokasi_project_code								nvarchar(50) =  null
	,@p_sipp_lokasi_project_ojk_code							nvarchar(50) =  null
	,@p_sipp_lokasi_project_name								nvarchar(250) =  null
	,@p_sipp_kategori_usaha_keuangan_berkelanjutan_code			nvarchar(50) =  null
	,@p_sipp_kategori_usaha_keuangan_berkelanjutan_ojk_code	    nvarchar(50) =  null
	,@p_sipp_kategori_usaha_keuangan_berkelanjutan_name			nvarchar(250) =  null
	,@p_sipp_kategori_piutang_code								nvarchar(50) =  null
	,@p_sipp_kategori_piutang_ojk_code						    nvarchar(50) =  null
	,@p_sipp_kategori_piutang_name								nvarchar(250) =  null
	,@p_sipp_metode_cadangan_kerugian_penurunan_nilai_code		nvarchar(50) =  null
	,@p_sipp_metode_cadangan_kerugian_penurunan_nilai_ojk_code  nvarchar(50) =  null
	,@p_sipp_metode_cadangan_kerugian_penurunan_nilai_name		nvarchar(250) =  null
	--
	,@p_cre_date												datetime
	,@p_cre_by													nvarchar(15)
	,@p_cre_ip_address											nvarchar(15)
	,@p_mod_date												datetime
	,@p_mod_by													nvarchar(15)
	,@p_mod_ip_address											nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into application_main_sipp
		(
			application_no
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
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_application_no
			,@p_sipp_tujuan_pembiayaan_code
			,@p_sipp_tujuan_pembiayaan_ojk_code						
			,@p_sipp_tujuan_pembiayaan_name							
			,@p_sipp_skema_pembiayaan_code								
			,@p_sipp_skema_pembiayaan_ojk_code							
			,@p_sipp_skema_pembiayaan_name								
			,@p_sipp_jenis_barang_atau_jasa_code						
			,@p_sipp_jenis_barang_atau_jasa_ojk_code					
			,@p_sipp_jenis_barang_atau_jasa_name						
			,@p_sipp_jenis_suku_bunga_code								
			,@p_sipp_jenis_suku_bunga_ojk_code							
			,@p_sipp_jenis_suku_bunga_name								
			,@p_sipp_mata_uang_code									
			,@p_sipp_mata_uang_ojk_code								
			,@p_sipp_mata_uang_name									
			,@p_sipp_lokasi_project_code								
			,@p_sipp_lokasi_project_ojk_code							
			,@p_sipp_lokasi_project_name								
			,@p_sipp_kategori_usaha_keuangan_berkelanjutan_code		   
			,@p_sipp_kategori_usaha_keuangan_berkelanjutan_ojk_code	   
			,@p_sipp_kategori_usaha_keuangan_berkelanjutan_name		   
			,@p_sipp_kategori_piutang_code								
			,@p_sipp_kategori_piutang_ojk_code							
			,@p_sipp_kategori_piutang_name								
			,@p_sipp_metode_cadangan_kerugian_penurunan_nilai_code		 
			,@p_sipp_metode_cadangan_kerugian_penurunan_nilai_ojk_code  
			,@p_sipp_metode_cadangan_kerugian_penurunan_nilai_name	
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

