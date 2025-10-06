CREATE PROCEDURE [dbo].[xsp_application_asset_allocation_proceed]
	@p_asset_no					nvarchar(50) 
	,@p_agreement_no			nvarchar(50)
	,@p_agreement_external_no	nvarchar(50)
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
as
begin
	declare @msg					 nvarchar(max)
			,@handover_code			 nvarchar(50)
			,@year					 nvarchar(2)
			,@month					 nvarchar(2)
			,@code					 nvarchar(50)
			,@purchase_request_code	 nvarchar(50)
			,@branch_code			 nvarchar(50)
			,@branch_name			 nvarchar(250)
			,@status				 nvarchar(15)  = N'HOLD'
			,@transaction_date		 datetime	   = dbo.xfn_get_system_date()
			,@type					 nvarchar(15)  = N'DELIVERY'
			,@remark				 nvarchar(4000)
			,@description			 nvarchar(4000)
			,@fa_code				 nvarchar(50)
			,@fa_name				 nvarchar(250)
			,@handover_from			 nvarchar(250) = N'INTERNAL'
			,@handover_to			 nvarchar(250)
			,@handover_address		 nvarchar(4000)
			,@handover_phone_area	 nvarchar(5)
			,@handover_phone_no		 nvarchar(15)
			,@handover_eta_date		 datetime
			,@unit_condition		 nvarchar(250)
			,@application_no		 nvarchar(50)
			,@reff_no				 nvarchar(50)
			,@reff_name				 nvarchar(50)
			,@mobilisasi_amount		 decimal(18, 2)
			,@is_gts				 nvarchar(1)
			,@agreement_external_no	 nvarchar(50)
			,@agreement_no			 nvarchar(50)
			,@asset_no				 nvarchar(50)
			,@client_no				 nvarchar(50)
			,@client_name			 nvarchar(250)
			,@bbn_location			 nvarchar(250)
			,@fa_category_code		 nvarchar(50)
			,@fa_category_name		 nvarchar(250)
			,@fa_merk_code			 nvarchar(50)
			,@fa_merk_name			 nvarchar(250)
			,@fa_model_code			 nvarchar(50)
			,@fa_model_name			 nvarchar(250)
			,@fa_type_code			 nvarchar(50)
			,@fa_type_name			 nvarchar(250)
			,@remark_continue_rental nvarchar(4000) 
			,@asset_type_code		 nvarchar(50);

	begin try
		if exists
		(
			select	1
			from	dbo.application_asset
			where	asset_no				= @p_asset_no
					and isnull(fa_code, isnull(replacement_fa_code, '')) = ''
		)
		begin
			set @msg = N'Please Select Fixed Asset, Asset No : ' + @p_asset_no ;

			raiserror(@msg, 16, -1) ;
		end 

		select	@branch_code			 = am.branch_code
				,@branch_name			 = am.branch_name
				,@remark				 = 'Pengiriman Unit Sewa Untuk Application : ' + am.application_external_no + ' - ' + cm.client_name + '. Asset ' + isnull(mvu.description, isnull(mhu.description, isnull(mmu.description, meu.description)))
				,@remark_continue_rental = 'No Need To Delivery Unit Sewa Untuk Application : ' + am.application_external_no + ' - ' + cm.client_name + '. Asset ' + isnull(mvu.description, isnull(mhu.description, isnull(mmu.description, meu.description)))
				,@description			 = 'Mobilisasi Unit Sewa Untuk Application : ' + am.application_external_no + ' - ' + cm.client_name + '. Asset ' + isnull(mvu.description, isnull(mhu.description, isnull(mmu.description, meu.description))) + ' Mobilization to ' + aa.mobilization_city_description + ' ' + aa.mobilization_province_description
				,@fa_code				 = isnull(aa.replacement_fa_code, aa.fa_code)
				,@fa_name				 = isnull(aa.replacement_fa_name, aa.fa_name)
				,@handover_to			 = aa.deliver_to_name
				,@unit_condition		 = aa.asset_condition 
				,@application_no		 = aa.application_no
				,@handover_address		 = aa.deliver_to_address
				,@handover_phone_area	 = aa.deliver_to_area_no
				,@handover_phone_no		 = aa.deliver_to_phone_no
				,@handover_eta_date		 = aa.request_delivery_date
				,@reff_no				 = aa.asset_no
				,@reff_name				 = aa.asset_name
				,@mobilisasi_amount		 = aa.mobilization_amount
				,@agreement_external_no	 = am.agreement_external_no
				,@client_name			 = am.client_name
				,@client_no				 = cm.client_no
				,@bbn_location			 = aa.bbn_location_description
				,@agreement_no			 = am.agreement_no
				,@is_gts				 = aa.is_request_gts
				,@asset_type_code        = aa.asset_type_code
		from	dbo.application_asset aa
				inner join dbo.application_main am on (am.application_no		= aa.application_no)
				inner join dbo.client_main cm on (cm.code						= am.client_code)
				left join dbo.application_asset_vehicle asv on (asv.asset_no	= aa.asset_no)
				left join dbo.master_vehicle_unit mvu on (mvu.code				= asv.vehicle_unit_code)
				left join dbo.application_asset_he aah on (aah.asset_no			= aa.asset_no)
				left join dbo.master_he_unit mhu on (mhu.code					= aah.he_unit_code)
				left join dbo.application_asset_machine aam on (aam.asset_no	= aa.asset_no)
				left join dbo.master_machinery_unit mmu on (mmu.code			= aam.machinery_unit_code)
				left join dbo.application_asset_electronic aae on (aae.asset_no = aa.asset_no)
				left join dbo.master_electronic_unit meu on (meu.code			= aae.electronic_unit_code)
		where	aa.asset_no = @p_asset_no
		

		--set Remark jika continue Rental
		if exists
		(
			select	1
			from	ifinams.dbo.asset a 
			where	a.code	= @fa_code
					and isnull(a.re_rent_status, '') = 'CONTINUE' 
		)
		begin
			 set @remark = @remark_continue_rental
		end ;

		--process purchase request untuk mobilisasi
		begin
			if exists (select 1 from dbo.application_asset where asset_no = @p_asset_no and isnull(fa_code, '') <> '')
			begin
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
														 ,@p_asset_no			= @p_asset_no
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
			end
		end
		

		exec dbo.xsp_opl_interface_handover_asset_insert @p_code					= @handover_code output
														 ,@p_branch_code			= @branch_code
														 ,@p_branch_name			= @branch_name
														 ,@p_status					= @status
														 ,@p_transaction_date		= @transaction_date
														 ,@p_type					= @type
														 ,@p_remark					= @remark
														 ,@p_fa_code				= @fa_code
														 ,@p_fa_name				= @fa_name
														 ,@p_handover_from			= @handover_from
														 ,@p_handover_to			= @handover_to
														 ,@p_handover_address		= @handover_address  
														 ,@p_handover_phone_area	= @handover_phone_area
														 ,@p_handover_phone_no		= @handover_phone_no 
														 ,@p_handover_eta_date		= @handover_eta_date 
														 ,@p_unit_condition			= @unit_condition
														 ,@p_reff_no				= @reff_no
														 ,@p_reff_name				= @reff_name
														 ,@p_agreement_external_no	= @p_agreement_external_no	
														 ,@p_agreement_no			= @p_agreement_no
														 ,@p_asset_no				= @p_asset_no
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
		-- integrasi budget insurance ke ams
		insert into dbo.opl_interface_asset_insurance_for_ams
		(
			asset_no
			,main_coverage_code
			,main_coverage_description
			,region_code
			,region_description
			,main_coverage_premium_amount
			,is_use_tpl
			,tpl_coverage_code
			,tpl_coverage_description
			,tpl_premium_amount
			,is_use_pll
			,pll_coverage_code
			,pll_coverage_description
			,pll_premium_amount
			,is_use_pa_passenger
			,pa_passenger_amount
			,pa_passenger_seat
			,pa_passenger_premium_amount
			,is_use_pa_driver
			,pa_driver_amount
			,pa_driver_premium_amount
			,is_use_srcc
			,srcc_premium_amount
			,is_use_ts
			,ts_premium_amount
			,is_use_flood
			,flood_premium_amount
			,is_use_earthquake
			,earthquake_premium_amount
			,is_commercial_use
			,commercial_premium_amount
			,is_authorize_workshop
			,authorize_workshop_premium_amount
			,total_premium_amount
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
			,is_tbod
			,tbod_premium_amount
			,asset_code
		)
		select aid.asset_no
			  ,main_coverage_code
			  ,main_coverage_description
			  ,region_code
			  ,region_description
			  ,main_coverage_premium_amount
			  ,is_use_tpl
			  ,tpl_coverage_code
			  ,tpl_coverage_description
			  ,tpl_premium_amount
			  ,is_use_pll
			  ,pll_coverage_code
			  ,pll_coverage_description
			  ,pll_premium_amount
			  ,is_use_pa_passenger
			  ,pa_passenger_amount
			  ,pa_passenger_seat
			  ,pa_passenger_premium_amount
			  ,is_use_pa_driver
			  ,pa_driver_amount
			  ,pa_driver_premium_amount
			  ,is_use_srcc
			  ,srcc_premium_amount
			  ,is_use_ts
			  ,ts_premium_amount
			  ,is_use_flood
			  ,flood_premium_amount
			  ,is_use_earthquake
			  ,earthquake_premium_amount
			  ,is_commercial_use
			  ,commercial_premium_amount
			  ,is_authorize_workshop
			  ,authorize_workshop_premium_amount
			  ,total_premium_amount
			  ,@p_mod_date
			  ,@p_mod_by
			  ,@p_mod_ip_address
			  ,@p_mod_date
			  ,@p_mod_by
			  ,@p_mod_ip_address
			  ,is_tbod
			  ,tbod_premium_amount
			  ,isnull(aa.fa_code,aa.replacement_fa_code)
		from dbo.asset_insurance_detail aid
		inner join dbo.application_asset aa on aid.asset_no = aa.asset_no
		where aid.asset_no = @p_asset_no

		if (@is_gts = '1')
		begin
			update	dbo.application_asset
			set		purchase_gts_status = 'DELIVERY'
					,asset_status		= 'DELIVERY' -- Louis Selasa, 08 Juli 2025 10.44.51 -- 
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	asset_no			= @p_asset_no ;
		end
		else
		begin
			update	dbo.application_asset
			set		purchase_status = 'DELIVERY'
					,asset_status	= 'DELIVERY' -- Louis Selasa, 08 Juli 2025 10.44.51 -- 
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	asset_no		= @p_asset_no ;
		end
		
		-- Louis Selasa, 08 Juli 2025 10.32.39 -- 
		-- insert application log
		begin
		
			declare @unit_desc nvarchar(4000)
					,@remark_log nvarchar(4000)
					,@id bigint

			if (@asset_type_code = 'VHCL') --jika asset type nya vehicle
			begin
				select	@unit_desc = mvu.description
				from	dbo.application_asset_vehicle aav
						left join dbo.master_vehicle_unit mvu on (mvu.code		  = aav.vehicle_unit_code)
				where	aav.asset_no = @p_asset_no ;
			end ;
			else if (@asset_type_code = 'ELEC') --jika type asset nya electric
			begin
				select	@unit_desc = meu.description 
				from	application_asset_electronic aae
						left join dbo.master_electronic_unit meu on (meu.code		 = aae.electronic_unit_code)
				where	aae.asset_no = @p_asset_no ;
			end ;
			else if (@asset_type_code = 'HE') --jika type asset nya heavy equipment
			begin
				select	@unit_desc = mhu.description
				from	dbo.application_asset_he aah
						left join master_he_unit mhu on (mhu.code		 = aah.he_unit_code)
				where	aah.asset_no = @p_asset_no ;
			end ;
			else if (@asset_type_code = 'MCHN') --jika type asset nya machine
			begin
				select	@unit_desc = mmu.description
				from	dbo.application_asset_machine aam
						left join master_machinery_unit mmu on (mmu.code		= aam.machinery_unit_code)
				where	aam.asset_no = @p_asset_no ;
			end ;

			set @remark_log = 'Delivery Asset : ' + @p_asset_no + ' ' + @unit_desc;

			exec dbo.xsp_application_log_insert @p_id				= @id output 
												,@p_application_no	= @application_no
												,@p_log_date		= @p_mod_date
												,@p_log_description	= @remark_log
												,@p_cre_date		= @p_mod_date	  
												,@p_cre_by			= @p_mod_by		  
												,@p_cre_ip_address	= @p_mod_ip_address
												,@p_mod_date		= @p_mod_date	  
												,@p_mod_by			= @p_mod_by		  
												,@p_mod_ip_address	= @p_mod_ip_address
		end
		-- Louis Selasa, 08 Juli 2025 10.32.39 -- 
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





