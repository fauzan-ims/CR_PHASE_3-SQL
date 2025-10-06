

CREATE PROCEDURE dbo.xsp_faktur_no_replacement_detail_upload_validasi_post
(			 
	@p_no									bigint
	,@p_id									bigint
	,@p_npwp_pembeli_or_identitas_lainnya	nvarchar (50) 
	,@p_nama_pembeli						nvarchar (50) 
	,@p_kode_transaksi						nvarchar (50) 
	,@p_nomor_faktur_pajak					nvarchar (50) 
	,@p_tanggal_faktur_pajak				nvarchar (50)       
	,@p_masa_or_pajak						nvarchar (50)      
	,@p_tahun								nvarchar (50)      
	,@p_status_faktur						nvarchar (50) 
	,@p_harga_jual_or_penggantian_or_dpp	nvarchar (50) 
	,@p_dpp_nilai_lain_or_dpp				nvarchar (50) 
	,@p_ppn									nvarchar (50) 
	,@p_ppnbm								nvarchar (50)            
	,@p_penandatangan						nvarchar (50) 
	,@p_referensi							nvarchar (50) 
	,@p_dilaporkan_oleh_penjual				nvarchar (50) 
	,@p_dilaporkan_oleh_pemungut_ppn		nvarchar (50) 
	--,@p_faktur_no_before					nvarchar (50) 
	,@p_faktur_no_replacement_code			nvarchar (50) 
	,@p_user_id								nvarchar (50) 
	,@p_upload_date							datetime
	,@p_cre_by								nvarchar(15)
	,@p_cre_date							datetime
	,@p_cre_ip_address						nvarchar(15)

)
as
begin
	declare @msg						nvarchar(max)
			,@validasi1					nvarchar(max)= ''
			,@invoice_no_exist_faktur	nvarchar(50)		
			,@faktur_no_exist			nvarchar(50)
		
	begin try

		if isnull(@p_referensi,'') = ''
		begin
		    set @validasi1 = ', referensi tidak boleh kosong'
		end
	
		if isnull(@p_nomor_faktur_pajak,'') = ''
		begin
		    set @validasi1 = @validasi1+', faktur no coretax tidak boleh kosong'
		end

		if isnull(@p_referensi,'') <> ''
		begin
			if not exists (select 1 from dbo.invoice where invoice_no = @p_referensi)
			begin
			     set @validasi1 = @validasi1+', referensi '+ isnull(@p_referensi,'') +' tidak terdaftar pada invoice'
			end
			if exists (select 1 from dbo.invoice where invoice_no = @p_referensi and invoice_status <> 'POST')
			begin
			    set @validasi1 = @validasi1+', referensi '+ isnull(@p_referensi,'') +' tidak berstatus POST'
			end
			if exists (select 1 from dbo.invoice where invoice_no = @p_referensi and faktur_no = @p_nomor_faktur_pajak)
			begin
			    set @validasi1 = @validasi1+', referensi '+ isnull(@p_referensi,'') +' dengan faktur no '+ isnull(@p_nomor_faktur_pajak,'') +' sudah terdaftar pada ifin'
			end
		end

		if isnull(@p_nomor_faktur_pajak,'') <> ''
		begin
			if(left(@p_nomor_faktur_pajak,2) <> '04') -- jika bukan kode 04
			begin
				set @validasi1 = @validasi1+', nomor seri pada nomor faktur pajak harus diawali dengan 04'
			end
	
			if exists (select 1 from dbo.invoice where faktur_no = @p_nomor_faktur_pajak and invoice_no <> @p_referensi )
			begin
				select @invoice_no_exist_faktur = invoice_no from dbo.invoice where faktur_no = @p_nomor_faktur_pajak
				set @validasi1 = @validasi1+', nomor faktur telah terdaftar di invoice no '+ isnull(@invoice_no_exist_faktur,'')
			end

			select @faktur_no_exist = faktur_no from dbo.invoice where invoice_no = @p_referensi and isnull(faktur_no ,'') <> '' and faktur_no not in (select faktur_no from dbo.faktur_allocation_detail)
			if left(@faktur_no_exist,4) = left(@p_nomor_faktur_pajak,4)
			begin
				set @validasi1 = @validasi1+', tidak bisa mereplace no faktur pajak dengan 4 nomor seri yang sama pada invoice ' + isnull(@p_referensi,'')
			end
		end

		if isnull(@p_status_faktur,'') <> 'APPROVED'
		begin
		    set @validasi1 = @validasi1+', status faktur harus APPROVED'
		end

		--sepria(11032025: set yg isinya kosong jadi null atau no untuk datatype tabel datetime dan decimal)
		begin
			if(isnull(@p_tanggal_faktur_pajak,'') <> '')
			begin
			   if (try_parse(@p_tanggal_faktur_pajak as datetime) is null)
				begin
					set @validasi1 = @validasi1+', format tanggal faktur pajak salah'
				end
			end

			if(isnull(@p_harga_jual_or_penggantian_or_dpp,'') <> '')
			begin
			   if (try_parse(@p_harga_jual_or_penggantian_or_dpp as decimal (18,2)) is null)
				begin
					set @validasi1 = @validasi1+', format harga jual/penggantian/dpp salah'
				end
			end

			if(isnull(@p_dpp_nilai_lain_or_dpp,'') <> '')
			begin
			   if (try_parse(@p_dpp_nilai_lain_or_dpp as decimal (18,2)) is null)
				begin
					set @validasi1 = @validasi1+', format dpp nilai lain/dpp salah'
				end
			end

			if(isnull(@p_ppn,'') <> '')
			begin
			   if (try_parse(@p_ppn as decimal (18,2)) is null)
				begin
					set @validasi1 = @validasi1+', format ppn salah'
				end
			end

			if(isnull(@p_ppnbm,'') <> '')
			begin
			   if (try_parse(@p_ppnbm as decimal (18,2)) is null)
				begin
					set @validasi1 = @validasi1+', format ppnbm salah'
				end
			end
		end

		if isnull(@validasi1,'') <> ''
		begin

			set @validasi1 = convert(nvarchar(5),@p_no) + @validasi1

			insert into dbo.faktur_no_replacement_detail_upload_validasi_1
			(
			    id_upload_data,
			    faktur_no_replacement_code,
			    user_id,
			    upload_date,
			    validasi,
			    cre_date,
			    cre_by,
			    cre_ip_address,
			    mod_date,
			    mod_by,
			    mod_ip_address
			)
			values
			(   @p_id
				,@p_faktur_no_replacement_code
				,@p_user_id
				,@p_upload_date
				,@validasi1
				,@p_cre_date		
				,@p_cre_by			
				,@p_cre_ip_address
				,@p_cre_date		
				,@p_cre_by			
				,@p_cre_ip_address
			    )
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

