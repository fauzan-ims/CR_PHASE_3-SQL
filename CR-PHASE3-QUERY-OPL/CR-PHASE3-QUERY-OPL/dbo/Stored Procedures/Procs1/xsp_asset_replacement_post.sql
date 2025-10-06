CREATE PROCEDURE dbo.xsp_asset_replacement_post
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
			,@agreement_no			nvarchar(50)
			,@date					datetime
			,@remark				nvarchar(4000)
			,@old_asset_no			nvarchar(50)
			,@new_fa_code			nvarchar(50)
			,@new_fa_name			nvarchar(250)
			,@replacement_type		nvarchar(50)
			,@estimate_return_date	datetime
			,@system_date			datetime
			,@old_fa_name			nvarchar(250)
			,@old_fa_code			nvarchar(50)
			,@code					nvarchar(50)
			,@client_name			nvarchar(250)
			,@remark_old			nvarchar(4000)
			,@remark_new			nvarchar(4000)
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)
			,@handover_address		nvarchar(4000)
			,@handover_phone_area	nvarchar(5)
			,@handover_phone_no		nvarchar(15)
			,@agreement_external_no	nvarchar(50)
			,@client_no				nvarchar(50)
			,@bbn_location			nvarchar(250)
			--
			,@purchase_request_code	 nvarchar(50)
			,@fa_category_code		 nvarchar(50)
			,@fa_category_name		 nvarchar(250)
			,@fa_merk_code			 nvarchar(50)
			,@fa_merk_name			 nvarchar(250)
			,@fa_model_code			 nvarchar(50)
			,@fa_model_name			 nvarchar(250)
			,@fa_type_code			 nvarchar(50)
			,@fa_type_name			 nvarchar(250)
			,@transaction_date		 datetime	   = dbo.xfn_get_system_date()
			,@mobilisasi_amount		 decimal(18, 2)
			,@description			 nvarchar(4000)
			,@plat_list				 nvarchar(MAX)

			-- Alif 26/08/2025
			IF EXISTS (
			SELECT 1
			FROM dbo.asset_replacement_detail ARD
			JOIN dbo.asset_replacement AR ON AR.CODE = ARD.replacement_code
			LEFT JOIN IFINAMS.dbo.asset_vehicle AV_NEW ON AV_NEW.asset_code = ARD.new_fa_code
			LEFT JOIN dbo.agreement_asset AA ON AA.asset_no = ARD.old_asset_no
			WHERE ARD.replacement_code = @p_code
			  AND (
					AV_NEW.PLAT_NO IN (
						SELECT AV_SALE.PLAT_NO
						FROM IFINAMS.dbo.SALE S
						JOIN IFINAMS.dbo.SALE_DETAIL SD ON SD.SALE_CODE = S.CODE
						JOIN IFINAMS.dbo.ASSET_VEHICLE AV_SALE ON AV_SALE.ASSET_CODE = SD.ASSET_CODE
						WHERE S.STATUS IN ('hold', 'on process', 'approve')
					)
					OR
					AA.fa_reff_no_01 IN (
						SELECT AV_SALE.PLAT_NO
						FROM IFINAMS.dbo.SALE S
						JOIN IFINAMS.dbo.SALE_DETAIL SD ON SD.SALE_CODE = S.CODE
						JOIN IFINAMS.dbo.ASSET_VEHICLE AV_SALE ON AV_SALE.ASSET_CODE = SD.ASSET_CODE
						WHERE S.STATUS IN ('hold', 'on process', 'approve')
					)
				)
		)
		BEGIN
			SELECT @plat_list = STRING_AGG(PLAT_NO, ', ')
			FROM (
				SELECT DISTINCT AV_NEW.PLAT_NO
				FROM dbo.asset_replacement_detail ARD
				JOIN dbo.asset_replacement AR ON AR.CODE = ARD.replacement_code
				LEFT JOIN IFINAMS.dbo.asset_vehicle AV_NEW ON AV_NEW.asset_code = ARD.new_fa_code
				LEFT JOIN dbo.agreement_asset AA ON AA.asset_no = ARD.old_asset_no
				WHERE ARD.replacement_code = @p_code
				  AND AV_NEW.PLAT_NO IN (
						SELECT AV_SALE.PLAT_NO
						FROM IFINAMS.dbo.SALE S
						JOIN IFINAMS.dbo.SALE_DETAIL SD ON SD.SALE_CODE = S.CODE
						JOIN IFINAMS.dbo.ASSET_VEHICLE AV_SALE ON AV_SALE.ASSET_CODE = SD.ASSET_CODE
						WHERE S.STATUS IN ('hold', 'on process', 'approve')
					)
		
				UNION
		
				SELECT DISTINCT AA.fa_reff_no_01
				FROM dbo.asset_replacement_detail ARD
				JOIN dbo.asset_replacement AR ON AR.CODE = ARD.replacement_code
				LEFT JOIN IFINAMS.dbo.asset_vehicle AV_NEW ON AV_NEW.asset_code = ARD.new_fa_code
				LEFT JOIN dbo.agreement_asset AA ON AA.asset_no = ARD.old_asset_no
				WHERE ARD.replacement_code = @p_code
				  AND AA.fa_reff_no_01 IN (
						SELECT AV_SALE.PLAT_NO
						FROM IFINAMS.dbo.SALE S
						JOIN IFINAMS.dbo.SALE_DETAIL SD ON SD.SALE_CODE = S.CODE
						JOIN IFINAMS.dbo.ASSET_VEHICLE AV_SALE ON AV_SALE.ASSET_CODE = SD.ASSET_CODE
						WHERE S.STATUS IN ('hold', 'on process', 'approve')
					)
			) AS ResultList

			SET @msg = 'Assets In New Asset No Are In the Sales Request Process, For Plat No: ' + @plat_list;
			RAISERROR(@msg, 16, -1);
			RETURN;
		END;



	begin try
		set @system_date = dbo.xfn_get_system_date() ;

		 if exists (
						select	1 
						from	dbo.asset_replacement_detail
						where	replacement_code = @p_code
						and		(
										isnull(new_fa_code, '') = ''
										or isnull(new_fa_name, '') = ''
										or isnull(reason_code, '') = ''
										or isnull(replacement_type, '') = ''
										or (replacement_type IN ('TEMPORARY','MAINTENANCE') and estimate_return_date is null)
										or isnull(remark, '') = ''
									)
					)
		begin
			set @msg = 'Please Completed Asset Detail List' ;
			raiserror(@msg, 16, 1) ;
			RETURN;
        end

		-- Set agreement no      
		select	@agreement_no			= ar.agreement_no
				,@branch_code			= ar.branch_code
				,@branch_name			= ar.branch_name
				,@date					= ar.date
				,@remark				= ar.remark
				,@agreement_external_no	= am.agreement_external_no
		from	dbo.asset_replacement ar
		inner join dbo.agreement_main am on (am.agreement_no = ar.agreement_no)
		where	code = @p_code ;

		--update to table asset replacement
		if exists
		(
			select	1
			from	asset_replacement
			where	code = @p_code
					and status <> 'ON PROCESS'
		)
		begin
			set @msg = 'Data already Proceed.' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else
		begin
			update	dbo.asset_replacement
			set		status			= 'POST'
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @p_code ;
		end ;

		-- Looping asset replacement detail
		declare c_asset_replacement_detail cursor for
		select	old_asset_no
				,new_fa_code
				,new_fa_name
				,replacement_type
				,estimate_return_date
		from	dbo.asset_replacement_detail
		where	replacement_code = @p_code ;

		open c_asset_replacement_detail ;

		fetch c_asset_replacement_detail
		into @old_asset_no
			 ,@new_fa_code
			 ,@new_fa_name
			 ,@replacement_type
			 ,@estimate_return_date ;

		while @@fetch_status = 0
		begin

			if (@replacement_type = 'PERMANENT')
			begin
				--insert old asset to opl_interface_handover_asset
				select		@client_name			= am.client_name
							,@client_no				= am.client_no
							,@old_fa_code			= isnull(ass.replacement_fa_code, ass.fa_code)
							,@old_fa_name			= isnull(ass.replacement_fa_name, ass.fa_name)
							,@handover_address		= ass.deliver_to_address
							,@handover_phone_area	= ass.deliver_to_area_no
							,@handover_phone_no		= ass.deliver_to_phone_no
							,@bbn_location			= ass.bbn_location_description
							,@mobilisasi_amount     = ass.mobilization_amount
							,@description			 = 'Mobilisasi Unit Sewa Untuk Agreement : ' + am.agreement_external_no + ' - ' + am.client_name + '. Asset ' + isnull(mvu.description, isnull(mhu.description, isnull(mmu.description, meu.description))) + ' Mobilization to ' + ass.mobilization_city_description + ' ' + ass.mobilization_province_description
				from		dbo.agreement_main am
				inner join	dbo.agreement_asset	ass on (ass.agreement_no		= am.agreement_no)
				left join dbo.agreement_asset_vehicle asv on (asv.asset_no		= ass.asset_no)
				left join dbo.master_vehicle_unit mvu on (mvu.code				= asv.vehicle_unit_code)
				left join dbo.agreement_asset_he aah on (aah.asset_no			= ass.asset_no)
				left join dbo.master_he_unit mhu on (mhu.code					= aah.he_unit_code)
				left join dbo.agreement_asset_machine aam on (aam.asset_no		= ass.asset_no)
				left join dbo.master_machinery_unit mmu on (mmu.code			= aam.machinery_unit_code)
				left join dbo.agreement_asset_electronic aae on (aae.asset_no	= ass.asset_no)
				left join dbo.master_electronic_unit meu on (meu.code			= aae.electronic_unit_code)
				where		ass.asset_no = @old_asset_no
				
				if (@mobilisasi_amount > 0)
				begin
					select top 1
							@fa_category_code		= mvu.vehicle_category_code
							,@fa_category_name		= mvc.description
							,@fa_merk_code			= mvu.vehicle_merk_code
							,@fa_merk_name			= mvm.description
							,@fa_model_code			= mvu.vehicle_model_code
							,@fa_model_name			= mvmo.description
							,@fa_type_code			= mvu.vehicle_type_code
							,@fa_type_name			= mvt.description
					from	dbo.master_vehicle_unit mvu
						left join dbo.master_vehicle_category mvc on (mvc.code	  = mvu.vehicle_category_code)
						left join dbo.master_vehicle_merk mvm on (mvm.code		  = mvu.vehicle_merk_code)
						left join dbo.master_vehicle_model mvmo on (mvmo.code	  = mvu.vehicle_model_code)
						left join dbo.master_vehicle_type mvt on (mvt.code		  = mvu.vehicle_type_code)
					where	category_type			= 'MOBILISASI' ;

					exec dbo.xsp_purchase_request_insert @p_code				= @purchase_request_code output
														 ,@p_asset_no			= @old_asset_no
														 ,@p_branch_code		= @branch_code
														 ,@p_branch_name		= @branch_name
														 ,@p_request_date		= @transaction_date
														 ,@p_request_status		= 'HOLD'
														 ,@p_description		= @description
														 ,@p_fa_category_code	= @fa_category_code		
														 ,@p_fa_category_name	= @fa_category_name	
														 ,@p_fa_merk_code		= @fa_merk_code		
														 ,@p_fa_merk_name		= @fa_merk_name		
														 ,@p_fa_model_code		= @fa_model_code		
														 ,@p_fa_model_name		= @fa_model_name		
														 ,@p_fa_type_code		= @fa_type_code		
														 ,@p_fa_type_name		= @fa_type_name		
														 ,@p_result_fa_code		= null
														 ,@p_result_fa_name		= null
														 ,@p_result_date		= null
														 ,@p_unit_from			= 'BUY'
														 ,@p_category_type		= 'MOBILISASI'
														 --
														 ,@p_cre_date			= @p_mod_date		
														 ,@p_cre_by				= @p_mod_by			
														 ,@p_cre_ip_address		= @p_mod_ip_address	
														 ,@p_mod_date			= @p_mod_date		
														 ,@p_mod_by				= @p_mod_by			
														 ,@p_mod_ip_address		= @p_mod_ip_address	

					exec dbo.xsp_purchase_request_post @p_code				= @purchase_request_code
													   ,@p_mod_date			= @p_mod_date		
													   ,@p_mod_by			= @p_mod_by			
													   ,@p_mod_ip_address	= @p_mod_ip_address
				end

				set @remark_old = 'Penarikan pengantian Unit Sewa Untuk Kontrak : ' + isnull(@agreement_external_no, '') + ' - ' + isnull(@client_name, '') + '. dari Asset ' + isnull(@old_fa_code, '') + ' - ' + isnull(@old_fa_name, '') + ' menjadi ' + isnull(@new_fa_code, '') + ' - ' + isnull(@new_fa_name, '') ;

				exec dbo.xsp_opl_interface_handover_asset_insert @p_code					= @code output
																 ,@p_branch_code			= @branch_code
																 ,@p_branch_name			= @branch_name
																 ,@p_status					= 'HOLD'
																 ,@p_transaction_date		= @system_date
																 ,@p_type					= 'REPLACE GTS IN'
																 ,@p_remark					= @remark_old
																 ,@p_fa_code				= @old_fa_code
																 ,@p_fa_name				= @old_fa_name
																 ,@p_handover_from			= @client_name
																 ,@p_handover_to			= 'INTERNAL'
																 ,@p_handover_address		= @handover_address  
																 ,@p_handover_phone_area	= @handover_phone_area
																 ,@p_handover_phone_no		= @handover_phone_no 
																 ,@p_handover_eta_date		= @date 
																 ,@p_unit_condition			= ''
																 ,@p_reff_no				= @p_code
																 ,@p_reff_name				= 'ASSET REPLACEMENT'
																 ,@p_agreement_external_no	= @agreement_external_no
																 ,@p_agreement_no			= @agreement_no
																 ,@p_asset_no				= @old_asset_no
																 ,@p_client_no				= @client_no
																 ,@p_client_name			= @client_name
																 ,@p_bbn_location			= @bbn_location
																 --						 
																 ,@p_cre_date				= @p_mod_date
																 ,@p_cre_by					= @p_mod_by
																 ,@p_cre_ip_address			= @p_mod_ip_address
																 ,@p_mod_date				= @p_mod_date
																 ,@p_mod_by					= @p_mod_by
																 ,@p_mod_ip_address			= @p_mod_ip_address ;

				--insert new asset to opl_interface_handover_asset

				set @remark_new = 'Pengiriman pengantian Unit Sewa Untuk Kontrak : ' + isnull(@agreement_external_no, '') + ' - ' + isnull(@client_name, '') + '. dari Asset ' + isnull(@old_fa_code, '') + ' - ' + isnull(@old_fa_name, '') + ' menjadi ' + isnull(@new_fa_code, '') + ' - ' + isnull(@new_fa_name, '') ;

				exec dbo.xsp_opl_interface_handover_asset_insert @p_code					= @code output
																 ,@p_branch_code			= @branch_code
																 ,@p_branch_name			= @branch_name
																 ,@p_status					= 'HOLD'
																 ,@p_transaction_date		= @date
																 ,@p_type					= 'REPLACE GTS OUT'
																 ,@p_remark					= @remark_new
																 ,@p_fa_code				= @new_fa_code
																 ,@p_fa_name				= @new_fa_name
																 ,@p_handover_from			= 'INTERNAL'
																 ,@p_handover_to			= @client_name
																 ,@p_handover_address		= @handover_address  
																 ,@p_handover_phone_area	= @handover_phone_area
																 ,@p_handover_phone_no		= @handover_phone_no 
																 ,@p_handover_eta_date		= @system_date 
																 ,@p_unit_condition			= ''
																 ,@p_reff_no				= @p_code
																 ,@p_reff_name				= 'ASSET REPLACEMENT'
																 ,@p_agreement_external_no	= @agreement_external_no
																 ,@p_agreement_no			= @agreement_no
																 ,@p_asset_no				= @old_asset_no
																 ,@p_client_no				= @client_no
																 ,@p_client_name			= @client_name
																 ,@p_bbn_location			= @bbn_location
																 --
																 ,@p_cre_date				= @p_mod_date
																 ,@p_cre_by					= @p_mod_by
																 ,@p_cre_ip_address			= @p_mod_ip_address
																 ,@p_mod_date				= @p_mod_date
																 ,@p_mod_by					= @p_mod_by
																 ,@p_mod_ip_address			= @p_mod_ip_address ;
			end
			else
			begin
				--insert old asset to opl_interface_handover_asset
				select		@old_fa_name			= isnull(ass.fa_name, ass.replacement_fa_name)
							,@client_no				= am.client_no
							,@client_name			= am.client_name
							,@old_fa_code			= isnull(ass.fa_code, ass.replacement_fa_code)
							,@handover_address		= ass.deliver_to_address
							,@handover_phone_area	= ass.deliver_to_area_no
							,@handover_phone_no		= ass.deliver_to_phone_no
							,@bbn_location			= ass.bbn_location_description
				from		dbo.agreement_main am
				inner join	dbo.agreement_asset	ass on (ass.agreement_no = am.agreement_no)
				where		ass.asset_no = @old_asset_no

				set @remark_old = 'Penarikan pengantian Unit Sewa Untuk Kontrak : ' + isnull(@agreement_external_no, '') + ' - ' + isnull(@client_name, '') + '. dari Asset ' + isnull(@old_fa_code, '') + ' - ' + isnull(@old_fa_name, '') + ' menjadi ' + isnull(@new_fa_code, '') + ' - ' + isnull(@new_fa_name, '') ;

				exec dbo.xsp_opl_interface_handover_asset_insert @p_code					= @code output
																 ,@p_branch_code			= @branch_code
																 ,@p_branch_name			= @branch_name
																 ,@p_status					= 'HOLD'
																 ,@p_transaction_date		= @date
																 ,@p_type					= 'REPLACE IN'
																 ,@p_remark					= @remark_old
																 ,@p_fa_code				= @old_fa_code
																 ,@p_fa_name				= @old_fa_name
																 ,@p_handover_from			= @client_name
																 ,@p_handover_to			= 'INTERNAL'
																 ,@p_handover_address		= @handover_address  
																 ,@p_handover_phone_area	= @handover_phone_area
																 ,@p_handover_phone_no		= @handover_phone_no 
																 ,@p_handover_eta_date		= @system_date 
																 ,@p_unit_condition			= ''
																 ,@p_reff_no				= @p_code
																 ,@p_reff_name				= 'ASSET REPLACEMENT'
																 ,@p_agreement_external_no	= @agreement_external_no
																 ,@p_agreement_no			= @agreement_no
																 ,@p_asset_no				= @old_asset_no
																 ,@p_client_no				= @client_no
																 ,@p_client_name			= @client_name
																 ,@p_bbn_location			= @bbn_location
																 --						 
																 ,@p_cre_date				= @p_mod_date
																 ,@p_cre_by					= @p_mod_by
																 ,@p_cre_ip_address			= @p_mod_ip_address
																 ,@p_mod_date				= @p_mod_date
																 ,@p_mod_by					= @p_mod_by
																 ,@p_mod_ip_address			= @p_mod_ip_address ;

				--insert new asset to opl_interface_handover_asset

				set @remark_new = 'Pengiriman pengantian Unit Sewa Untuk Kontrak : ' + isnull(@agreement_external_no, '') + ' - ' + isnull(@client_name, '') + '. dari Asset ' + isnull(@old_fa_code, '') + ' - ' + isnull(@old_fa_name, '') + ' menjadi ' + isnull(@new_fa_code, '') + ' - ' + isnull(@new_fa_name, '') ;

				exec dbo.xsp_opl_interface_handover_asset_insert @p_code					= @code output
																 ,@p_branch_code			= @branch_code
																 ,@p_branch_name			= @branch_name
																 ,@p_status					= 'HOLD'
																 ,@p_transaction_date		= @date
																 ,@p_type					= 'REPLACE OUT'
																 ,@p_remark					= @remark_new
																 ,@p_fa_code				= @new_fa_code
																 ,@p_fa_name				= @new_fa_name
																 ,@p_handover_from			= 'INTERNAL'
																 ,@p_handover_to			= @client_name
																 ,@p_handover_address		= @handover_address  
																 ,@p_handover_phone_area	= @handover_phone_area
																 ,@p_handover_phone_no		= @handover_phone_no 
																 ,@p_handover_eta_date		= @system_date 
																 ,@p_unit_condition			= ''
																 ,@p_reff_no				= @p_code
																 ,@p_reff_name				= 'ASSET REPLACEMENT'
																 ,@p_agreement_external_no	= @agreement_external_no
																 ,@p_agreement_no			= @agreement_no
																 ,@p_asset_no				= @old_asset_no
																 ,@p_client_no				= @client_no
																 ,@p_client_name			= @client_name
																 ,@p_bbn_location			= @bbn_location
																 --
																 ,@p_cre_date				= @p_mod_date
																 ,@p_cre_by					= @p_mod_by
																 ,@p_cre_ip_address			= @p_mod_ip_address
																 ,@p_mod_date				= @p_mod_date
																 ,@p_mod_by					= @p_mod_by
																 ,@p_mod_ip_address			= @p_mod_ip_address ;
			end

			--Update to table agreement asset
			--if (@replacement_type = 'PERMANENT')
			--begin
			--	update	dbo.agreement_asset
			--	set		fa_code					= @new_fa_code
			--			,fa_name				= @new_fa_name
			--			,asset_name				= @new_fa_name
			--			,replacement_fa_code	= null
			--			,replacement_fa_name	= null
			--			,replacement_end_date	= null
			--	where	agreement_no			= @agreement_no 
			--	and		asset_no				= @old_asset_no;
			--end ;
			--else
			--begin
			--	update	dbo.agreement_asset
			--	set		replacement_fa_code		= @new_fa_code
			--			,replacement_fa_name	= @new_fa_name
			--			,replacement_end_date	= @estimate_return_date
			--	where	agreement_no			= @agreement_no
			--	and		asset_no				= @old_asset_no ;

			--end ;

			--Update table agreement_asset_replacement													
			if exists
			(
				select	1
				from	agreement_asset_replacement_history
				where	asset_no	  = @old_asset_no
						and is_latest = '1'
			)
			begin
				update	dbo.agreement_asset_replacement_history
				set		is_latest	  = '0'
				where	asset_no	  = @old_asset_no
						and is_latest = '1' ;
			end ;

			--insert to table agreement asset replacement history
			insert into dbo.agreement_asset_replacement_history
			(
				asset_no
				,new_fixed_asset_code
				,new_fixed_asset_name
				,replacement_code
				,replacement_date
				,is_latest
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			values
			(	@old_asset_no
				,case when @replacement_type = 'PERMANENT' then @old_fa_code else @new_fa_code end
				,case when @replacement_type = 'PERMANENT' then @old_fa_name else @new_fa_name end
				,@p_code
				,@date
				,'1'
				--
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
			) ;

			--Insert to table agreement log
			insert into dbo.agreement_log
			(
				agreement_no
				,asset_no
				,log_source_no
				,log_date
				,log_remarks
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			values
			(	
				@agreement_no
				,@old_asset_no
				,@p_code
				,@date
				,'Asset Replacement ' + @replacement_type + ' -With new Asset: ' + @new_fa_code + ' ' + @new_fa_name + ' ,Note: ' + @remark
				--
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
			) ;

			fetch c_asset_replacement_detail
			into @old_asset_no
				 ,@new_fa_code
				 ,@new_fa_name
				 ,@replacement_type
				 ,@estimate_return_date ;
		end ;

		close c_asset_replacement_detail ;
		deallocate c_asset_replacement_detail ;
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