-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_asset_proceed]
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@status				nvarchar(20)
			,@company_code			nvarchar(50)
			,@asset_type			nvarchar(50)
			-- Asqal 12-Oct-2022 ket : for WOM (+)
			,@is_valid				int
			,@max_day				int
			,@purchase_date			datetime
			,@purchase_price		decimal(18,2)

	begin try -- 
		--if exists(select 1 from dbo.asset where code = @p_code and is_maintenance = '1')
		--begin
		--	if not exists(select 1 from dbo.asset_maintenance_schedule where asset_code = @p_code)
		--	begin
		--		set @msg = 'Please generate maintenance schedule first.';
		--		raiserror(@msg ,16,-1);	
		--	end
		--end


		select	@status				= dor.status
				,@company_code		= dor.company_code
				,@asset_type		= dor.type_code
				,@purchase_price	= dor.purchase_price
		from	dbo.asset dor
		where	dor.code = @p_code ;

		-- Asqal 12-Oct-2022 ket : for WOM to control back date based on setting (+) ====
		set @is_valid = dbo.xfn_date_validation(@purchase_date) ;

		select	@max_day = cast(value as int)
		from	dbo.sys_global_param
		where	code = 'MDT' ;

		if(@purchase_price = 0)
		begin
			set @msg = 'Purchase Price must be greater than 0.';
			raiserror(@msg ,16,-1);	
		end

		--if @is_valid = 0
		--begin
		--	set @msg = 'Transaki input back date maksimal tanggal ' + cast(@max_day as char(2)) + ' pada tiap bulan';

		--	raiserror(@msg, 16, -1) ;
		--end ;

		-- End of additional control ===================================================

		--if (@asset_type = 'ELCT')
		--begin

		--	if exists (SELECT 1 FROM dbo.ASSET_ELECTRONIC where ASSET_CODE = @p_code and MERK_CODE is null)
		--	begin
		--		set @msg = 'Please fill in the mandatory fields(Merk)';
		--		raiserror(@msg ,16,-1);
		--	end

		--	if exists (SELECT 1 FROM dbo.ASSET_ELECTRONIC where ASSET_CODE = @p_code and MODEL_CODE is null)
		--	begin
		--		set @msg = 'Please fill in the mandatory fields(Model)';
		--		raiserror(@msg ,16,-1);
		--	end

		--	if exists (SELECT 1 FROM dbo.ASSET_ELECTRONIC where ASSET_CODE = @p_code and TYPE_ITEM_CODE is null)
		--	begin
		--		set @msg = 'Please fill in the mandatory fields(Type)';
		--		raiserror(@msg ,16,-1);
		--	end

		--	if exists (SELECT 1 FROM dbo.ASSET_ELECTRONIC where ASSET_CODE = @p_code and SERIAL_NO is null)
		--	begin
		--		set @msg = 'Please fill in the mandatory fields(Serial No)';
		--		raiserror(@msg ,16,-1);
		--	end

		--end

		if (@asset_type = 'VHCL')
		begin

			--if exists (SELECT 1 FROM dbo.ASSET_VEHICLE where ASSET_CODE = @p_code and MERK_CODE is null)
			--begin
			--	set @msg = 'Please fill in the mandatory fields(Merk)';
			--	raiserror(@msg ,16,-1);
			--end

			--if exists (SELECT 1 FROM dbo.ASSET_VEHICLE where ASSET_CODE = @p_code and MODEL_CODE is null)
			--begin
			--	set @msg = 'Please fill in the mandatory fields(Model)';
			--	raiserror(@msg ,16,-1);
			--end

			--if exists (SELECT 1 FROM dbo.ASSET_VEHICLE where ASSET_CODE = @p_code and TYPE_ITEM_CODE is null)
			--begin
			--	set @msg = 'Please fill in the mandatory fields(Type)';
			--	raiserror(@msg ,16,-1);
			--end

			if exists (SELECT 1 FROM dbo.ASSET_VEHICLE where ASSET_CODE = @p_code and PLAT_NO is null)
			begin
				set @msg = 'Please fill in the mandatory field(Plat No)';
				raiserror(@msg ,16,-1);
			end

			if exists (SELECT 1 FROM dbo.ASSET_VEHICLE where ASSET_CODE = @p_code and CHASSIS_NO is null)
			begin
				set @msg = 'Please fill in the mandatory field(Chassis No)';
				raiserror(@msg ,16,-1);
			end

			if exists (SELECT 1 FROM dbo.ASSET_VEHICLE where ASSET_CODE = @p_code and ENGINE_NO is null)
			begin
				set @msg = 'Please fill in the mandatory field(Engine No)';
				raiserror(@msg ,16,-1);
			end

			--if exists (SELECT 1 FROM dbo.ASSET_VEHICLE where ASSET_CODE = @p_code and BPKB_NO is null)
			--begin
			--	set @msg = 'Please fill in the mandatory field(BPKB No)';
			--	raiserror(@msg ,16,-1);
			--end

			--if exists (SELECT 1 FROM dbo.ASSET_VEHICLE where ASSET_CODE = @p_code and STNK_EXPIRED_DATE is null)
			--begin
			--	set @msg = 'Please fill in the mandatory field(STNK Expired Date)';
			--	raiserror(@msg ,16,-1);
			--end

			--if exists (SELECT 1 FROM dbo.ASSET_VEHICLE where ASSET_CODE = @p_code and BUILT_YEAR is null)
			--begin
			--	set @msg = 'Please fill in the mandatory field(Built Year)';
			--	raiserror(@msg ,16,-1);
			--end

		end

		--if (@asset_type = 'MCHN')
		--begin

		--	if exists (SELECT 1 FROM dbo.ASSET_MACHINE where ASSET_CODE = @p_code and MERK_CODE is null)
		--	begin
		--		set @msg = 'Please fill in the mandatory fields(Merk)';
		--		raiserror(@msg ,16,-1);
		--	end

		--	if exists (SELECT 1 FROM dbo.ASSET_MACHINE where ASSET_CODE = @p_code and MODEL_CODE is null)
		--	begin
		--		set @msg = 'Please fill in the mandatory fields(Model)';
		--		raiserror(@msg ,16,-1);
		--	end

		--	if exists (SELECT 1 FROM dbo.ASSET_MACHINE where ASSET_CODE = @p_code and TYPE_ITEM_CODE is null)
		--	begin
		--		set @msg = 'Please fill in the mandatory fields(Type)';
		--		raiserror(@msg ,16,-1);
		--	end

		--end
