CREATE PROCEDURE dbo.xsp_mtn_hold_maturity
(--buat manitenace matueity
	@p_agreement_no nvarchar(50)
	,@p_mod_by	nvarchar(50)
)
as
begin
	declare @msg		nvarchar(max)
			,@code_handovr	nvarchar(50)	--untuk code handover
			,@code_maturity nvarchar(50)
			,@agreement		nvarchar(50)
			,@agreement_no	nvarchar(50)	= replace(@p_agreement_no, '/', '.')
			,@mod_date		datetime		= getdate()
			--,@p_mod_by		nvarchar(250)
			,@hand_code		nvarchar(50)
			,@hand_stats	nvarchar(20)

	begin transaction;
	begin try

		select	@code_maturity = mt.CODE
				,@code_handovr = hr.CODE
				,@agreement = hr.AGREEMENT_NO
				--,@hand_code = hr.HANDOVER_CODE
				,@hand_stats = ha.STATUS
		from	IFINOPL.dbo.MATURITY mt
				inner join ifinams.dbo.handover_request hr on hr.agreement_no = mt.agreement_no
				left join ifinams.dbo.handover_asset ha on ha.code = hr.handover_code
		where	mt.AGREEMENT_NO = @agreement_no
		and		mt.STATUS			= 'POST'
		and		mt.RESULT			= 'STOP'
		and		hr.TYPE				= 'PICK UP'
		AND		hr.STATUS			<> 'CANCEL'
		
		DECLARE handover_lebih_dari_1_asset CURSOR FAST_FORWARD READ_ONLY FOR 	
			
				select	hr.HANDOVER_CODE
				from	IFINOPL.dbo.MATURITY mt
						inner join ifinams.dbo.handover_request hr on hr.agreement_no = mt.agreement_no
						left join ifinams.dbo.handover_asset ha on ha.code = hr.handover_code
				where	mt.AGREEMENT_NO = @agreement_no
				and		mt.STATUS			= 'POST'
				and		mt.RESULT			= 'STOP'
				and		hr.TYPE				= 'PICK UP'
				AND		HR.STATUS			<> 'CANCEL'
		
		OPEN handover_lebih_dari_1_asset
		
		FETCH NEXT FROM handover_lebih_dari_1_asset INTO @hand_code
        
		WHILE @@FETCH_STATUS = 0
		BEGIN
		    update IFINAMS.dbo.HANDOVER_ASSET
			set STATUS = 'CANCEL'
				,REMARK = 'CANCEL MATURITY DIKARENAKAN INGIN EXTEND'
				,MOD_DATE = @mod_date
				,MOD_BY = @p_mod_by
				,MOD_IP_ADDRESS = @p_mod_by
			where CODE = @hand_code
			and	TYPE = 'PICK UP'

			SELECT * FROM IFINAMS.dbo.HANDOVER_ASSET
			where code = @hand_code
		
		    FETCH NEXT FROM handover_lebih_dari_1_asset INTO @hand_code
		end
        
		CLOSE handover_lebih_dari_1_asset
		DEALLOCATE handover_lebih_dari_1_asset
        
		---command aja jika handover_assetnya hold lalu jalankan script ini kembali
		if exists
			(
				select	1
				from	IFINAMS.dbo.HANDOVER_REQUEST
				where	STATUS	<> 'HOLD'
				and		CODE		= @code_handovr
			)
		begin
			set @msg = ('HAND OVER REQUEST SUDAH TIDAK HOLD ' + @hand_code + ' ' + @hand_stats);
			raiserror(@msg, 16, 1);
			return;

		end;
		-- befpre
		--SELECT * FROM IFINAMS.dbo.HANDOVER_ASSET
		--where code = @hand_code

		select	*
		from	IFINAMS.dbo.HANDOVER_REQUEST
		where AGREEMENT_NO = @agreement;

		select	*
		from	IFINAMS.dbo.AMS_INTERFACE_HANDOVER_ASSET
		where AGREEMENT_NO = @agreement;

		select	*
		from	dbo.OPL_INTERFACE_HANDOVER_ASSET
		where AGREEMENT_NO = @agreement;


		--
		--update IFINAMS.dbo.HANDOVER_ASSET
		--set STATUS = 'CANCEL'
		--	,REMARK = 'CANCEL MATURITY DIKARENAKAN INGIN EXTEND'
		--	,MOD_DATE = @mod_date
		--	,MOD_BY = @p_mod_by
		--	,MOD_IP_ADDRESS = @p_mod_by
		--where CODE = @hand_code
		--	and	TYPE = 'PICK UP'


		update IFINAMS.dbo.HANDOVER_REQUEST
		set STATUS = 'CANCEL'
			,REMARK = 'CANCEL MATURITY DIKARENAKAN INGIN EXTEND'
			,MOD_DATE = @mod_date
			,MOD_BY = @p_mod_by
			,MOD_IP_ADDRESS = @p_mod_by
		where AGREEMENT_NO = @agreement
		and	TYPE = 'PICK UP'
		AND	STATUS <> 'CANCEL'

		update IFINAMS.dbo.AMS_INTERFACE_HANDOVER_ASSET
		set STATUS = 'CANCEL'
			,REMARK = 'CANCEL MATURITY DIKARENAKAN INGIN EXTEND'
			,MOD_DATE = @mod_date
			,MOD_BY = @p_mod_by
			,MOD_IP_ADDRESS = @p_mod_by
		where AGREEMENT_NO = @agreement
		and	TYPE = 'PICK UP'
		AND	STATUS <> 'CANCEL'

		update dbo.OPL_INTERFACE_HANDOVER_ASSET
		set STATUS = 'CANCEL'
			,REMARK = 'CANCEL MATURITY DIKARENAKAN INGIN EXTEND'
			,MOD_DATE = @mod_date
			,MOD_BY = @p_mod_by
			,MOD_IP_ADDRESS = @p_mod_by
		where AGREEMENT_NO = @agreement
		and	TYPE = 'PICK UP'
		AND	STATUS <> 'CANCEL'

		--delete from IFINAMS.dbo.HANDOVER_REQUEST
		--where AGREEMENT_NO = @agreement;
		--delete from IFINAMS.dbo.AMS_INTERFACE_HANDOVER_ASSET
		--where AGREEMENT_NO = @agreement;
		--delete from dbo.OPL_INTERFACE_HANDOVER_ASSET
		--where AGREEMENT_NO = @agreement;
		--delete IFINAMS.dbo.HANDOVER_ASSET
		--where CODE = @hand_code

		SELECT 'BEFORE',ASSET_STATUS,* 
		from dbo.AGREEMENT_ASSET 
		where AGREEMENT_NO = @agreement

		select	'BEFORE'
				,STATUS
				,*
		from	dbo.MATURITY
		where CODE = @code_maturity;

		--HOLD MATUR
		begin
			update	dbo.MATURITY
			set STATUS = 'HOLD'
			where CODE = @code_maturity;
		end;


		update	dbo.AGREEMENT_ASSET
		set		ASSET_STATUS = 'RENTED'
		where	AGREEMENT_NO = @agreement;
		--

		--after
		select	'AFTER'
				,STATUS
				,*
		from	dbo.MATURITY
		where CODE = @code_maturity;

		SELECT 'AFTER',ASSET_STATUS,* 
		from dbo.AGREEMENT_ASSET 
		where AGREEMENT_NO = @agreement

		--SELECT * FROM IFINAMS.dbo.HANDOVER_ASSET
		--where code = @hand_code

		select	*
		from	IFINAMS.dbo.HANDOVER_REQUEST
		where AGREEMENT_NO = @agreement;

		select	*
		from	IFINAMS.dbo.AMS_INTERFACE_HANDOVER_ASSET
		where AGREEMENT_NO = @agreement;

		select	*
		from	dbo.OPL_INTERFACE_HANDOVER_ASSET
		where AGREEMENT_NO = @agreement;

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
			(	'Request Perubahan Status Maturity' -- MAINTENANCE_NAME - nvarchar(50)
				,'Dikarnakan user ingin Extend'		-- REMARK - nvarchar(4000)
				,'MATURITY'							-- TABEL_UTAMA - nvarchar(50)
				,@agreement_no						-- REFF_1 - nvarchar(50)
				,null								-- REFF_2 - nvarchar(50)
				,null								-- REFF_3 - nvarchar(50)
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
    ON OBJECT::[dbo].[xsp_mtn_hold_maturity] TO [aryo.budi]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_mtn_hold_maturity] TO [ims-raffyanda]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_mtn_hold_maturity] TO [eddy.rakhman]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_mtn_hold_maturity] TO [bsi-miki.maulana]
    AS [dbo];

