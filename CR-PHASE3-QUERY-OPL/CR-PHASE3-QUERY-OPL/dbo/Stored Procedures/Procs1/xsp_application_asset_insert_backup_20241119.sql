create PROCEDURE [dbo].[xsp_application_asset_insert_backup_20241119]
(
	@p_asset_no								nvarchar(50)	output
	,@p_application_no						nvarchar(50)
	,@p_asset_type_code						nvarchar(50)
	,@p_asset_name							nvarchar(250)
	,@p_asset_year							nvarchar(4)
	,@p_asset_condition						nvarchar(5)
	,@p_billing_to							nvarchar(10)
	,@p_billing_to_name						nvarchar(250)	= ''
	,@p_billing_to_area_no					nvarchar(4)		= ''
	,@p_billing_to_phone_no					nvarchar(15)	= ''
	,@p_billing_to_address					nvarchar(4000)	= ''
	,@p_billing_mode						nvarchar(10)
	,@p_billing_mode_date					int
	,@p_billing_to_faktur_type				nvarchar(3)
	,@p_billing_to_npwp						nvarchar(20)	= ''
	,@p_npwp_name							nvarchar(250)	= ''
	,@p_npwp_address						nvarchar(4000)	= ''
	,@p_deliver_to							nvarchar(10)
	,@p_deliver_to_name						nvarchar(250)	= ''
	,@p_deliver_to_area_no					nvarchar(4)		= ''
	,@p_deliver_to_phone_no					nvarchar(15)	= ''
	,@p_deliver_to_address					nvarchar(4000)	= ''
	,@p_pickup_phone_area_no				nvarchar(4)		= ''
	,@p_pickup_phone_no						nvarchar(15)	= ''
	,@p_pickup_name							nvarchar(50)	= ''
	,@p_pickup_address						nvarchar(4000)	= ''
	,@p_asset_amount						decimal(18, 2)	= 0
	,@p_asset_interest_rate					decimal(9, 6)	= 0
	,@p_asset_interest_amount				decimal(18, 2)	= 0
	,@p_asset_rv_pct						decimal(9, 6)	= 0
	,@p_asset_rv_amount						int				= 0
	,@p_cogs_amount							decimal(18, 2)	= 0
	,@p_basic_lease_amount					decimal(18, 2)	= 0
	,@p_margin_by							nvarchar(50)	= 'ALL'
	,@p_margin_rate							decimal(9, 6)	= 0
	,@p_margin_amount						decimal(18, 2)	= 0
	,@p_additional_charge_rate				decimal(9, 6)	= 0
	,@p_additional_charge_amount			decimal(18, 2)	= 0
	,@p_lease_amount						decimal(18, 2)	= 0
	,@p_net_margin_amount					decimal(18, 2)	= 0
	,@p_lease_rounded_amount				decimal(18, 2)	= 0
	,@p_category_code						nvarchar(50)	= null
	,@p_subcategory_code					nvarchar(50)	= null
	,@p_merk_code							nvarchar(50)	= null
	,@p_model_code							nvarchar(50)	= null
	,@p_type_code							nvarchar(50)	= null
	,@p_unit_code							nvarchar(50)	= null
	,@p_colour								nvarchar(250)	= null
	,@p_transmisi							nvarchar(250)	= null
	,@p_remarks								nvarchar(4000)	= null 
	,@p_fa_code								nvarchar(50)	= null 
	,@p_fa_name								nvarchar(250)	= null 
	,@p_karoseri_amount						decimal(18, 2)	= 0
	,@p_accessories_amount					decimal(18, 2)	= 0
	,@p_mobilization_amount					decimal(18, 2)	= 0
	,@p_fa_reff_no_01						nvarchar(250)	= null
	,@p_fa_reff_no_02						nvarchar(250)	= null
	,@p_fa_reff_no_03						nvarchar(250)	= null
	,@p_email								nvarchar(250)
	,@p_is_otr								nvarchar(1)
	,@p_bbn_location_code					nvarchar(50)	= null
	,@p_bbn_location_description			nvarchar(4000)	= null
	,@p_plat_colour							nvarchar(10)
	,@p_usage								nvarchar(10)
	,@p_start_miles							int
	,@p_monthly_miles						int
	,@p_request_delivery_date				datetime
	,@p_is_bbn_client						nvarchar(1)
	,@p_client_bbn_name						nvarchar(250)	= null
	,@p_client_bbn_address					nvarchar(4000)	= null
	,@p_mobilization_city_code			    nvarchar(50)	= null
	,@p_mobilization_city_description	    nvarchar(250)	= null
	,@p_mobilization_province_code		    nvarchar(50)	= null
	,@p_mobilization_province_description   nvarchar(250)	= null
	,@p_borrowing_interest_rate				decimal(9, 6)	= 0
	,@p_borrowing_interest_amount			decimal(18, 2)	= 0
	,@p_discount_amount						decimal(18, 2)	= 0
	,@p_discount_karoseri_amount			decimal(18, 2)	= 0
	,@p_discount_accessories_amount			decimal(18, 2)	= 0
	,@p_initial_price_amount				decimal(18, 2)	= 0
	,@p_otr_amount							decimal(18, 2)  = 0
	,@p_is_use_gps							nvarchar(1)
	,@p_gps_monthly_amount					decimal(18, 2)  = 0
	,@p_gps_installation_amount				decimal(18, 2)  = 0
	--
	,@p_cre_date						    datetime
	,@p_cre_by							    nvarchar(15)
	,@p_cre_ip_address					    nvarchar(15)
	,@p_mod_date						    datetime
	,@p_mod_by							    nvarchar(15)
	,@p_mod_ip_address					    nvarchar(15)
)
as
begin
	declare @msg									nvarchar(max)
			,@year									nvarchar(2)
			,@month									nvarchar(2)
			,@code									nvarchar(50)
			,@branch_code							nvarchar(50)
			,@rounding_type							nvarchar(10)
			,@rounding_amount						decimal(18, 2)
			,@periode								int		   = 0
			,@pmt_amount							decimal(18,2)	= 0
			,@is_purchase_requirement_after_lease	nvarchar(1)
			,@lease_option							nvarchar(10)
			,@billing_type							nvarchar(50)
			,@currency								nvarchar(10)
			,@facility								nvarchar(50)
			,@budget_replacement_amount				decimal(18, 2) = 0
			,@budget_registration_amount			decimal(18, 2) = 0
			,@budget_maintanance_amount				decimal(18, 2) = 0
			,@class_code							nvarchar(50)
			,@registration_class_code				nvarchar(50)
			,@insurance_class_code					nvarchar(50)  
			,@payment_type							nvarchar(1)
			,@total_amount_ex_vat					decimal(18, 2) = 0
			,@parameter_calculate_asset_1			decimal(9, 6)
			,@parameter_calculate_asset_2			decimal(9, 6)
			,@parameter_calculate_asset_3			decimal(18, 2)
			,@sum_asset_year						int
			,@asset_rv_rate							decimal(9, 6)
			-- (+) Ari 2023-12-01 ket : add asset jika dipilih langsung dari application
			,@is_sumulasi							nvarchar(10) 
			,@asset_no								nvarchar(50)
			,@fa_code								nvarchar(50)
			,@vat_amount							decimal(18, 2)
			,@total_otr_vat_karoseri				decimal(18, 2) = 0
			,@budget_gps_amount						decimal(18, 2) = 0

	select	@branch_code							= branch_code
			,@periode								= periode
			,@billing_type							= billing_type
			,@lease_option							= lease_option
			,@is_purchase_requirement_after_lease	= is_purchase_requirement_after_lease
			,@rounding_type							= round_type
			,@rounding_amount						= round_amount
			,@currency								= currency_code
			,@facility								= facility_code
			,@is_sumulasi							= is_simulation -- (+) Ari 2023-12-01 ket : add checking
	from	dbo.application_main
	where	application_no							= @p_application_no ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			= @code output
												,@p_branch_code			= @branch_code
												,@p_sys_document_code	= N''
												,@p_custom_prefix		= 'OPLAA'
												,@p_year				= @year
												,@p_month				= @month
												,@p_table_name			= 'APPLICATION_ASSET'
												,@p_run_number_length	= 6
												,@p_delimiter			= '.'
												,@p_run_number_only		= N'0' ; 

	begin try

		select	@parameter_calculate_asset_1 = value
		from	dbo.sys_global_param
		where	code = 'PCAA1' ;

		select	@parameter_calculate_asset_2 = value
		from	dbo.sys_global_param
		where	code = 'PCAA2' ;

		select	@parameter_calculate_asset_3 = value
		from	dbo.sys_global_param
		where	code = 'PCAA3' ;
	 
		if (isnull(@p_fa_code, '') <> '')
		begin
			if exists (select 1 from dbo.application_asset where application_no = @p_application_no and fa_code = @p_fa_code)
			begin
				set @msg = 'Fixed Asset already exists' ;

				raiserror(@msg, 16, -1) ;
			end
		end
		
		--untuk mengambil RV pct
		if (@p_asset_condition = 'USED')
		begin
			set @sum_asset_year = year(getdate()) - @p_asset_year ;

			select	@asset_rv_rate = case
										 when @p_transmisi = 'AT' then rv_rate_at
										 else rv_rate
									 end
			from	ifinbam.dbo.master_model_rv
			where	model_code = @p_model_code
					and year   = case
									 when @sum_asset_year = 0 then 1
									 else @sum_asset_year
								 end ;
	 
			if (isnull(@asset_rv_rate, 0) = 0)
			begin 
				set @msg = 'Please Setting Asset RV PCT' ;

				raiserror(@msg, 16, -1) ; 
			end

			set @total_amount_ex_vat = @p_initial_price_amount * (@asset_rv_rate / 100)

			set @total_amount_ex_vat = dbo.fn_get_round(@total_amount_ex_vat, @parameter_calculate_asset_3) ;

			set @p_otr_amount = @total_amount_ex_vat
		end ;
		else
		begin
			if (
					@p_otr_amount <= 0
				)
			begin
				set @msg = 'OTR Amount must be greater than 0' ;

				raiserror(@msg, 16, -1) ;
			end ;

			set @vat_amount = dbo.fn_get_round((((@p_otr_amount - @p_discount_amount) / @parameter_calculate_asset_1) * ((@parameter_calculate_asset_2 * 1.00) / 100)), @parameter_calculate_asset_3) ;

			set @total_amount_ex_vat = (@p_otr_amount - @p_discount_amount) - @vat_amount
			--set @total_amount_ex_vat = @p_otr_amount - @vat_amount

			set @total_amount_ex_vat = dbo.fn_get_round(@total_amount_ex_vat, @parameter_calculate_asset_3) ;

			set @total_otr_vat_karoseri = @p_otr_amount - @vat_amount + @p_karoseri_amount
		end

		if (@p_billing_mode <> 'NORMAL')
		begin
			if (
				   @p_billing_mode_date > 31
				   or	@p_billing_mode_date < 1
			   )
			begin
				set @msg = 'Date must be in betwen 1 - 31' ;

				raiserror(@msg, 16, -1) ;
			end ;
		end ;

		if (
				@p_request_delivery_date < dbo.xfn_get_system_date()
			)
		begin
			set @msg = 'Estimate Delivery Date must be greater or equal than System Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (
				@p_otr_amount <= 0 and @p_asset_condition <> 'USED'
			)
		begin
			set @msg = 'OTR Amount must be greater than 0' ;

			raiserror(@msg, 16, -1) ;
		end ;

		--if (
		--		@p_discount_amount >= @total_amount_ex_vat
		--	)
		--begin
		--	set @msg = 'Discount Amount must be less than Unit Amount' ;

		--	raiserror(@msg, 16, -1) ;
		--end ;
		
		if (
				@p_discount_karoseri_amount > @p_karoseri_amount
			)
		begin
			set @msg = 'Discount Karoseri Amount must be less or equal than Karoseri Amount' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (
				@p_discount_accessories_amount > @p_accessories_amount
			)
		begin
			set @msg = 'Discount Accessories Amount must be less or equal than Accessories Amount' ;

			raiserror(@msg, 16, -1) ;
		end ;

		select	@payment_type = case first_payment_type
								when 'ADV' then '1'
								else '0'
							end
		from	dbo.application_main 
		where	application_no = @p_application_no ;


		--set is otr
		if	@p_is_otr = 'T'
			set	@p_is_otr = '1'
		else
			set	@p_is_otr = '0'

		--set is bbn client
		if @p_is_bbn_client = 'T'
			set	@p_is_bbn_client = '1'
		else
			set	@p_is_bbn_client = '0'

		--set is use gps
		if @p_is_use_gps = 'T'
			set	@p_is_use_gps = '1'
		else
			set	@p_is_use_gps = '0'
			
		--set @total_amount_ex_vat = @p_otr_amount - ((@p_otr_amount / @parameter_calculate_asset_1) * ((@parameter_calculate_asset_2 * 1.00) / 100))

		--set @total_amount_ex_vat = dbo.fn_get_round(@total_amount_ex_vat, @parameter_calculate_asset_3) ;

		set @p_asset_amount = (@total_amount_ex_vat) + (@p_karoseri_amount - @p_discount_karoseri_amount) + (@p_accessories_amount - @p_discount_accessories_amount)
		
		if (@p_asset_interest_rate > 0)
		begin
			set @pmt_amount = dbo.fn_get_pmt(@p_asset_interest_rate / 12, @periode, @p_asset_amount * -1, @p_asset_rv_amount, @payment_type) ;
			set @p_asset_interest_amount = (dbo.fn_get_pmt(@p_asset_interest_rate / 12, @periode, @p_asset_amount * -1, @p_asset_rv_amount, @payment_type) * @periode) - (@p_asset_amount - @p_asset_rv_amount) ;
		end ;

		if (@p_borrowing_interest_rate > 0)
		begin
			set @p_borrowing_interest_amount = (dbo.fn_get_pmt((@p_borrowing_interest_rate / 100) / 12, @periode, @p_asset_amount * -1, @p_asset_rv_amount, @payment_type) * @periode) - (@p_asset_amount - @p_asset_rv_amount) ;
		end ;

		if (@p_asset_rv_pct > 0)
		begin
			if (@p_asset_condition = 'USED')
			begin
				set @p_asset_rv_amount = ((@p_initial_price_amount + @p_karoseri_amount) * @p_asset_rv_pct) / 100 ;
			end ;
			else
			begin
				set @p_asset_rv_amount = ((@total_otr_vat_karoseri) * @p_asset_rv_pct) / 100 ;
			end ;
		end ;
		else if (@p_asset_rv_amount > 0)
		begin
			if (@p_asset_condition = 'USED')
			begin
				set @p_asset_rv_pct = (@p_asset_rv_amount / (@p_initial_price_amount + @p_karoseri_amount)) * 100 ;
			end ;
			else
			begin
				set @p_asset_rv_pct = (@p_asset_rv_amount / (@total_otr_vat_karoseri)) * 100 ;
			end ;
		end ;
		
		
		--if (@p_asset_rv_pct > 0 or @p_asset_rv_amount > 0)
		--begin
		--	if exists
		--	(
		--		select	1
		--		from	dbo.application_asset
		--		where	asset_no		 = @code
		--				and isnull(asset_rv_pct, 0) <> @p_asset_rv_pct
		--	)
		--	begin
		--		if (@p_asset_condition = 'USED')
		--		begin
		--			set @p_asset_rv_amount = (@p_initial_price_amount * @p_asset_rv_pct) / 100 ;
		--		end ;
		--		else
		--		begin
		--			set @p_asset_rv_amount = (@total_amount_ex_vat * @p_asset_rv_pct) / 100 ;
		--		end ;
		--	end ;
		--	else if exists
		--	(
		--		select	1
		--		from	dbo.application_asset
		--		where	asset_no			= @code
		--				and isnull(asset_rv_amount, 0) <> @p_asset_rv_amount
		--	)
		--	begin
		--		if (@p_asset_condition = 'USED')
		--		begin
		--			set @p_asset_rv_pct = (@p_asset_rv_amount / @p_initial_price_amount) * 100 ;
		--		end ;
		--		else
		--		begin
		--			set @p_asset_rv_pct = (@p_asset_rv_amount / @total_amount_ex_vat) * 100 ;
		--		end ;
		--	end ;
		--end ;
		
		--if exists
		--(
		--	select	1
		--	from	dbo.application_asset
		--	where	asset_no			= @code
		--			and isnull(market_value, 0) <> @total_amount_ex_vat
		--)
		--begin
		--	if (@p_asset_condition = 'USED')
		--	begin
		--		set @p_asset_rv_amount = (@p_initial_price_amount * @p_asset_rv_pct) / 100 ;
		--	end ;
		--	else
		--	begin
		--		set @p_asset_rv_amount = (@total_amount_ex_vat * @p_asset_rv_pct) / 100 ;
		--	end ;
		--end
		
		insert into dbo.application_asset
		(
			asset_no
			,application_no
			,asset_type_code
			,asset_name
			,asset_year
			,asset_condition
			,billing_to
			,billing_to_name
			,billing_to_area_no
			,billing_to_phone_no
			,billing_to_address
			,billing_type
			,billing_mode
			,billing_mode_date
			,billing_to_faktur_type
			,billing_to_npwp
			,npwp_name
			,npwp_address
			,is_purchase_requirement_after_lease
			,deliver_to
			,deliver_to_name
			,deliver_to_area_no
			,deliver_to_phone_no
			,deliver_to_address
			,pickup_phone_area_no
			,pickup_phone_no
			,pickup_name
			,pickup_address
			,market_value
			,asset_amount
			,asset_interest_rate
			,asset_interest_amount
			,asset_rv_pct
			,asset_rv_amount
			,periode
			,lease_option
			,cogs_amount
			,basic_lease_amount
			,margin_by
			,margin_rate
			,margin_amount
			,additional_charge_rate
			,additional_charge_amount
			,lease_amount
			,round_type
			,round_amount
			,lease_rounded_amount
			,net_margin_amount
			,purchase_status
			,fa_code
			,fa_name
			,karoseri_amount
			,accessories_amount
			,mobilization_amount
			,fa_reff_no_01
			,fa_reff_no_02
			,fa_reff_no_03
			,email
			,is_otr
			,bbn_location_code
			,bbn_location_description
			,plat_colour
			,usage
			,start_miles
			,monthly_miles
			,is_use_registration
			,is_use_replacement
			,is_use_maintenance
			,is_use_insurance
			,request_delivery_date
			,is_bbn_client
			,client_bbn_name
			,client_bbn_address
			,pmt_amount
			,subvention_amount
			,mobilization_city_code			    
			,mobilization_city_description	    
			,mobilization_province_code		    
			,mobilization_province_description
			,borrowing_interest_rate
			,borrowing_interest_amount
			,discount_amount				
			,discount_karoseri_amount	
			,discount_accessories_amount
			,initial_price_amount
			,purchase_gts_status
			,otr_amount
			,is_use_gps
			,gps_monthly_amount
			,gps_installation_amount
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@code
			,@p_application_no
			,@p_asset_type_code
			,upper(@p_asset_name)
			,@p_asset_year
			,@p_asset_condition
			,@p_billing_to
			,UPPER(@p_billing_to_name)
			,@p_billing_to_area_no
			,@p_billing_to_phone_no
			,@p_billing_to_address
			,@billing_type
			,@p_billing_mode
			,@p_billing_mode_date
			,@p_billing_to_faktur_type
			,@p_billing_to_npwp
			,UPPER(@p_npwp_name)
			,@p_npwp_address
			,@is_purchase_requirement_after_lease
			,@p_deliver_to
			,UPPER(@p_deliver_to_name)
			,@p_deliver_to_area_no
			,@p_deliver_to_phone_no
			,@p_deliver_to_address
			,@p_pickup_phone_area_no
			,@p_pickup_phone_no
			,UPPER(@p_pickup_name)
			,@p_pickup_address
			,@total_amount_ex_vat
			,@p_asset_amount
			,@p_asset_interest_rate
			,@p_asset_interest_amount
			,@p_asset_rv_pct
			,@p_asset_rv_amount
			,@periode
			,@lease_option
			,@p_cogs_amount
			,@p_basic_lease_amount
			,@p_margin_by
			,@p_margin_rate
			,@p_margin_amount
			,@p_additional_charge_rate
			,@p_additional_charge_amount
			,@p_lease_amount
			,@rounding_type
			,@rounding_amount
			,@p_lease_rounded_amount
			,@p_net_margin_amount
			,'NONE'
			,@p_fa_code
			,@p_fa_name
			,@p_karoseri_amount			
			,@p_accessories_amount		
			,@p_mobilization_amount		
			,@p_fa_reff_no_01
			,@p_fa_reff_no_02
			,@p_fa_reff_no_03
			,@p_email
			,@p_is_otr
			,@p_bbn_location_code		
			,@p_bbn_location_description
			,@p_plat_colour			
			,@p_usage			
			,@p_start_miles			
			,@p_monthly_miles		
			,'1'
			,'1'
			,'1'
			,'0'
			,@p_request_delivery_date
			,@p_is_bbn_client			
			,@p_client_bbn_name			
			,@p_client_bbn_address		
			,@pmt_amount
			,0
			,@p_mobilization_city_code			    
			,@p_mobilization_city_description	    
			,@p_mobilization_province_code		    
			,@p_mobilization_province_description   
			,@p_borrowing_interest_rate
			,@p_borrowing_interest_amount
			,@p_discount_amount				
			,@p_discount_karoseri_amount	
			,@p_discount_accessories_amount
			,@p_initial_price_amount
			,'NONE'
			,@p_otr_amount
			,@p_is_use_gps
			,@p_gps_monthly_amount
			,@p_gps_installation_amount
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;  

		if @p_asset_type_code = 'VHCL'
		begin
			select	@class_code = class_type_code
					,@registration_class_code = registration_class_type_code
					,@insurance_class_code = insurance_asset_type_code
			from	dbo.master_vehicle_unit
			where	code = @p_unit_code ;

			exec dbo.xsp_application_asset_vehicle_insert @p_asset_no					= @code
														  ,@p_vehicle_category_code		= @p_category_code	
														  ,@p_vehicle_subcategory_code	= @p_subcategory_code
														  ,@p_vehicle_merk_code			= @p_merk_code		
														  ,@p_vehicle_model_code		= @p_model_code		
														  ,@p_vehicle_type_code			= @p_type_code		
														  ,@p_vehicle_unit_code			= @p_unit_code		
														  ,@p_colour					= @p_colour		
														  ,@p_transmisi					= @p_transmisi	
														  ,@p_remarks					= @p_remarks		
														  ,@p_cre_date					= @p_cre_date
														  ,@p_cre_by					= @p_cre_by
														  ,@p_cre_ip_address			= @p_cre_ip_address
														  ,@p_mod_date					= @p_mod_date
														  ,@p_mod_by					= @p_mod_by
														  ,@p_mod_ip_address			= @p_mod_ip_address ;
		end ;
		else if @p_asset_type_code = 'MCHN'
		begin
			select	@class_code = class_type_code
					,@registration_class_code = registration_class_type_code
					,@insurance_class_code = insurance_asset_type_code
			from	dbo.master_machinery_unit
			where	code = @p_unit_code ;

			exec dbo.xsp_application_asset_machine_insert @p_asset_no					 = @code
														  ,@p_machinery_category_code	 = @p_category_code	
														  ,@p_machinery_subcategory_code = @p_subcategory_code
														  ,@p_machinery_merk_code		 = @p_merk_code		
														  ,@p_machinery_model_code		 = @p_model_code		
														  ,@p_machinery_type_code		 = @p_type_code		
														  ,@p_machinery_unit_code		 = @p_unit_code		
														  ,@p_colour					 = @p_colour		
														  ,@p_remarks					 = @p_remarks 
														  ,@p_cre_date					 = @p_cre_date
														  ,@p_cre_by					 = @p_cre_by
														  ,@p_cre_ip_address			 = @p_cre_ip_address
														  ,@p_mod_date					 = @p_mod_date
														  ,@p_mod_by					 = @p_mod_by
														  ,@p_mod_ip_address			 = @p_mod_ip_address ;
		end ;
		else if @p_asset_type_code = 'HE'
		begin
			select	@class_code = class_type_code
					,@registration_class_code = registration_class_type_code
					,@insurance_class_code = insurance_asset_type_code
			from	dbo.master_he_unit
			where	code = @p_unit_code ;

			exec dbo.xsp_application_asset_he_insert @p_asset_no			 = @code
													 ,@p_he_category_code	 = @p_category_code	
													 ,@p_he_subcategory_code = @p_subcategory_code
													 ,@p_he_merk_code		 = @p_merk_code		
													 ,@p_he_model_code		 = @p_model_code		
													 ,@p_he_type_code		 = @p_type_code		
													 ,@p_he_unit_code		 = @p_unit_code		
													 ,@p_colour				 = @p_colour		
													 ,@p_remarks			 = @p_remarks 
													 --	
													 ,@p_cre_date			 = @p_cre_date
													 ,@p_cre_by				 = @p_cre_by
													 ,@p_cre_ip_address		 = @p_cre_ip_address
													 ,@p_mod_date			 = @p_mod_date
													 ,@p_mod_by				 = @p_mod_by
													 ,@p_mod_ip_address		 = @p_mod_ip_address ;
		end ;
		else if @p_asset_type_code = 'ELEC'
		begin
			select	@class_code = class_type_code
					,@registration_class_code = registration_class_type_code
					,@insurance_class_code = insurance_asset_type_code
			from	dbo.master_electronic_unit
			where	code = @p_unit_code ;

			exec dbo.xsp_application_asset_electronic_insert @p_asset_no					 = @code
															 ,@p_electronic_category_code	 = @p_category_code	
															 ,@p_electronic_subcategory_code = @p_subcategory_code
															 ,@p_electronic_merk_code		 = @p_merk_code		
															 ,@p_electronic_model_code		 = @p_model_code	
															 ,@p_electronic_unit_code		 = @p_unit_code		
															 ,@p_colour						 = @p_colour		
															 ,@p_remarks					 = @p_remarks 
															 ,@p_cre_date					 = @p_cre_date
															 ,@p_cre_by						 = @p_cre_by
															 ,@p_cre_ip_address				 = @p_cre_ip_address
															 ,@p_mod_date					 = @p_mod_date
															 ,@p_mod_by						 = @p_mod_by
															 ,@p_mod_ip_address				 = @p_mod_ip_address ;
		end ;

		--set	@budget_replacement_amount = isnull(dbo.xfn_get_budget_amount(@class_code, @p_mod_date, 'REPLACEMENT', @p_asset_amount, 0, @p_unit_code, @p_start_miles, @p_monthly_miles,  ceiling((@periode  * 1.00) / 12),0,''), 0) ;
		set	@budget_replacement_amount = round(isnull(dbo.xfn_get_budget_amount(@class_code, @p_mod_date, 'REPLACEMENT', @p_asset_amount, 0, @p_unit_code, @p_start_miles, @p_monthly_miles,  ceiling((@periode  * 1.00) / 12),0,''), 0),0) ; -- (+) Ari 2024-03-12 ket : request pak hary round normal
			
		--set	@budget_registration_amount = isnull(dbo.xfn_get_budget_amount(@registration_class_code, @p_mod_date, 'REGISTRATION', @p_asset_amount, 0, @p_unit_code, @p_start_miles, @p_monthly_miles,  ceiling((@periode  * 1.00) / 12),0,''), 0) ;
		set	@budget_registration_amount = round(isnull(dbo.xfn_get_budget_amount(@registration_class_code, @p_mod_date, 'REGISTRATION', @p_asset_amount, 0, @p_unit_code, @p_start_miles, @p_monthly_miles,  ceiling((@periode  * 1.00) / 12),0,''), 0),0) ; -- (+) Ari 2024-03-12 ket : request pak hary round normal
			
		--set @budget_maintanance_amount = isnull(dbo.xfn_get_budget_amount(@class_code, @p_mod_date, 'MAINTENANCE', @p_asset_amount, 0, @p_unit_code, @p_start_miles, @p_monthly_miles, @periode, @p_asset_year, @p_usage), 0) ;
		set @budget_maintanance_amount = round(isnull(dbo.xfn_get_budget_amount(@class_code, @p_mod_date, 'MAINTENANCE', @p_asset_amount, 0, @p_unit_code, @p_start_miles, @p_monthly_miles, @periode, @p_asset_year, @p_usage), 0),0) ; -- (+) Ari 2024-03-12 ket : request pak hary round normal
	
		if exists
		(
			select	1
			from	dbo.application_asset
			where	asset_no			   = @p_asset_no
					and is_use_gps		   = '1'
					and gps_monthly_amount > 0
		)
		begin
			select	@budget_gps_amount = (isnull(gps_monthly_amount, 0) * periode)
			from	dbo.application_asset
			where	asset_no = @p_asset_no ;

			set @budget_maintanance_amount = @budget_maintanance_amount + isnull(@budget_gps_amount, 0)
		end ;

		exec dbo.xsp_application_asset_budget_insert @p_id					 = 0
													 ,@p_asset_no			 = @code
													 ,@p_cost_code			 = N'MBDC.2208.000001'
													 ,@p_cost_type			 = N'FIXED'
													 ,@p_cost_amount_monthly = @budget_replacement_amount
													 ,@p_cost_amount_yearly  = @budget_replacement_amount
													 ,@p_cre_date			 = @p_cre_date
													 ,@p_cre_by				 = @p_cre_by
													 ,@p_cre_ip_address		 = @p_cre_ip_address
													 ,@p_mod_date			 = @p_mod_date
													 ,@p_mod_by				 = @p_mod_by
													 ,@p_mod_ip_address		 = @p_mod_ip_address
			
		exec dbo.xsp_application_asset_budget_insert @p_id					 = 0
													 ,@p_asset_no			 = @code
													 ,@p_cost_code			 = N'MBDC.2301.000001'
													 ,@p_cost_type			 = N'FIXED'
													 ,@p_cost_amount_monthly = @budget_registration_amount
													 ,@p_cost_amount_yearly  = @budget_registration_amount
													 ,@p_cre_date			 = @p_cre_date
													 ,@p_cre_by				 = @p_cre_by
													 ,@p_cre_ip_address		 = @p_cre_ip_address
													 ,@p_mod_date			 = @p_mod_date
													 ,@p_mod_by				 = @p_mod_by
													 ,@p_mod_ip_address		 = @p_mod_ip_address

		exec dbo.xsp_application_asset_budget_insert @p_id					 = 0
													 ,@p_asset_no			 = @code
													 ,@p_cost_code			 = N'MBDC.2211.000003'
													 ,@p_cost_type			 = N'FIXED'
													 ,@p_cost_amount_monthly = @budget_maintanance_amount
													 ,@p_cost_amount_yearly  = @budget_maintanance_amount
													 ,@p_cre_date			 = @p_cre_date
													 ,@p_cre_by				 = @p_cre_by
													 ,@p_cre_ip_address		 = @p_cre_ip_address
													 ,@p_mod_date			 = @p_mod_date
													 ,@p_mod_by				 = @p_mod_by
													 ,@p_mod_ip_address		 = @p_mod_ip_address

		exec dbo.xsp_application_main_rental_amount_update @p_application_no  = @p_application_no
														   --
														   ,@p_mod_date		  = @p_cre_date
														   ,@p_mod_by		  = @p_cre_by
														   ,@p_mod_ip_address = @p_cre_ip_address ;

		exec dbo.xsp_application_amortization_calculate @p_asset_no			= @p_asset_no
														,@p_cre_date		= @p_mod_date
														,@p_cre_by			= @p_mod_by
														,@p_cre_ip_address	= @p_mod_ip_address
														,@p_mod_date		= @p_mod_date
														,@p_mod_by			= @p_mod_by
														,@p_mod_ip_address	= @p_mod_ip_address


		-- (+) Ari 2023-12-01 ket : jika insert asset kembali, update juga ams
		if(isnull(@is_sumulasi,'0') = '0')
		begin
			--for update fixe asset status to Reserved when asset condition is USED
			declare currapplicationasset cursor fast_forward read_only for
			select	asset_no
					,fa_code
			from	dbo.application_asset
			where	application_no		= @p_application_no
					and asset_no		= @code
					and asset_condition = 'USED' ;

			open currapplicationasset ;

			fetch next from currapplicationasset
			into @asset_no 
				,@fa_code ;

			while @@fetch_status = 0
			begin

				exec ifinams.dbo.xsp_asset_update_rental_status @p_code				= @fa_code
																,@p_rental_reff_no	= @asset_no
																,@p_rental_status	= 'RESERVED'
																,@p_reserved_by		= null
																,@p_is_cancel		= '0'
																,@p_mod_date		= @p_mod_date
																,@p_mod_by			= @p_mod_by
																,@p_mod_ip_address	= @p_mod_ip_address
				
				
				fetch next from currapplicationasset
				into @asset_no 
					,@fa_code ;
			end ;

			close currapplicationasset ;
			deallocate currapplicationasset ;
		end

		set @p_asset_no = @code ;
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
