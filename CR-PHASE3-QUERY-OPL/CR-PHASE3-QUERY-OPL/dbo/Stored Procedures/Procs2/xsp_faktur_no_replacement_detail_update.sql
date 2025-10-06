

CREATE PROCEDURE	dbo.xsp_faktur_no_replacement_detail_update
(
	 @p_id									bigint
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
	--                                
	,@p_mod_date							datetime
	,@p_mod_by								nvarchar(15)
	,@p_mod_ip_address						nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;
	begin try
		update	dbo.faktur_no_replacement_detail
		set		 npwp_pembeli_or_identitas_lainnya 	= @p_npwp_pembeli_or_identitas_lainnya 	
				,nama_pembeli                     	= @p_nama_pembeli                     	
				,kode_transaksi                   	= @p_kode_transaksi                   	
				,nomor_faktur_pajak               	= @p_nomor_faktur_pajak               	
				,tanggal_faktur_pajak             	= @p_tanggal_faktur_pajak             	
				,masa_or_pajak                    	= @p_masa_or_pajak                    	
				,tahun                            	= @p_tahun                            	
				,status_faktur                    	= @p_status_faktur                    	
				,harga_jual_or_penggantian_or_dpp 	= @p_harga_jual_or_penggantian_or_dpp 	
				,dpp_nilai_lain_or_dpp            	= @p_dpp_nilai_lain_or_dpp            	
				,ppn                              	= @p_ppn                              		
				,ppnbm                            	= @p_ppnbm                            	
				,penandatangan                    	= @p_penandatangan                    	
				,referensi                        	= @p_referensi                        	
				,dilaporkan_oleh_penjual          	= @p_dilaporkan_oleh_penjual          		
				,dilaporkan_oleh_pemungut_ppn     	= @p_dilaporkan_oleh_pemungut_ppn     	
				,faktur_no_before  					= @p_faktur_no_before  					
				--
				,mod_date							= @p_mod_date		
				,mod_by								= @p_mod_by			
				,mod_ip_address						= @p_mod_ip_address	
		where	 id									= @p_id ;
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
