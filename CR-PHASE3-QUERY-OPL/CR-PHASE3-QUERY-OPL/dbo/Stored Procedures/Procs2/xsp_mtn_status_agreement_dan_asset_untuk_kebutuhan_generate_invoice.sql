CREATE PROCEDURE dbo.xsp_mtn_status_agreement_dan_asset_untuk_kebutuhan_generate_invoice
(
--berikut adalah script buka tutup untuk pembuatan additional invoice

--*reminder : untuk script ini dijalankan ketika user sudah siap membuat additional invoice dan jalankan lagi jika user sudah selesai generate additional invoice(kembali posisi awal) 
--*critical : jika tidak ada info dari user ketika dibukakan harus segera di ubah kembali, agar tidak ada yang bergerak

	@p_agreement_no			NVARCHAR(50)  --isi no kontraknya
	,@p_asset_no			NVARCHAR(50) -- Isi kode asset nya (untuk perubahan yang hanya spesifik asset saja) 
	,@p_agreement_condition NVARCHAR(1) -- ini isi 1 untuk agreementnya juga
	,@p_asset_condition		NVARCHAR(1) -- ini isi 1 untuk assetnya juga 
	,@p_mod_by				NVARCHAR(50)
)
as
begin
-- agreement condition = 1 Jika ingin update status agreement 
-- asset condition = 1 jika ingin update status asset 

	DECLARE  @msg				NVARCHAR(MAX)
			,@status_agreement	NVARCHAR(50)
			,@status_asset		NVARCHAR(50)
			,@agreement_no		NVARCHAR(50) = REPLACE(@p_agreement_no,'/','.')
			,@mod_ip_address	NVARCHAR(50) = @p_mod_by

	begin TRY

	select	'BEFORE',am.agreement_status 
			,ast.asset_status
			,COUNT(ast.ASSET_NO) 'total asset'
	from	dbo.agreement_main am
	inner join dbo.agreement_asset ast on ast.agreement_no = am.agreement_no
	where	am.agreement_no = @agreement_no
	GROUP BY am.AGREEMENT_STATUS,ast.ASSET_STATUS

		if (isnull(@p_mod_by, '') = '')
		begin
			set @msg = 'Harap diisi MTN Mod By';
			raiserror(@msg, 16, 1) ;
			return
		end

	SELECT	@status_agreement	= am.AGREEMENT_STATUS 
	FROM	dbo.AGREEMENT_MAIN am
	INNER JOIN dbo.AGREEMENT_ASSET ast ON ast.AGREEMENT_NO = am.AGREEMENT_NO
	WHERE	am.AGREEMENT_NO = @agreement_no --AND ast.ASSET_NO = @p_asset_no

	SELECT	@status_asset		= ast.ASSET_STATUS
	FROM	dbo.AGREEMENT_MAIN am
	INNER JOIN dbo.AGREEMENT_ASSET ast ON ast.AGREEMENT_NO = am.AGREEMENT_NO
	WHERE	am.AGREEMENT_NO = @agreement_no AND ast.ASSET_NO = @p_asset_no

	IF (@p_agreement_condition = '1')
	begin
		IF (@status_agreement = 'TERMINATE')
			BEGIN

			PRINT 'MASUK'
				UPDATE dbo.AGREEMENT_MAIN 
				SET AGREEMENT_STATUS = 'GO LIVE'
					,MOD_DATE = GETDATE()
					,MOD_BY = @p_mod_by
					,MOD_IP_ADDRESS = @mod_ip_address
				WHERE AGREEMENT_NO = @agreement_no
	
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
				(   N'Perubahan Status Agreement/Asset',       -- MAINTENANCE_NAME - nvarchar(50)
					N'Merubah status agreement/asset dari terminate menjadi go live untuk kebutuhan generate invoice',       -- REMARK - nvarchar(4000)
					N'AGREEMENT_MAIN',       -- TABEL_UTAMA - nvarchar(50)
					@p_agreement_no,       -- REFF_1 - nvarchar(50)
					N'',       -- REFF_2 - nvarchar(50)
					N'',       -- REFF_3 - nvarchar(50)
					GETDATE(), -- CRE_DATE - datetime
					@p_mod_by        -- CRE_BY - nvarchar(250)
					)
			end
		ELSE
	--if @status_agreement = 'GO LIVE'
			BEGIN
				UPDATE dbo.AGREEMENT_MAIN 
				SET AGREEMENT_STATUS = 'TERMINATE'
					,MOD_DATE = GETDATE()
					,MOD_BY = @p_mod_by
					,MOD_IP_ADDRESS = @mod_ip_address
				WHERE AGREEMENT_NO = @agreement_no


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
				(   N'Perubahan Status Agreement/Asset',       -- MAINTENANCE_NAME - nvarchar(50)
					N'Merubah status agreement/asset dari terminate menjadi terminate menjadi golive untuk kebutuhan generate invoice',       -- REMARK - nvarchar(4000)
					N'AGREEMENT_MAIN',       -- TABEL_UTAMA - nvarchar(50)
					@p_agreement_no,       -- REFF_1 - nvarchar(50)
					N'',       -- REFF_2 - nvarchar(50)
					N'',       -- REFF_3 - nvarchar(50)
					GETDATE(), -- CRE_DATE - datetime
					@p_mod_by        -- CRE_BY - nvarchar(250)
					)
			end
	END

	IF (@p_asset_condition = '1')
	BEGIN 
		IF (@status_asset in ('RETURN','TERMINATE'))
			BEGIN
				UPDATE dbo.AGREEMENT_ASSET
				SET ASSET_STATUS = 'RENTED'
					,MOD_DATE = GETDATE()
					,MOD_BY = @p_mod_by
					,MOD_IP_ADDRESS = @mod_ip_address
				WHERE AGREEMENT_NO = @agreement_no and asset_no = @p_asset_no

				--UPDATE	dbo.ET_MAIN
				--SET		ET_STATUS = 'CANCEL'
				--FROM	dbo.ET_MAIN A
				--INNER JOIN dbo.ET_DETAIL B ON B.ET_CODE = A.CODE
				--WHERE	ET_STATUS = 'APPROVE'
				--		AND IS_TERMINATE = '1'
				--		AND B.ASSET_NO = @p_asset_no
	
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
				(   N'Perubahan Status Asset',       -- MAINTENANCE_NAME - nvarchar(50)
					N'Merubah status agreement dari Return menjadi Rented untuk kebutuhan generate invoice',       -- REMARK - nvarchar(4000)
					N'AGREEMENT_ASSET',       -- TABEL_UTAMA - nvarchar(50)
					@p_agreement_no,       -- REFF_1 - nvarchar(50)
					@p_asset_no,       -- REFF_2 - nvarchar(50)
					N'',       -- REFF_3 - nvarchar(50)
					GETDATE(), -- CRE_DATE - datetime
					@p_mod_by        -- CRE_BY - nvarchar(250)
					)
			END
		ELSE 
			BEGIN
				UPDATE dbo.AGREEMENT_ASSET
				SET ASSET_STATUS = 'RETURN'
					,MOD_DATE = GETDATE()
					,MOD_BY = @p_mod_by
					,MOD_IP_ADDRESS = @mod_ip_address
				WHERE AGREEMENT_NO = @agreement_no and asset_no = @p_asset_no


				
				--SET @msg = 'Status asset masih rented'
			--RAISERROR (@msg, 16, -1)
		END
	end


	select	'AFTER',am.agreement_status 
			,ast.asset_status
			,COUNT(ast.ASSET_NO) 'total asset'
	from	dbo.agreement_main am
	inner join dbo.agreement_asset ast on ast.agreement_no = am.agreement_no
	where	am.agreement_no = @agreement_no
	GROUP BY am.AGREEMENT_STATUS,ast.ASSET_STATUS

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

