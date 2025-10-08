CREATE PROCEDURE dbo.xsp_mtn_hold_maturity_full_version
(--buat manitenace matueity
	@p_agreement_no			nvarchar(50)
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@code_handovr				nvarchar(50)	--untuk code handover
			,@code_maturity				nvarchar(50)
			,@agreement					nvarchar(50)
			,@agreement_no				nvarchar(50)	= replace(@p_agreement_no, '/', '.')
			,@mod_date					datetime		= getdate()
			--,@p_mod_by					nvarchar(250)
			,@hand_code					nvarchar(50)
			,@hand_stats 				nvarchar(50)
			,@handover_request_status	nvarchar(50)			
			,@client_no					nvarchar(50)
			,@client_name				nvarchar(250)
			,@asset_no					nvarchar(50)
			,@fa_code					nvarchar(50)

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
		
		select	@handover_request_status = status
		from	ifinams.dbo.handover_request
		where	code = @code_handovr;
		
		SELECT @hand_stats 'HANDOVER_ASSET_STATUS',@handover_request_status 'HANDOVER_REQUEST_STATUS'
		
		IF (@handover_request_status = 'HOLD')
		BEGIN
		
		    EXEC dbo.xsp_mtn_hold_maturity @p_agreement_no = @p_agreement_no, -- nvarchar(50)
		                                   @p_mod_by = @p_mod_by;             -- nvarchar(50)
		END;
		
		IF (@hand_stats = 'HOLD')
		BEGIN
		    --SELECT 'MASUK';
		    EXEC dbo.xsp_mtn_hold_maturity_v2 @p_agreement_no = @p_agreement_no, -- nvarchar(50)
		                                      @p_mod_by = @p_mod_by;             -- nvarchar(50)
		END;

		IF (@hand_stats = 'POST')
		BEGIN

		select @agreement_no = am.agreement_no
				,@client_no = am.client_no
				,@client_name = am.client_name
				,@asset_no = ass.asset_no
				,@fa_code = ass.fa_code
		from	dbo.agreement_main am
		inner join dbo.agreement_asset ass on ass.agreement_no = am.agreement_no
		where	am.agreement_no = @agreement_no

		select 'BEFORE', * from ifinams.dbo.asset where code = @fa_code

		update	IFINAMS.dbo.asset
		set		fisical_status			= 'ON CUSTOMER'
				,rental_status			= 'IN USE'
				,agreement_no			= @agreement_no
				,agreement_external_no	= @p_agreement_no
				,client_no				= @client_no
				,client_name			= @client_name
				,asset_no				= @asset_no
				,re_rent_status			= 'IN USE'
				--
				,mod_date				= getdate()	  
				,mod_by					= @p_mod_by		  
				,mod_ip_address			= @p_mod_ip_address
		where	code = @fa_code ;


		exec dbo.xsp_mtn_hold_maturity_v2 @p_agreement_no = @p_agreement_no	-- nvarchar(50)
										,@p_mod_by = @p_mod_by			-- nvarchar(50)

		select 'AFTER', * FROM IFINAMS.dbo.ASSET where CODE = @fa_code
		end

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