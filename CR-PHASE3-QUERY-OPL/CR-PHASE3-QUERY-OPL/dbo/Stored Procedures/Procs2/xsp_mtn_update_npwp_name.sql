--Script Update NPWP Name di Agreement Asset untuk kebutuhan Invoice
CREATE PROCEDURE dbo.xsp_mtn_update_npwp_name
(
	@p_agreement_no		NVARCHAR(50)	= ''	-- NOMOR AGREEMENT DARI NMWP NAME YANG AKAN DI UBAH
	,@p_asset_no		nvarchar(50)	= ''	-- NOMOR ASSET NO PADA AGREEMENT JIKA UPDATE HANYA SPESIFIK 1 ASSET NO SAJA
	,@p_npwp_name_baru	nvarchar(400)	= ''	-- NAMA NWPW YANG AKAN DIUBAH
	--
	,@p_mod_by			nvarchar(50)	= ''	-- NAMA PIC YANG MELAKUKAN MAINTENANCE
			
)
as
begin
	begin try 
		BEGIN TRANSACTION
		
		DECLARE @msg				NVARCHAR(max)
				,@mod_date			DATETIME		= GETDATE()
				,@mod_ip_address	NVARCHAR(50)	= 'MTN_UPDATE_NPWP'
		 
		SELECT AGREEMENT_NO, NPWP_NAME 'npwp name old' FROM dbo.AGREEMENT_ASSET WHERE AGREEMENT_NO = @p_agreement_no
		 
		UPDATE	dbo.AGREEMENT_ASSET
		SET		NPWP_NAME		= @p_npwp_name_baru
				--
				,MOD_BY			= @p_mod_by
				,MOD_IP_ADDRESS = @mod_ip_address
				,MOD_DATE		= @mod_date
		WHERE	AGREEMENT_NO = @p_agreement_no				-- Gunakan ini jika mengupdate 1 agreement
		--AND ASSET_NO = @p_asset_no						-- Gunakan ini jika mengupdate spesifik asset
		 
		INSERT INTO dbo.MTN_DATA_DSF_LOG
		(
		    MAINTENANCE_NAME,
		    REMARK,
		    TABEL_UTAMA,
		    REFF_1,
		    REFF_2,
		    REFF_3,
		    CRE_DATE,
		    CRE_BY
		)
		VALUES
		(   'MTN_NPWP_NAME_AGREEMENT_ASSET', -- MAINTENANCE_NAME - nvarchar(50)
		    'MAINTENANCE ' + @p_agreement_no + ' Perubahan NPWP Name menjadi ' + @p_npwp_name_baru, -- REMARK - nvarchar(4000)
		    'AGREEMENT ASSET', -- TABEL_UTAMA - nvarchar(50)
		    @p_agreement_no, -- REFF_1 - nvarchar(50)
		    @p_asset_no, -- REFF_2 - nvarchar(50)
		    NULL, -- REFF_3 - nvarchar(50)
		    @mod_date, -- CRE_DATE - datetime
		    @p_mod_by  -- CRE_BY - nvarchar(250)
		    )
			if @@error = 0
			begin
				select 'SUCCESS'
				commit transaction ;
			end ;
			else
			begin
				select 'GAGAL PROCESS : ' + @msg
				rollback transaction ;
			end

		end try
		begin catch
			select 'GAGAL PROCESS : ' + @msg
			rollback transaction ;
		end catch ;  
			 
END
