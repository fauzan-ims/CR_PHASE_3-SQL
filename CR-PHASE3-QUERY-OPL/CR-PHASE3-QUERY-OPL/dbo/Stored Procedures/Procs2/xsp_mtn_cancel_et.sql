CREATE PROCEDURE dbo.xsp_mtn_cancel_et
(--buat manitenace ET
	@p_agreement_no		NVARCHAR(50)
	,@p_et_code			NVARCHAR(50)
	,@p_mod_by			NVARCHAR(50)
	,@p_mod_ip_address	NVARCHAR(15)
)
AS
BEGIN
	declare @msg		nvarchar(max)
			,@code_handovr	nvarchar(50)	--untuk code handover
			,@code_maturity nvarchar(50)
			,@agreement		nvarchar(50)
			,@agreement_no	nvarchar(50)	= replace(@p_agreement_no, '/', '.')
			,@mod_date		datetime		= getdate()
			--,@p_mod_by		nvarchar(250)
			,@hand_code		nvarchar(50)
			,@hand_stats	nvarchar(20)
			,@asset_no		NVARCHAR(50)
			,@client_no		NVARCHAR(50)
			,@client_name	NVARCHAR(50)
			,@fa_code		NVARCHAR(50)

	begin transaction;
	begin try

		SELECT  @client_no		= CLIENT_NO  
				,@client_name	= CLIENT_NAME
		FROM	dbo.AGREEMENT_MAIN
		WHERE	AGREEMENT_EXTERNAL_NO = @p_agreement_no
		
		DECLARE handover_lebih_dari_1_asset CURSOR FAST_FORWARD READ_ONLY FOR 	
			
		select	hr.HANDOVER_CODE
				,ed.ASSET_NO
				,ha.STATUS
		from	IFINOPL.dbo.ET_MAIN mt
				INNER JOIN dbo.ET_DETAIL ed ON ed.ET_CODE = mt.CODE
				inner join ifinams.dbo.handover_request hr on hr.ASSET_NO = ed.ASSET_NO
				left join ifinams.dbo.handover_asset ha on ha.code = hr.handover_code
		where	mt.AGREEMENT_NO = @agreement_no
				AND ed.IS_TERMINATE = '3'
				and		hr.TYPE		= 'PICK UP'
				AND ha.REFF_NAME = 'EARLY TERMINATION'
		
		OPEN handover_lebih_dari_1_asset
		
		FETCH NEXT FROM handover_lebih_dari_1_asset 
		INTO	@hand_code
				,@asset_no
				,@hand_stats
        
		WHILE @@FETCH_STATUS = 0
		BEGIN

		SELECT 'BEFORE',ASSET_STATUS,* 
		from dbo.AGREEMENT_ASSET 
		where ASSET_NO = @asset_no

			if (@hand_stats = 'POST')
			BEGIN

			select	@fa_code = fa_code 
			from	dbo.agreement_asset 
			where	asset_no = @asset_no

            
				UPDATE IFINAMS.dbo.ASSET
				set		fisical_status			= 'ON CUSTOMER'
						,rental_status			= 'IN USE'
						,agreement_no			= @agreement_no
						,agreement_external_no	= @p_agreement_no
						,client_no				= @client_no
						,client_name			= @client_name
						--
						,MOD_DATE				= GETDATE()
						,MOD_BY					= @p_mod_by
						,MOD_IP_ADDRESS			= @p_mod_ip_address
				WHERE CODE =  @fa_code
				PRINT 'update asset'
			end
			
		    update IFINAMS.dbo.HANDOVER_ASSET
			set STATUS				= 'CANCEL'
				,REMARK				= 'CANCEL KARENA BATAL DILAKUKAN ET'
				,MOD_DATE			= GETDATE()
				,MOD_BY				= @p_mod_by
				,MOD_IP_ADDRESS		= @p_mod_ip_address
			where CODE = @hand_code
			and	TYPE = 'PICK UP'
			AND REFF_NAME = 'EARLY TERMINATION'
			PRINT 'update handover asset ams'

			update IFINAMS.dbo.HANDOVER_REQUEST
			set STATUS				= 'CANCEL'
				,REMARK				= 'CANCEL KARENA BATAL DILAKUKAN ET'
				,MOD_DATE			= GETDATE()
				,MOD_BY				= @p_mod_by
				,MOD_IP_ADDRESS		= @p_mod_ip_address
			where ASSET_NO = @asset_no
			and	TYPE = 'PICK UP'
			AND REFF_NAME = 'EARLY TERMINATION'
			PRINT 'update handover request ams'

			update IFINAMS.dbo.AMS_INTERFACE_HANDOVER_ASSET
			set STATUS				= 'CANCEL'
				,REMARK				= 'CANCEL KARENA BATAL DILAKUKAN ET'
				,MOD_DATE			= GETDATE()
				,MOD_BY				= @p_mod_by
				,MOD_IP_ADDRESS		= @p_mod_ip_address
			where ASSET_NO = @asset_no
			and	TYPE = 'PICK UP'
			AND REFF_NAME = 'EARLY TERMINATION'
			PRINT 'update handover asset interface ams'


			update dbo.OPL_INTERFACE_HANDOVER_ASSET
			set STATUS				= 'CANCEL'
				,REMARK				= 'CANCEL KARENA BATAL DILAKUKAN ET'
				,MOD_DATE			= GETDATE()
				,MOD_BY				= @p_mod_by
				,MOD_IP_ADDRESS		= @p_mod_ip_address
			where ASSET_NO = @asset_no
			and	TYPE = 'PICK UP'
			AND REFF_NAME = 'EARLY TERMINATION'
			PRINT 'update handover asset interface opl'

			update	dbo.AGREEMENT_ASSET
			set		ASSET_STATUS			= 'RENTED'
					--
					,MOD_DATE				= GETDATE()
					,MOD_BY					= @p_mod_by
					,MOD_IP_ADDRESS			= @p_mod_ip_address
			where	ASSET_NO = @asset_no;
			PRINT 'update agreement_asset'

			
			UPDATE dbo.ET_DETAIL
			SET		IS_TERMINATE = '0'
					,MOD_DATE				= GETDATE()
					,MOD_BY					= @p_mod_by
					,MOD_IP_ADDRESS			= @p_mod_ip_address
			WHERE ASSET_NO = @asset_no AND ET_CODE = @p_et_code
			PRINT 'update et detail'
		
			IF EXISTS
			(
				SELECT	1 
				FROM	dbo.ADDITIONAL_INVOICE_REQUEST 
				WHERE	ASSET_NO = @asset_no 
				AND		REFF_CODE = @p_et_code
				AND		STATUS = 'HOLD'
			)
			BEGIN
				UPDATE	dbo.ADDITIONAL_INVOICE_REQUEST
				SET		STATUS = 'CANCEL'
						,MOD_DATE				= GETDATE()
						,MOD_BY					= @p_mod_by
						,MOD_IP_ADDRESS			= @p_mod_ip_address
				WHERE	REFF_CODE = @p_et_code
				AND		ASSET_NO = @asset_no
				PRINT 'UPDATE ADDITIONAL INVOICE REQUEST MENJADI CANCEL'
			END

			SELECT 'AFTER',ASSET_STATUS,* 
			from dbo.AGREEMENT_ASSET 
			where ASSET_NO = @asset_no

			--SELECT * FROM IFINAMS.dbo.HANDOVER_ASSET
			--where code = @hand_code

		    FETCH NEXT FROM handover_lebih_dari_1_asset 
			INTO	@hand_code
					,@asset_no
					,@hand_stats
		end
        
		CLOSE handover_lebih_dari_1_asset
		DEALLOCATE handover_lebih_dari_1_asset
        

		SELECT * FROM IFINAMS.dbo.AMS_INTERFACE_HANDOVER_ASSET WHERE MOD_IP_ADDRESS = @p_mod_ip_address
		SELECT * FROM IFINAMS.dbo.HANDOVER_REQUEST WHERE MOD_IP_ADDRESS =  @p_mod_ip_address
		SELECT * FROM IFINAMS.dbo.HANDOVER_ASSET WHERE MOD_IP_ADDRESS = @p_mod_ip_address
		SELECT * FROM IFINAMS.dbo.ASSET WHERE MOD_IP_ADDRESS = @p_mod_ip_address
		SELECT * FROM dbo.ET_DETAIL WHERE MOD_IP_ADDRESS = @p_mod_ip_address
		SELECT * FROM dbo.ADDITIONAL_INVOICE_REQUEST WHERE MOD_IP_ADDRESS = @p_mod_ip_address
		begin
			insert into dbo.MTN_DATA_DSF_LOG
			(
				MAINTENANCE_NAME
				,REMARK
				,TABEL_UTAMA
				,REFF_1
				,REFF_2
				,REFF_3
				,CRE_DATE
				,CRE_BY
			)
			values
			(	'Request Cancel Asset yang akan di ET' -- MAINTENANCE_NAME - nvarchar(50)
				,'DIKARENAKAN ET DICANCEL UNTUK BEBERAPA ASSET'		-- REMARK - nvarchar(4000)
				,'ET_DETAIL'							-- TABEL_UTAMA - nvarchar(50)
				,@agreement_no						-- REFF_1 - nvarchar(50)
				,@p_et_code								-- REFF_2 - nvarchar(50)
				,@p_mod_ip_address								-- REFF_3 - nvarchar(50)
				,@mod_date							-- CRE_DATE - datetime
				,@p_mod_by							-- CRE_BY - nvarchar(250)
				);
		end;

		if @@error = 0
		begin
			select	'SUCCESS';
			commit transaction;
		end;
		else
		begin
			select	'GAGAL';
			rollback transaction;
		end;
	end try
	begin catch

		rollback transaction;

		if (len(@msg) <> 0)
		begin
			set @msg = N'V' + N';' + @msg;
		end;
		else
		begin
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message();
			end;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message();
			end;
		end;

		raiserror(@msg, 16, -1);

		return;
	end catch;
end;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_mtn_cancel_et] TO [ims-raffyanda]
    AS [dbo];

