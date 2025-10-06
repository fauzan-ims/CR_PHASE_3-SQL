

CREATE PROCEDURE dbo.xsp_faktur_no_replacement_detail_insert
(
	 @p_id									bigint		   = 0 output
	,@p_npwp_pembeli_or_identitas_lainnya 	 nvarchar (50)
	,@p_nama_pembeli                     	 nvarchar (50)
	,@p_kode_transaksi                   	 nvarchar (50)
	,@p_nomor_faktur_pajak               	 nvarchar (50)
	,@p_tanggal_faktur_pajak             	 datetime     
	,@p_masa_or_pajak                    	 nvarchar (50)     
	,@p_tahun                            	 nvarchar (50)     
	,@p_status_faktur                    	 nvarchar (50)
	,@p_harga_jual_or_penggantian_or_dpp 	 decimal (18,2)
	,@p_dpp_nilai_lain_or_dpp            	 decimal (18,2)
	,@p_ppn                              	 decimal (18,2)
	,@p_ppnbm                            	 decimal (18,2)          
	,@p_penandatangan                    	 nvarchar (50)
	,@p_referensi                        	 nvarchar (50)
	,@p_dilaporkan_oleh_penjual          	 nvarchar (50)
	,@p_dilaporkan_oleh_pemungut_ppn     	 nvarchar (50)
	,@p_faktur_no_before  					 nvarchar (50)
	,@p_faktur_no_replacement_code			 nvarchar(50)
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)

	begin try

		insert into faktur_no_replacement_detail
		(
			 id									
			,npwp_pembeli_or_identitas_lainnya 	
			,nama_pembeli                     	
			,kode_transaksi                   	
			,nomor_faktur_pajak               	
			,tanggal_faktur_pajak             	
			,masa_or_pajak                    	
			,tahun                            	
			,status_faktur                    	
			,harga_jual_or_penggantian_or_dpp 	
			,dpp_nilai_lain_or_dpp            	
			,ppn                              	
			,ppnbm                            	
			,penandatangan                    	
			,referensi                        	
			,dilaporkan_oleh_penjual          	
			,dilaporkan_oleh_pemungut_ppn     	
			,faktur_no_before 
			,faktur_no_replacement_code 					
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
			 @p_id									
			,@p_npwp_pembeli_or_identitas_lainnya 	
			,@p_nama_pembeli                     	
			,@p_kode_transaksi                   	
			,@p_nomor_faktur_pajak               	
			,@p_tanggal_faktur_pajak             	
			,@p_masa_or_pajak                    	
			,@p_tahun                            	
			,@p_status_faktur                    	
			,@p_harga_jual_or_penggantian_or_dpp 	
			,@p_dpp_nilai_lain_or_dpp            	
			,@p_ppn                              	
			,@p_ppnbm                            	
			,@p_penandatangan                    	
			,@p_referensi                        	
			,@p_dilaporkan_oleh_penjual          	
			,@p_dilaporkan_oleh_pemungut_ppn     	
			,@p_faktur_no_before  
			,@p_faktur_no_replacement_code					
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;





