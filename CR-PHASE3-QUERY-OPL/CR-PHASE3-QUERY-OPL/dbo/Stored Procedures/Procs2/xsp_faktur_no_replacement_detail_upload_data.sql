

CREATE PROCEDURE dbo.xsp_faktur_no_replacement_detail_upload_data
(
     @p_npwp_pembeli_or_identitas_lainnya NVARCHAR (50)  = ''
    ,@p_nama_pembeli                      NVARCHAR (50)  = ''
    ,@p_kode_transaksi                    NVARCHAR (50)  = ''
    ,@p_nomor_faktur_pajak                NVARCHAR (50)  = ''
    ,@p_tanggal_faktur_pajak              NVARCHAR (50)  = ''
    ,@p_masa_or_pajak                     NVARCHAR (50)  = ''
    ,@p_tahun                             NVARCHAR (50)  = ''
    ,@p_status_faktur                     NVARCHAR (50)  = ''
    ,@p_harga_jual_or_penggantian_or_dpp  NVARCHAR (50)  = ''
    ,@p_dpp_nilai_lain_or_dpp             NVARCHAR (50)  = ''
    ,@p_ppn                               NVARCHAR (50)  = ''
    ,@p_ppnbm                             NVARCHAR (50)  = ''
    ,@p_penandatangan                     NVARCHAR (50)  = ''
    ,@p_referensi                         NVARCHAR (50)  = ''
    ,@p_dilaporkan_oleh_penjual           NVARCHAR (50)  = ''
    ,@p_dilaporkan_oleh_pemungut_ppn      NVARCHAR (50)  = ''
    ,@p_cre_date                          NVARCHAR (50)  = ''
    ,@p_cre_by                            NVARCHAR (15)  = ''
    ,@p_cre_ip_address                    NVARCHAR (15)  = ''
    ,@p_mod_date                          NVARCHAR (50)  = ''
    ,@p_mod_by                            NVARCHAR (15)  = ''
    ,@p_mod_ip_address                    NVARCHAR (15)  = ''
    ,@p_faktur_no_replacement_code        NVARCHAR (50)  = ''

)
AS
BEGIN
	
	DECLARE @msg		 NVARCHAR(MAX)

	begin try
		
		insert into dbo.faktur_no_replacement_detail_upload_1
		(
			 npwp_pembeli_or_identitas_lainnya
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
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
			,faktur_no_replacement_code
			,user_id
			,upload_date
		)
		values
		(	 @p_npwp_pembeli_or_identitas_lainnya-- NPWP_PEMBELI_OR_IDENTITAS_LAINNYA - nvarchar(50)
			,@p_nama_pembeli                     -- NAMA_PEMBELI - nvarchar(50)
			,@p_kode_transaksi                   -- KODE_TRANSAKSI - nvarchar(50)
			,@p_nomor_faktur_pajak               -- NOMOR_FAKTUR_PAJAK - nvarchar(50)
			,@p_tanggal_faktur_pajak             -- TANGGAL_FAKTUR_PAJAK - datetime
			,@p_masa_or_pajak                    -- MASA_OR_PAJAK - datetime
			,@p_tahun                            -- TAHUN - datetime
			,@p_status_faktur                    -- STATUS_FAKTUR - nvarchar(50)
			,@p_harga_jual_or_penggantian_or_dpp -- HARGA_JUAL_OR_PENGGANTIAN_OR_DPP - decimal(9, 6)
			,@p_dpp_nilai_lain_or_dpp            -- DPP_NILAI_LAIN_OR_DPP - decimal(9, 6)
			,@p_ppn                              -- PPN - decimal(9, 6)
			,@p_ppnbm                            -- PPNBM - int
			,@p_penandatangan                    -- PENANDATANGAN - nvarchar(50)
			,@p_referensi                        -- REFERENSI - nvarchar(50)
			,@p_dilaporkan_oleh_penjual          -- DILAPORKAN_OLEH_PENJUAL - nvarchar(50)
			,@p_dilaporkan_oleh_pemungut_ppn     -- DILAPORKAN_OLEH_PEMUNGUT_PPN - nvarchar(50)
			,@p_cre_date                         -- CRE_DATE - datetime
			,@p_cre_by                           -- CRE_BY - nvarchar(15)
			,@p_cre_ip_address                   -- CRE_IP_ADDRESS - nvarchar(15)
			,@p_mod_date                         -- MOD_DATE - datetime
			,@p_mod_by                           -- MOD_BY - nvarchar(15)
			,@p_mod_ip_address                   -- MOD_IP_ADDRESS - nvarchar(15)
			,@p_faktur_no_replacement_code       -- FAKTUR_NO_REPLACEMENT_CODE - nvarchar(50)
			,@p_cre_by                          -- USER_ID - nvarchar(50)
			,@p_cre_date                      	-- UPLOAD_DATE - datetime
			)


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
