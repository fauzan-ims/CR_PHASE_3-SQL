CREATE PROCEDURE dbo.xsp_application_main_slik_insert
(
	@p_application_no									nvarchar(50)  = null
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
	,@p_cre_date										datetime
	,@p_cre_by											nvarchar(15)
	,@p_cre_ip_address									nvarchar(15)
	,@p_mod_date										datetime
	,@p_mod_by											nvarchar(15)
	,@p_mod_ip_address									nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into application_main_slik
		(
			application_no
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
			,@p_slik_sifat_kredit_code
			,@p_slik_sifat_kredit_ojk_code							
			,@p_slik_sifat_kredit_name								
			,@p_slik_jenis_kredit_code								
			,@p_slik_jenis_kredit_ojk_code							
			,@p_slik_jenis_kredit_name								
			,@p_slik_skim_akad_pembiayaan_code						
			,@p_slik_skim_akad_pembiayaan_ojk_code					
			,@p_slik_skim_akad_pembiayaan_name						
			,@p_slik_kategori_debitur_code							
			,@p_slik_kategori_debitur_ojk_code						
			,@p_slik_kategori_debitur_name							
			,@p_slik_jenis_penggunaan_code							
			,@p_slik_jenis_penggunaan_ojk_code						
			,@p_slik_jenis_penggunaan_name							
			,@p_slik_orientasi_penggunaan_code						
			,@p_slik_orientasi_penggunaan_ojk_code					
			,@p_slik_orientasi_penggunaan_name						
			,@p_slik_sektor_ekonomi_code							
			,@p_slik_sektor_ekonomi_ojk_code						
			,@p_slik_sektor_ekonomi_name							
			,@p_slik_jenis_bunga_code								
			,@p_slik_jenis_bunga_ojk_code							
			,@p_slik_jenis_bunga_name								
			,@p_slik_kredit_pembiayaan_prog_pemerintah_code		
			,@p_slik_kredit_pembiayaan_prog_pemerintah_ojk_code	
			,@p_slik_kredit_pembiayaan_prog_pemerintah_name		
			,@p_slik_take_over_dari_code							
			,@p_slik_take_over_dari_ojk_code						
			,@p_slik_take_over_dari_name							
			,@p_slik_sumber_dana_code								
			,@p_slik_sumber_dana_ojk_code							
			,@p_slik_sumber_dana_name								
			,@p_slik_cara_restrukturasi_code						
			,@p_slik_cara_restrukturasi_ojk_code					
			,@p_slik_cara_restrukturasi_name						
			,@p_slik_kondisi_code									
			,@p_slik_kondisi_ojk_code								
			,@p_slik_kondisi_name									
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

