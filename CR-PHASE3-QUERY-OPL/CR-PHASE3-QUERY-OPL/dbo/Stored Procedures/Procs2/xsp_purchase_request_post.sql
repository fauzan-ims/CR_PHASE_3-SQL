
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_purchase_request_post]
	@p_code as		   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
as
begin
	/*
	untuk melakukan permintaan pembelian, saat unit yang mau disewakan belum dimiliki
	sehingga melakukan request ke bagian procrument untuk agar di proses untuk pembelian asset
	*/
	declare @msg		nvarchar(max)
			,@asset_no	nvarchar(50)
			,@unit_code nvarchar(50)  = null
			,@unit_desc nvarchar(250) = null ;

	begin try

		select	@asset_no = asset_no 
		from	dbo.purchase_request
		where	code = @p_code ;

		--hanya boleh di post jika [REQUEST_STATUS] nya HOLD
		if exists
		(
			select	1
			from	dbo.purchase_request
			where	code			   = @p_code
					and request_status <> 'HOLD'
		)
		begin
			set @msg = N'Data already Proceed' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if exists
		(
			select	1
			from	dbo.purchase_request
			where	code			  = @p_code
					and categori_type = 'MOBILISASI'
		)
		begin
			select	@unit_code = code
					,@unit_desc = description
			from	dbo.master_vehicle_unit
			where	category_type = 'MOBILISASI' ;
		end

		if exists
		(
			select	1
			from	dbo.purchase_request
			where	code			  = @p_code
					and categori_type = 'GPS'
		)
		begin
			select	@unit_code = value
					,@unit_desc = description
			from	dbo.sys_global_param
			where	code = 'IS_USE_GPS' ; 
		end

		insert into dbo.opl_interface_purchase_request
		(
			code
			,branch_code
			,branch_name
			,request_date
			,request_status
			,description
			,marketing_code
			,marketing_name
			,fa_category_code
			,fa_category_name
			,fa_merk_code
			,fa_merk_name
			,fa_model_code
			,fa_model_name
			,fa_type_code
			,fa_type_name
			,fa_unit_code
			,fa_unit_name
			,result_fa_code
			,result_fa_name
			,result_date
			,fa_reff_no_01
			,fa_reff_no_02
			,fa_reff_no_03
			,fa_reff_no_04
			,fa_reff_no_05
			,fa_reff_no_06
			,fa_reff_no_07
			,unit_from
			,category_type
			,asset_no
			,spaf_amount
			,subvention_amount
			,mobilization_city_code				
			,mobilization_city_description		
			,mobilization_province_code			
			,mobilization_province_description
			,mobilization_fa_code
			,mobilization_fa_name
			,deliver_to_address
			,deliver_to_area_no
			,deliver_to_phone_no
			,settle_date
			,job_status
			,failed_remarks
			,asset_amount
			,asset_discount_amount
			,karoseri_amount
			,karoseri_discount_amount
			,accesories_amount
			,accesories_discount_amount
			,mobilization_amount
			,application_no
			,otr_amount
			,gps_amount
			,budget_amount
			,bbn_name
			,bbn_location
			,bbn_address
			,built_year
			,asset_colour
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	distinct
				pr.code
				,pr.branch_code
				,pr.branch_name
				,pr.request_date
				,pr.request_status
				,pr.description
				,am.marketing_code
				,am.marketing_name
				,pr.fa_category_code
				,pr.fa_category_name
				,pr.fa_merk_code
				,pr.fa_merk_name
				,pr.fa_model_code
				,pr.fa_model_name
				,pr.fa_type_code
				,pr.fa_type_name
				,isnull(@unit_code, isnull(mbc.item_code, isnull(aad.code, isnull(aav.vehicle_unit_code, isnull(aam.machinery_unit_code, isnull(aah.he_unit_code, aae.electronic_unit_code))))))
				,isnull(@unit_desc, isnull(mbc.item_description, isnull(aad.description, isnull(mvu.description, isnull(mmu.description, isnull(mhu.description, meu.description))))))
				,pr.result_fa_code
				,pr.result_fa_name
				,pr.result_date
				,fa_reff_no_01
				,fa_reff_no_02
				,fa_reff_no_03
				,aa.asset_year
				,aa.asset_condition
				,isnull(aae.colour, isnull(aah.colour, isnull(aam.colour, aav.colour)))
				,aav.transmisi
				,pr.unit_from
				,pr.categori_type
				,pr.asset_no
				,aa.spaf_amount
				,aa.subvention_amount
				,aa.mobilization_city_code				
				,aa.mobilization_city_description		
				,aa.mobilization_province_code			
				,aa.mobilization_province_description
				,isnull(aa.fa_code, aa.replacement_fa_code)
				,isnull(aa.fa_name, aa.replacement_fa_name)
				,aa.deliver_to_address
				,aa.deliver_to_area_no
				,aa.deliver_to_phone_no
				,null
				,'HOLD'
				,null
				,aa.market_value --aa.asset_amount
				,aa.discount_amount
				,aad.amount --aa.karoseri_amount
				,aa.discount_karoseri_amount
				,aad.amount --aa.accessories_amount
				,aa.discount_accessories_amount
				,aa.mobilization_amount
				,am.application_no
				,aa.otr_amount
				,aa.gps_installation_amount
				,aab.budget_amount
				,aa.client_bbn_name
				,aa.bbn_location_description
				,aa.client_bbn_address
				,aa.asset_year
				,aav.colour
				--
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.purchase_request pr
				left join dbo.application_asset aa on (aa.asset_no				= pr.asset_no)
				left join dbo.application_asset_detail aad on (aad.purchase_code = pr.code)
				left join dbo.application_asset_budget aab on (aab.purchase_code = pr.code)
				left join dbo.master_budget_cost mbc on (mbc.code = aab.cost_code)
				left join dbo.application_asset_vehicle aav on (aav.asset_no	= aa.asset_no)
				left join dbo.master_vehicle_unit mvu on (mvu.code				= aav.vehicle_unit_code)
				left join dbo.master_vehicle_unit mvu2 on (mvu2.code			= aad.code)
				left join dbo.application_asset_machine aam on (aam.asset_no	= aa.asset_no)
				left join dbo.master_machinery_unit mmu on (mmu.code			= aam.machinery_unit_code)
				left join dbo.application_asset_he aah on (aah.asset_no			= aa.asset_no)
				left join dbo.master_he_unit mhu on (mhu.code					= aah.he_unit_code)
				left join dbo.application_asset_electronic aae on (aae.asset_no = aa.asset_no)
				left join dbo.master_electronic_unit meu on (meu.code			= aae.electronic_unit_code)
				left join dbo.application_main am on (am.application_no			= aa.application_no)
		where	pr.asset_no			= @asset_no
		and		pr.request_status	= 'HOLD'

		update	dbo.purchase_request
		set		request_status		= 'ON PROCESS'
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	asset_no			= @asset_no
		and		request_status		= 'HOLD'

		--(+) menambahkan otomatis post allocation ketika purchase	-- Louis Kamis, 07 September 2023 17.29.12 --
		if exists
		(
			select	1
			from	dbo.purchase_request
			where	code			  = @p_code
					and categori_type = 'ASSET'
		)
		begin
			exec dbo.xsp_application_asset_allocation_post @p_asset_no		  = @asset_no
														   ,@p_mod_date		  = @p_mod_date
														   ,@p_mod_by		  = @p_mod_by
														   ,@p_mod_ip_address = @p_mod_ip_address ;
		end ;


		--Insert ke interface insurance asset
		insert into dbo.opl_interface_asset_insurance
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
		)
		select asset_no
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
		from dbo.asset_insurance_detail
		where asset_no = @asset_no

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

