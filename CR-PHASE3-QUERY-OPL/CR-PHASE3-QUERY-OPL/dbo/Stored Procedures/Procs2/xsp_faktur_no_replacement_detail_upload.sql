

CREATE PROCEDURE dbo.xsp_faktur_no_replacement_detail_upload
(
	 @p_faktur_no_replacement_code		nvarchar(50)
	,@p_cre_by							nvarchar(15)
	,@p_cre_date						datetime
	,@p_cre_ip_address					nvarchar(15)
    
)
as
begin
	
	declare @msg								nvarchar(max)
			,@remark_validation1				nvarchar(max) = ''
			,@remark_validation2				nvarchar(max) = ''
			,@remark_validation 				nvarchar(max) = ''
			,@id								bigint
			,@npwp_pembeli_or_identitas_lainnya nvarchar (50) 
			,@nama_pembeli                      nvarchar (50) 
			,@kode_transaksi                    nvarchar (50) 
			,@nomor_faktur_pajak                nvarchar (50) 
			,@tanggal_faktur_pajak              nvarchar (50)      
			,@masa_or_pajak                     nvarchar (50)      
			,@tahun                             nvarchar (50)      
			,@status_faktur                     nvarchar (50) 
			,@harga_jual_or_penggantian_or_dpp  nvarchar (50)
			,@dpp_nilai_lain_or_dpp             nvarchar (50)
			,@ppn                               nvarchar (50)
			,@ppnbm                             nvarchar (50)            
			,@penandatangan                     nvarchar (50) 
			,@referensi                         nvarchar (50) 
			,@dilaporkan_oleh_penjual           nvarchar (50) 
			,@dilaporkan_oleh_pemungut_ppn      nvarchar (50) 
			,@faktur_no_before                  nvarchar (50) 
			,@cre_date                          datetime      
			,@cre_by                            nvarchar (15) 
			,@cre_ip_address                    nvarchar (15) 
			,@mod_date                          datetime      
			,@mod_by                            nvarchar (15) 
			,@mod_ip_address                    nvarchar (15) 
			,@faktur_no_replacement_code        nvarchar (50) 
			,@user_id                           nvarchar (50) 
			,@upload_date                       datetime      
			,@no								int			= 0

	begin try
        begin
			declare c_jurnal cursor local fast_forward read_only for
			select	id
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
					,faktur_no_replacement_code
					,user_id
					,upload_date 
			from	dbo.faktur_no_replacement_detail_upload_1
			where	faktur_no_replacement_code = @p_faktur_no_replacement_code --and user_id = @p_cre_by -- and cast(upload_date as datetime) = cast(@p_cre_date as datetime)
			order by id asc

			open c_jurnal
			fetch c_jurnal 
			into 	@id 
					,@npwp_pembeli_or_identitas_lainnya 
					,@nama_pembeli                      
					,@kode_transaksi                    
					,@nomor_faktur_pajak                
					,@tanggal_faktur_pajak              
					,@masa_or_pajak                     
					,@tahun                             
					,@status_faktur                     
					,@harga_jual_or_penggantian_or_dpp  
					,@dpp_nilai_lain_or_dpp             
					,@ppn                               
					,@ppnbm                             
					,@penandatangan                     
					,@referensi                         
					,@dilaporkan_oleh_penjual           
					,@dilaporkan_oleh_pemungut_ppn                       
					,@faktur_no_replacement_code        
					,@user_id                           
					,@upload_date                       

			while @@fetch_status = 0
			begin
			set @no = @no + 1
					exec dbo.xsp_faktur_no_replacement_detail_upload_validasi_post  @p_no										= @no
																					,@p_id										= @id
																					,@p_npwp_pembeli_or_identitas_lainnya		= @npwp_pembeli_or_identitas_lainnya	
																					,@p_nama_pembeli							= @nama_pembeli						
																					,@p_kode_transaksi							= @kode_transaksi						
																					,@p_nomor_faktur_pajak						= @nomor_faktur_pajak					
																					,@p_tanggal_faktur_pajak					= @tanggal_faktur_pajak			
																					,@p_masa_or_pajak							= @masa_or_pajak						
																					,@p_tahun									= @tahun								
																					,@p_status_faktur							= @status_faktur						
																					,@p_harga_jual_or_penggantian_or_dpp		= @harga_jual_or_penggantian_or_dpp	
																					,@p_dpp_nilai_lain_or_dpp					= @dpp_nilai_lain_or_dpp				
																					,@p_ppn										= @ppn										
																					,@p_ppnbm									= @ppnbm								
																					,@p_penandatangan							= @penandatangan						
																					,@p_referensi								= @referensi							
																					,@p_dilaporkan_oleh_penjual					= @dilaporkan_oleh_penjual				
																					,@p_dilaporkan_oleh_pemungut_ppn			= @dilaporkan_oleh_pemungut_ppn							
																					,@p_faktur_no_replacement_code				= @faktur_no_replacement_code			
																					,@p_user_id									= @user_id								
																					,@p_upload_date								= @upload_date		
																					,@p_cre_by									= @p_cre_by			
																					,@p_cre_date								= @p_cre_date		
																					,@p_cre_ip_address							= @p_cre_ip_address	
					

					fetch	c_jurnal 
					into	@id
							,@npwp_pembeli_or_identitas_lainnya 
							,@nama_pembeli                      
							,@kode_transaksi                    
							,@nomor_faktur_pajak                
							,@tanggal_faktur_pajak              
							,@masa_or_pajak                     
							,@tahun                             
							,@status_faktur                     
							,@harga_jual_or_penggantian_or_dpp  
							,@dpp_nilai_lain_or_dpp             
							,@ppn                               
							,@ppnbm                             
							,@penandatangan                     
							,@referensi                         
							,@dilaporkan_oleh_penjual           
							,@dilaporkan_oleh_pemungut_ppn                      
							,@faktur_no_replacement_code        
							,@user_id                           
							,@upload_date 

			end
			close c_jurnal
			deallocate c_jurnal

			if not exists(	select 1 
							from	dbo.faktur_no_replacement_detail_upload_validasi_1 
							where	faktur_no_replacement_code		= @p_faktur_no_replacement_code 
							and		user_id							= @p_cre_by 
							and		cast(upload_date as datetime)	= cast(@upload_date as datetime))
			begin
			
					  insert into  dbo.faktur_no_replacement_detail
					  (
					      faktur_no_replacement_code,
					      user_id,
					      upload_date,
					      npwp_pembeli_or_identitas_lainnya,
					      nama_pembeli,
					      kode_transaksi,
					      nomor_faktur_pajak,
					      tanggal_faktur_pajak,
					      masa_or_pajak,
					      tahun,
					      status_faktur,
					      harga_jual_or_penggantian_or_dpp,
					      dpp_nilai_lain_or_dpp,
					      ppn,
					      ppnbm,
					      penandatangan,
					      referensi,
					      dilaporkan_oleh_penjual,
					      dilaporkan_oleh_pemungut_ppn,
						  faktur_no_before,
					      cre_date,
					      cre_by,
					      cre_ip_address,
					      mod_date,
					      mod_by,
					      mod_ip_address
					  )
					select	
                            faktur_no_replacement_code
                            ,user_id
                            ,upload_date
                            ,npwp_pembeli_or_identitas_lainnya
                            ,nama_pembeli
                            ,kode_transaksi
                            ,nomor_faktur_pajak
							,case when tanggal_faktur_pajak = '' then null 
								when tanggal_faktur_pajak = 'null' then null
								else cast(fnrdu.tanggal_faktur_pajak as date) end
                            ,masa_or_pajak
                            ,tahun
                            ,status_faktur
							,case when isnull(harga_jual_or_penggantian_or_dpp,'') = '' then null 
								when isnull(harga_jual_or_penggantian_or_dpp,'') = 'null' then null
								else convert(decimal(18,2),harga_jual_or_penggantian_or_dpp) end
							,case when isnull(dpp_nilai_lain_or_dpp,'') = '' then null 
								when isnull(dpp_nilai_lain_or_dpp,'') = 'null' then null
								else convert(decimal(18,2),dpp_nilai_lain_or_dpp) end
                            ,case when isnull(ppn,'') = '' then null 
								when isnull(ppn,'') = 'null' then null
								else convert(decimal(18,2),ppn) end
                            ,case when isnull(ppnbm,'') = '' then null 
								when isnull(ppnbm,'') = 'null' then null
								else convert(decimal(18,2),ppnbm) end
                            ,penandatangan
                            ,referensi
                            ,dilaporkan_oleh_penjual
                            ,dilaporkan_oleh_pemungut_ppn
							,inv.faktur_no
                            ,@p_cre_date
                            ,@p_cre_by
                            ,@p_cre_ip_address
                            ,@p_cre_date
                            ,@p_cre_by
                            ,@p_cre_ip_address
					from	dbo.faktur_no_replacement_detail_upload_1 fnrdu
							inner join dbo.invoice inv on inv.invoice_no = fnrdu.referensi
					where	faktur_no_replacement_code		= @p_faktur_no_replacement_code 
					--and		user_id							= @user_id 
					--and		cast(upload_date as datetime)	= cast(@upload_date as datetime)
			end
			else 
			begin
				update	dbo.faktur_no_replacement 
				set		validasi		= '1'
						,mod_date		= @p_cre_date
						,mod_by			= @p_cre_by
						,mod_ip_address = @p_cre_ip_address
				where	code			= @p_faktur_no_replacement_code		
			end
        end

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
			set @msg = N'V' + N';' + @msg ;
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
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