------------------------------------------------------------------------------------------------
		-- if (@status IN ('HOLD','ONGRN'))
		-- BEGIN

		-- 		if(@status = 'ONGRN') -- (14042025: SEPRIA - TAMBAH KONDISI INI JIKA ASSET TERBENTUK DARI GRN TP BELUM FGRN
		-- 		begin
		-- 		    update	dbo.asset
		-- 			set		status			= 'ON PROCESS'
		-- 					,is_final_grn	= '0'
		-- 					,is_lock		= '1'
		-- 					--
		-- 					,mod_date		= @p_mod_date
		-- 					,mod_by			= @p_mod_by
		-- 					,mod_ip_address = @p_mod_ip_address
		-- 			where	code			= @p_code ;
		-- 		end
        --         else
        --         begin
		-- 			update	dbo.asset
		-- 			set		status			= 'ON PROCESS'
		-- 					,is_lock		= '1'
		-- 					,is_final_grn	= '1'
		-- 					--
		-- 					,mod_date		= @p_mod_date
		-- 					,mod_by			= @p_mod_by
		-- 					,mod_ip_address = @p_mod_ip_address
		-- 			where	code			= @p_code ;
        --         end

				if (@status = 'HOLD')
		begin

			    update	dbo.asset
				set		status			= 'ON PROCESS'
						,is_lock		= '1'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code			= @p_code ;
------------------------------------------------------------------------------------------------
			-- send mail attachment based on setting ================================================
			--exec dbo.xsp_master_email_notification_broadcast @p_code			= 'APRQTR'
			--												,@p_doc_code		= @p_code
			--												,@p_attachment_flag = 0
			--												,@p_attachment_file = ''
			--												,@p_attachment_path = ''
			--												,@p_company_code	= @company_code
			--												,@p_trx_no			= @p_code
			--												,@p_trx_type		= 'ASET'
			-- End of send mail attachment based on setting ================================================

		end
		else
		begin
			set @msg = 'Data Already Proceed.';
			raiserror(@msg ,16,-1);
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