GO
GRANT ALTER
    ON OBJECT::[dbo].[xsp_mtn_status_agreement_dan_asset_untuk_kebutuhan_generate_invoice] TO [aryo]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_mtn_status_agreement_dan_asset_untuk_kebutuhan_generate_invoice] TO [aryo]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[xsp_mtn_status_agreement_dan_asset_untuk_kebutuhan_generate_invoice] TO [DSF\aryo.budi]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_mtn_status_agreement_dan_asset_untuk_kebutuhan_generate_invoice] TO [DSF\aryo.budi]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[xsp_mtn_status_agreement_dan_asset_untuk_kebutuhan_generate_invoice] TO [DSF\eddy.rakhman]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_mtn_status_agreement_dan_asset_untuk_kebutuhan_generate_invoice] TO [DSF\eddy.rakhman]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[xsp_mtn_status_agreement_dan_asset_untuk_kebutuhan_generate_invoice] TO [eddy.r]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_mtn_status_agreement_dan_asset_untuk_kebutuhan_generate_invoice] TO [eddy.r]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[xsp_mtn_status_agreement_dan_asset_untuk_kebutuhan_generate_invoice] TO [aryo.budi]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_mtn_status_agreement_dan_asset_untuk_kebutuhan_generate_invoice] TO [aryo.budi]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[xsp_mtn_status_agreement_dan_asset_untuk_kebutuhan_generate_invoice] TO [eddy.rakhman]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_mtn_status_agreement_dan_asset_untuk_kebutuhan_generate_invoice] TO [eddy.rakhman]
    AS [dbo];

