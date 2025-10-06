CREATE PROCEDURE dbo.xsp_application_asset_update_backup_20250502
(
	@p_asset_no								nvarchar(50)  
	,@p_application_no						nvarchar(50) 
	,@p_asset_type_code						nvarchar(50)
	,@p_asset_name							nvarchar(250)
	,@p_billing_to							nvarchar(10)
	,@p_billing_to_name						nvarchar(250)	= ''
	,@p_billing_to_area_no					nvarchar(4)		= ''
	,@p_billing_to_phone_no					nvarchar(15)	= ''
	,@p_billing_to_address					nvarchar(4000)	= ''
	,@p_billing_mode						nvarchar(10)	= ''
	,@p_billing_mode_date					int				
	,@p_billing_to_faktur_type				nvarchar(3)
	,@p_billing_to_npwp						nvarchar(20)	= ''
	,@p_npwp_name							nvarchar(250)	= ''
	,@p_npwp_address						nvarchar(4000)	= ''
	,@p_deliver_to							nvarchar(10)	= ''
	,@p_deliver_to_name						nvarchar(250)	= ''
	,@p_deliver_to_area_no					nvarchar(4)		= ''
	,@p_deliver_to_phone_no					nvarchar(15)	= ''
	,@p_deliver_to_address					nvarchar(4000)	= ''
	,@p_pickup_phone_area_no				nvarchar(4)		= ''
	,@p_pickup_phone_no						nvarchar(15)	= ''
	,@p_pickup_name							nvarchar(250)	= ''
	,@p_pickup_address						nvarchar(4000)	= ''
	,@p_asset_amount						decimal(18, 2)	= 0
	,@p_asset_interest_rate					decimal(9, 6)	= 0
	,@p_asset_interest_amount				decimal(18, 2)	= 0
	,@p_asset_rv_pct						decimal(9, 6)	= 0
	,@p_asset_rv_amount						DECIMAL(18,2)				= 0	
	,@p_cogs_amount							decimal(18, 2)	= 0
	,@p_margin_by							nvarchar(50)	= 'ALL'
	,@p_margin_rate							decimal(9, 6)	= 0
	,@p_margin_amount						decimal(18, 2)	= 0
	,@p_additional_charge_rate				decimal(9, 6)	= 0
	,@p_additional_charge_amount			decimal(18, 2)	= 0
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
	,@p_subvention_amount					decimal(18, 2)	= 0
	,@p_fa_reff_no_01						nvarchar(250)	= null
	,@p_fa_reff_no_02						nvarchar(250)	= null
	,@p_fa_reff_no_03						nvarchar(250)	= null
	,@p_email								nvarchar(250)
	,@p_is_auto_email						nvarchar(1)
	,@p_is_otr								nvarchar(1)
	,@p_bbn_location_code					nvarchar(50)	= null
	,@p_bbn_location_description			nvarchar(4000)	= null
	,@p_plat_colour							nvarchar(10)
	,@p_usage								nvarchar(10)
	,@p_start_miles							int
	,@p_monthly_miles						int
	,@p_is_use_registration					nvarchar(1)
	,@p_is_use_replacement					nvarchar(1)
	,@p_is_use_maintenance					nvarchar(1)
	,@p_is_use_insurance					nvarchar(1)
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
	,@p_initial_price_amount				decimal(18, 2)  = 0
	,@p_otr_amount							decimal(18, 2)  = 0
	,@p_is_use_gps							nvarchar(1)
	,@p_gps_monthly_amount					decimal(18, 2)  = 0
	,@p_gps_installation_amount				decimal(18, 2)  = 0
	,@p_client_nitku						nvarchar(50) = ''
	--											
	,@p_mod_date							datetime
	,@p_mod_by								nvarchar(15)
	,@p_mod_ip_address						nvarchar(15)
)
as
begin

	declare @msg						   nvarchar(max)
			,@periode					   int
			,@lease_rounded_amount		   decimal(18, 2) = 0
			,@basic_lease_amount		   decimal(18, 2) = 0
			,@budget_replacement_amount	   decimal(18, 2) = 0
			,@budget_registration_amount   decimal(18, 2) = 0
			,@budget_maintanance_amount	   decimal(18, 2) = 0
			,@budget_insurance_amount	   decimal(18, 2) = 0
			,@pmt_amount				   decimal(18, 2) = 0
			,@spaf_rate					   decimal(9, 6)	 = 0
			,@borrowing_rate			   decimal(9, 6)	 = 0
			,@spaf_amount				   decimal(18, 2) = 0
			,@insurance_commission_rate	   decimal(9, 6)	 = 0
			,@additional_charge_amount	   decimal(18, 2) = 0
			,@additional_charge_amount_m   decimal(18, 2) = 0
			,@insurance_commission_amount  decimal(18, 2) = 0
			,@class_code				   nvarchar(50)
			,@registration_class_code	   nvarchar(50)
			,@insurance_class_code		   nvarchar(50)
			,@asset_condition			   nvarchar(5)
			,@rounding_type				   nvarchar(20)
			,@rounding_value			   decimal(18, 2)
			,@asset_year				   int
			,@multiplier				   int
			,@top_days					   int
			,@periode_devider			   int
			,@payment_type				   nvarchar(1)
			,@total_amount_ex_vat		   decimal(18, 2) = 0
			,@total_otr_vat_karoseri	   decimal(18, 2) = 0
			,@parameter_calculate_asset_1  decimal(9, 6)
			,@parameter_calculate_asset_2  decimal(9, 6)
			,@parameter_calculate_asset_3  decimal(18, 2) 
			,@parameter_calculate_asset_4  decimal(9, 6)
			,@sum_asset_year			   int
			,@asset_rv_rate				   decimal(9, 6)
			,@total_budget_amount		   decimal(18, 2)
			,@spaf_otr_amount			   decimal(18, 2)
			,@vat_amount				   decimal(18, 2)
			,@budget_vat_amount			   decimal(18, 2)
			,@original_amount_exc_acc	   decimal(18, 2)
			,@budget_gps_amount			   decimal(18, 2) = 0
			,@old_budget_gps_amount		   decimal(18, 2) = 0
			,@old_budget_maintanance_amount		   decimal(18, 2) = 0
			,@monthly_lease_rounded_amount decimal(18, 2) = 0 
			-- (+) Raffi Freshdesk 2329840
			,@purchase_date					datetime
			,@asset_purchase_month			INT
            ,@is_simulation					NVARCHAR(1)
	 
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

		select	@parameter_calculate_asset_4 = value
		from	dbo.sys_global_param
		where	code = 'PCAA4' ;

		select	@periode				= am.periode
				,@asset_condition		= asset_condition
				,@asset_year			= asset_year 
				,@multiplier			= mbt.multiplier
				,@borrowing_rate		= aa.borrowing_interest_rate
				,@top_days				= am.credit_term 
				,@rounding_type			= aa.round_type
				,@rounding_value		= aa.round_amount
				,@old_budget_gps_amount = aa.gps_monthly_amount
				,@is_simulation			= am.is_simulation
		from	dbo.application_asset aa
				inner join dbo.application_main am on (am.application_no = aa.application_no)
				inner join master_billing_type mbt on (mbt.code = aa.billing_type)
		where	asset_no = @p_asset_no ;

		if(@p_billing_mode <> 'NORMAL')
		begin
			if (
				   @p_billing_mode_date > 31
				   or	@p_billing_mode_date < 1
			   )
			begin
				set @msg = 'Date must be in betwen 1 - 31' ;

				raiserror(@msg, 16, -1) ;
			end ;
		end 

		if (isnull(@is_simulation,'')<>'1')and(len(ISNULL(@p_client_nitku,'')) <> 6)
		begin 
			set @msg = 'NITKU Must be 6 Digits'
			raiserror (@msg,16,-1);
		end

		if (
				@p_request_delivery_date < dbo.xfn_get_system_date()
			)
		begin
			set @msg = 'Estimate Delivery Date must be greater or equal than System Date' ;

			raiserror(@msg, 16, -1) ;
		end ;
		
		--untuk mengambil RV pct
		if (@asset_condition = 'USED')
		begin
			-- (+) Raffi Freshdesk 2329840
			SELECT @purchase_date = purchase_date
			from IFINAMS.dbo.ASSET 
			where CODE = @p_fa_code

			set @asset_purchase_month = datediff(month,@purchase_date,getdate())

			set @sum_asset_year = FLOOR(@asset_purchase_month / 12)
			--set @sum_asset_year = year(getdate()) - @p_asset_year ;

			select	@asset_rv_rate = case
										 when @p_transmisi = 'AT' then rv_rate_at
										 else rv_rate
									 end
			from	ifinbam.dbo.master_model_rv
			where	model_code = @p_model_code
					and year   = case
									 --when @sum_asset_year = 0 then 1
									 when @sum_asset_year = 0 then 0
									 else @sum_asset_year
								 end ;
			
			if @asset_purchase_month >= 12
			begin
				if (isnull(@asset_rv_rate, 0) = 0)
				begin 
					set @msg = 'Please Setting Asset RV PCT' ;

					raiserror(@msg, 16, -1) ; 
				end
			end

			if isnull(@asset_rv_rate,0) <> 0
			begin
				set @total_amount_ex_vat = @p_initial_price_amount * (@asset_rv_rate / 100)
			end
			else
			begin
				set @total_amount_ex_vat = @p_initial_price_amount
			end

			set @total_amount_ex_vat = dbo.fn_get_round(@total_amount_ex_vat, @parameter_calculate_asset_3) ; 

			set @p_otr_amount = @total_amount_ex_vat


			set @p_asset_rv_pct = ISNULL(@asset_rv_rate,0)
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

			set @total_amount_ex_vat = dbo.fn_get_round(@total_amount_ex_vat, @parameter_calculate_asset_3) ;
			
			set @total_otr_vat_karoseri = @p_otr_amount - @vat_amount + @p_karoseri_amount
		end

		if (
				@p_discount_amount >= @p_otr_amount
			)
		begin
			set @msg = 'Discount Amount must be less than : Rp. ' + convert(varchar, cast(@total_amount_ex_vat as money), 1) ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (
				@p_otr_amount <= 0
			)
		begin
			set @msg = 'OTR Amount must be greater than 0' ;

			raiserror(@msg, 16, -1) ;
		end ;
		
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

	 
		--set is auto email
		if @p_is_auto_email = 'T'
			set @p_is_auto_email = '1'
		else
			set @p_is_auto_email = '0'

		--set is otr
		if	@p_is_otr = 'T'
			set	@p_is_otr = '1'
		else
			set	@p_is_otr = '0'

		--set is use registration
		if	@p_is_use_registration = 'T'
			set	@p_is_use_registration = '1'
		else
			set	@p_is_use_registration = '0'

		--set is use replacement
		if	@p_is_use_replacement = 'T'
			set	@p_is_use_replacement = '1'
		else
			set	@p_is_use_replacement = '0'

		--set is use maintenance
		if	@p_is_use_maintenance = 'T'
			set	@p_is_use_maintenance = '1'
		else
			set	@p_is_use_maintenance = '0'

		--set is use insurance
		if	@p_is_use_insurance = 'T'
			set	@p_is_use_insurance = '1'
		else
			set	@p_is_use_insurance = '0'

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
		
		set @p_asset_amount = @total_amount_ex_vat + (@p_karoseri_amount - @p_discount_karoseri_amount) + (@p_accessories_amount - @p_discount_accessories_amount)
		 
		if (@p_asset_rv_pct > 0 or @p_asset_rv_amount > 0)
		BEGIN
			if exists
			(
				select	1
				from	dbo.application_asset
				where	asset_no		 = @p_asset_no
						and isnull(asset_rv_pct, 0) <> @p_asset_rv_pct
			)
			BEGIN
				if (@asset_condition = 'USED')
				begin
					set @p_asset_rv_amount = ((@p_initial_price_amount + @p_karoseri_amount) * @p_asset_rv_pct) / 100 ;
				end ;
				else
				BEGIN
					set @p_asset_rv_amount = ((@total_otr_vat_karoseri) * @p_asset_rv_pct) / 100 ;
				end ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_asset
				where	asset_no			= @p_asset_no
						and isnull(asset_rv_amount, 0) <> @p_asset_rv_amount
			)
			BEGIN
				if (@asset_condition = 'USED')
				begin
					set @p_asset_rv_pct = (@p_asset_rv_amount / (@p_initial_price_amount + @p_karoseri_amount)) * 100 ;
				end ;
				else
				BEGIN
					set @p_asset_rv_pct = (@p_asset_rv_amount / (@total_otr_vat_karoseri)) * 100 ;
				end ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_asset
				where	asset_no			= @p_asset_no
						and (isnull(otr_amount, 0) <> @p_otr_amount or isnull(karoseri_amount, 0) <> @p_karoseri_amount)
			)
			begin 
				if (@asset_condition = 'USED')
				begin
					set @p_asset_rv_amount = ((@p_initial_price_amount + @p_karoseri_amount) * @p_asset_rv_pct) / 100 ;
				end ;
				else
				begin  
					set @p_asset_rv_amount = ((@total_otr_vat_karoseri) * @p_asset_rv_pct) / 100 ; 
				end ;
	 
			end	
			else  --(+)Sepria 2025/02/19 (+) Penambahan kondisi untuk selalu mengcalculate ulang nilai rv amount nya
			begin
				if (@asset_condition = 'USED')
				begin
					set @p_asset_rv_amount = ((@p_initial_price_amount + @p_karoseri_amount) * @p_asset_rv_pct) / 100 ;
				end ;
				else
				begin  
					set @p_asset_rv_amount = ((@total_otr_vat_karoseri) * @p_asset_rv_pct) / 100 ; 
				end ;
			end
		end ;	

		if (@p_asset_interest_rate > 0)
		begin
			set @pmt_amount = dbo.fn_get_pmt(@p_asset_interest_rate / 12, @periode, @p_asset_amount * -1, @p_asset_rv_amount, @payment_type) ; 
			set @p_asset_interest_amount = (dbo.fn_get_pmt(@p_asset_interest_rate / 12, @periode, @p_asset_amount * -1, @p_asset_rv_amount, @payment_type) * @periode) - (@p_asset_amount - @p_asset_rv_amount)
		end

		if (@p_borrowing_interest_rate > 0)
		begin
			set @p_borrowing_interest_amount = (dbo.fn_get_pmt(@p_borrowing_interest_rate / 12, @periode, @p_asset_amount * -1, @p_asset_rv_amount, @payment_type) * @periode)  - (@p_asset_amount - @p_asset_rv_amount)
		end

		update	dbo.application_asset
		set		asset_name							= upper(@p_asset_name) 
				,billing_to							= @p_billing_to
				,billing_to_name					= UPPER(@p_billing_to_name)
				,billing_to_area_no					= @p_billing_to_area_no
				,billing_to_phone_no				= @p_billing_to_phone_no
				,billing_to_address					= @p_billing_to_address
				,billing_mode						= @p_billing_mode
				,billing_mode_date					= @p_billing_mode_date
				,billing_to_faktur_type				= @p_billing_to_faktur_type	
				,billing_to_npwp					= @p_billing_to_npwp	
				,npwp_name							= UPPER(@p_npwp_name)	
				,npwp_address						= @p_npwp_address	
				,deliver_to							= @p_deliver_to
				,deliver_to_name					= UPPER(@p_deliver_to_name)
				,deliver_to_area_no					= @p_deliver_to_area_no
				,deliver_to_phone_no				= @p_deliver_to_phone_no
				,deliver_to_address					= @p_deliver_to_address
				,pickup_phone_area_no				= @p_pickup_phone_area_no
				,pickup_phone_no					= @p_pickup_phone_no
				,pickup_name						= UPPER(@p_pickup_name)
				,pickup_address						= @p_pickup_address
				,market_value						= @total_amount_ex_vat
				,asset_amount						= @p_asset_amount
				,asset_interest_rate				= @p_asset_interest_rate
				,asset_interest_amount				= @p_asset_interest_amount
				,asset_rv_pct						= @p_asset_rv_pct
				,asset_rv_amount					= @p_asset_rv_amount
				,cogs_amount						= @p_cogs_amount 
				,margin_by							= @p_margin_by
				,margin_rate						= @p_margin_rate
				,margin_amount						= @p_margin_amount 
				,lease_amount						= 0 
				,fa_code							= @p_fa_code
				,fa_name							= @p_fa_name
				,karoseri_amount					= @p_karoseri_amount		 
				,accessories_amount					= @p_accessories_amount	 
				,mobilization_amount				= @p_mobilization_amount
				,fa_reff_no_01						= @p_fa_reff_no_01
				,fa_reff_no_02						= @p_fa_reff_no_02
				,fa_reff_no_03						= @p_fa_reff_no_03	
				,email								= @p_email
				,is_auto_email						= @p_is_auto_email
				,is_otr								= @p_is_otr
				,bbn_location_code					= @p_bbn_location_code
				,bbn_location_description			= @p_bbn_location_description
				,plat_colour						= @p_plat_colour
				,usage								= @p_usage
				,start_miles						= @p_start_miles 
				,monthly_miles						= @p_monthly_miles
				,is_use_registration				= @p_is_use_registration
				,is_use_replacement					= @p_is_use_replacement
				,is_use_maintenance					= @p_is_use_maintenance
				,is_use_insurance					= @p_is_use_insurance
				,request_delivery_date				= @p_request_delivery_date
				,is_bbn_client						= @p_is_bbn_client		
				,client_bbn_name					= @p_client_bbn_name		
				,client_bbn_address					= @p_client_bbn_address	
				,pmt_amount							= @pmt_amount
				,subvention_amount					= @p_subvention_amount
				,mobilization_city_code				= @p_mobilization_city_code			    
				,mobilization_city_description		= @p_mobilization_city_description	    
				,mobilization_province_code			= @p_mobilization_province_code		    
				,mobilization_province_description	= @p_mobilization_province_description  
				,borrowing_interest_rate			= @p_borrowing_interest_rate
				,borrowing_interest_amount			= @p_borrowing_interest_amount
				,discount_amount					= @p_discount_amount						
				,discount_karoseri_amount			= @p_discount_karoseri_amount			
				,discount_accessories_amount		= @p_discount_accessories_amount
				,initial_price_amount				= @p_initial_price_amount
				,otr_amount							= @p_otr_amount
				,is_use_gps							= @p_is_use_gps
				,gps_monthly_amount					= @p_gps_monthly_amount
				,gps_installation_amount			= @p_gps_installation_amount
				,CLIENT_NITKU						= @p_client_nitku
				--
				,mod_date							= @p_mod_date
				,mod_by								= @p_mod_by
				,mod_ip_address						= @p_mod_ip_address
		where	asset_no							= @p_asset_no ; 
				

									    
		if @p_asset_type_code = 'VHCL'
		begin
			select	@class_code = class_type_code
					,@registration_class_code = registration_class_type_code
					,@insurance_class_code = insurance_asset_type_code
					,@spaf_rate = spaf_pct
			from	dbo.master_vehicle_unit
			where	code = @p_unit_code ;

			exec dbo.xsp_application_asset_vehicle_update @p_asset_no					= @p_asset_no
														  ,@p_vehicle_category_code		= @p_category_code	
														  ,@p_vehicle_subcategory_code	= @p_subcategory_code
														  ,@p_vehicle_merk_code			= @p_merk_code		
														  ,@p_vehicle_model_code		= @p_model_code		
														  ,@p_vehicle_type_code			= @p_type_code		
														  ,@p_vehicle_unit_code			= @p_unit_code		
														  ,@p_colour					= @p_colour		
														  ,@p_transmisi					= @p_transmisi	
														  ,@p_remarks					= @p_remarks		
														  ,@p_mod_date					= @p_mod_date
														  ,@p_mod_by					= @p_mod_by
														  ,@p_mod_ip_address			= @p_mod_ip_address ;
		end ;
		else if @p_asset_type_code = 'MCHN'
		begin
			select	@class_code = class_type_code
					,@registration_class_code = registration_class_type_code
					,@insurance_class_code = insurance_asset_type_code
					,@spaf_rate = spaf_pct
			from	dbo.master_machinery_unit
			where	code = @p_unit_code ;

			exec dbo.xsp_application_asset_machine_update @p_asset_no					 = @p_asset_no
														  ,@p_machinery_category_code	 = @p_category_code	
														  ,@p_machinery_subcategory_code = @p_subcategory_code
														  ,@p_machinery_merk_code		 = @p_merk_code		
														  ,@p_machinery_model_code		 = @p_model_code		
														  ,@p_machinery_type_code		 = @p_type_code		
														  ,@p_machinery_unit_code		 = @p_unit_code		
														  ,@p_colour					 = @p_colour		
														  ,@p_remarks					 = @p_remarks 
														  ,@p_mod_date					 = @p_mod_date
														  ,@p_mod_by					 = @p_mod_by
														  ,@p_mod_ip_address			 = @p_mod_ip_address ;
		end ;
		else if @p_asset_type_code = 'HE'
		begin
			select	@class_code = class_type_code
					,@registration_class_code = registration_class_type_code
					,@insurance_class_code = insurance_asset_type_code
					,@spaf_rate = spaf_pct
			from	dbo.master_he_unit
			where	code = @p_unit_code ;

			exec dbo.xsp_application_asset_he_update @p_asset_no			 = @p_asset_no
													 ,@p_he_category_code	 = @p_category_code	
													 ,@p_he_subcategory_code = @p_subcategory_code
													 ,@p_he_merk_code		 = @p_merk_code		
													 ,@p_he_model_code		 = @p_model_code		
													 ,@p_he_type_code		 = @p_type_code		
													 ,@p_he_unit_code		 = @p_unit_code		
													 ,@p_colour				 = @p_colour		
													 ,@p_remarks			 = @p_remarks 
													 ,@p_mod_date			 = @p_mod_date
													 ,@p_mod_by				 = @p_mod_by
													 ,@p_mod_ip_address		 = @p_mod_ip_address ;
		end ;
		else if @p_asset_type_code = 'ELEC'
		begin
			select	@class_code = class_type_code
					,@registration_class_code = registration_class_type_code
					,@insurance_class_code = insurance_asset_type_code
					,@spaf_rate = spaf_pct
			from	dbo.master_electronic_unit
			where	code = @p_unit_code ;

			exec dbo.xsp_application_asset_electronic_update @p_asset_no					 = @p_asset_no
															 ,@p_electronic_category_code	 = @p_category_code	
															 ,@p_electronic_subcategory_code = @p_subcategory_code
															 ,@p_electronic_merk_code		 = @p_merk_code		
															 ,@p_electronic_model_code		 = @p_model_code		
															 ,@p_electronic_unit_code		 = @p_unit_code 
															 ,@p_colour						 = @p_colour	
															 ,@p_remarks					 = @p_remarks 
															 ,@p_mod_date					 = @p_mod_date
															 ,@p_mod_by						 = @p_mod_by
															 ,@p_mod_ip_address				 = @p_mod_ip_address ;
		end ; 
	
		if (@p_is_use_replacement = '1')
		begin
			--SET	@budget_replacement_amount = isnull(dbo.xfn_get_budget_amount(@class_code, @p_mod_date, 'REPLACEMENT', @p_asset_amount, 0, @p_unit_code, @p_start_miles, @p_monthly_miles,  ceiling((@periode  * 1.00) / 12),0,''), 0) ;
			SET	@budget_replacement_amount = round(isnull(dbo.xfn_get_budget_amount(@class_code, @p_mod_date, 'REPLACEMENT', @p_asset_amount, 0, @p_unit_code, @p_start_miles, @p_monthly_miles,  ceiling((@periode  * 1.00) / 12),0,''), 0),0) ; -- (+) Ari 2024-03-12 ket : request pak hary round normal
			
			if exists (select 1 from dbo.application_asset_budget where asset_no = @p_asset_no and cost_code = N'MBDC.2208.000001')
			begin 
				exec dbo.xsp_application_asset_budget_update @p_asset_no				= @p_asset_no
															 ,@p_cost_code				= N'MBDC.2208.000001'
															 ,@p_cost_amount_monthly	= @budget_replacement_amount
															 ,@p_cost_amount_yearly		= @budget_replacement_amount
															 ,@p_mod_date				= @p_mod_date
															 ,@p_mod_by					= @p_mod_by
															 ,@p_mod_ip_address			= @p_mod_ip_address
			end
			else
			begin 
				exec dbo.xsp_application_asset_budget_insert @p_id					 = 0
															 ,@p_asset_no			 = @p_asset_no
															 ,@p_cost_code			 = N'MBDC.2208.000001'
															 ,@p_cost_type			 = N'FIXED'
															 ,@p_cost_amount_monthly = @budget_replacement_amount
															 ,@p_cost_amount_yearly  = @budget_replacement_amount
															 ,@p_cre_date			 = @p_mod_date
															 ,@p_cre_by				 = @p_mod_by
															 ,@p_cre_ip_address		 = @p_mod_ip_address
															 ,@p_mod_date			 = @p_mod_date
															 ,@p_mod_by				 = @p_mod_by
															 ,@p_mod_ip_address		 = @p_mod_ip_address
			end
		end
		else if (@p_is_use_replacement = '0')
		begin
			exec dbo.xsp_application_asset_primary_budget_delete @p_asset_no   = @p_asset_no
														 ,@p_cost_code = N'MBDC.2208.000001'
			
		end
		
		if (@p_is_use_registration = '1')
		begin 

			if (@asset_condition = 'USED')
			begin
				--untuk mengambil original price asset - asset aksesories
				select	@original_amount_exc_acc = @p_initial_price_amount - adj.total_adjustment
				from	application_asset aa
						outer apply
				(
					select	isnull(sum(isnull(adj.total_adjustment, 0)), 0) total_adjustment
					from	ifinams.dbo.adjustment adj
							inner join ifinams.dbo.adjustment_detail adjd on (adjd.adjustment_code = adj.code)
							inner join ifinbam.dbo.master_item mi on (
																		 mi.description			   = adjd.adjustment_description
																		 and   mi.category_TYPE	   = 'ACCESSORIES'
																	 )
					where	adj.asset_code = aa.fa_code
				) adj
				where	aa.asset_no = @p_asset_no ;

				set @budget_vat_amount = @original_amount_exc_acc + (@original_amount_exc_acc * ((@parameter_calculate_asset_4 * 1.00) / 100)) ;
			end ;
			else
			begin
				set @budget_vat_amount = (@p_otr_amount - @p_discount_amount) + ((@p_karoseri_amount + (@p_karoseri_amount * ((@parameter_calculate_asset_2 * 1.00) / 100))) - @p_discount_karoseri_amount) ;
			end ;

			--set	@budget_registration_amount = isnull(dbo.xfn_get_budget_amount(@registration_class_code, @p_mod_date, 'REGISTRATION', @budget_vat_amount, 0, @p_unit_code, @p_start_miles, @p_monthly_miles,  ceiling((@periode  * 1.00) / 12),0,''), 0) ;
			set	@budget_registration_amount = round(isnull(dbo.xfn_get_budget_amount(@registration_class_code, @p_mod_date, 'REGISTRATION', @budget_vat_amount, 0, @p_unit_code, @p_start_miles, @p_monthly_miles,  ceiling((@periode  * 1.00) / 12),0,''), 0),0) ; -- (+) Ari 2024-03-12 ket : request pak hary round normal
			
			if exists (select 1 from dbo.application_asset_budget where asset_no = @p_asset_no and cost_code = N'MBDC.2301.000001')
			begin
				exec dbo.xsp_application_asset_budget_update @p_asset_no				= @p_asset_no
															 ,@p_cost_code				= N'MBDC.2301.000001'
															 ,@p_cost_amount_monthly	= @budget_registration_amount
															 ,@p_cost_amount_yearly		= @budget_registration_amount
															 ,@p_mod_date				= @p_mod_date
															 ,@p_mod_by					= @p_mod_by
															 ,@p_mod_ip_address			= @p_mod_ip_address 
			end
			else
			begin
				exec dbo.xsp_application_asset_budget_insert @p_id					 = 0
															 ,@p_asset_no			 = @p_asset_no
															 ,@p_cost_code			 = N'MBDC.2301.000001'
															 ,@p_cost_type			 = N'FIXED'
															 ,@p_cost_amount_monthly = @budget_registration_amount
															 ,@p_cost_amount_yearly  = @budget_registration_amount
															 ,@p_cre_date			 = @p_mod_date
															 ,@p_cre_by				 = @p_mod_by
															 ,@p_cre_ip_address		 = @p_mod_ip_address
															 ,@p_mod_date			 = @p_mod_date
															 ,@p_mod_by				 = @p_mod_by
															 ,@p_mod_ip_address		 = @p_mod_ip_address
			end
		end
		else if (@p_is_use_registration = '0')
		begin
			exec dbo.xsp_application_asset_primary_budget_delete @p_asset_no   = @p_asset_no
														 ,@p_cost_code = N'MBDC.2301.000001'
			
		end
		

		if(@p_is_use_maintenance = '1')
		begin  
			select	@old_budget_maintanance_amount = budget_amount
			from	dbo.application_asset_budget
			where	asset_no	  = @p_asset_no
					and cost_code = N'MBDC.2211.000003' ;

			--set @budget_maintanance_amount = isnull(dbo.xfn_get_budget_amount(@class_code, @p_mod_date, 'MAINTENANCE', @p_asset_amount, 0, @p_unit_code, @p_start_miles, @p_monthly_miles, @periode, @asset_year, @p_usage), 0) ;
			set @budget_maintanance_amount = round(isnull(dbo.xfn_get_budget_amount(@class_code, @p_mod_date, 'MAINTENANCE', @p_asset_amount, 0, @p_unit_code, @p_start_miles, @p_monthly_miles, @periode, @asset_year, @p_usage), 0),0) ; -- (+) Ari 2024-03-12 ket : request pak hary round normal
		
			if (isnull(@old_budget_maintanance_amount, 0) <> 0)
			begin
				set @old_budget_gps_amount = (isnull(@old_budget_gps_amount, 0) * @periode)
				
				set @budget_maintanance_amount = @old_budget_maintanance_amount - isnull(@old_budget_gps_amount, 0) ;
			end
			else if (isnull(@budget_maintanance_amount, 0) = 0)
			begin
				select	@budget_maintanance_amount = budget_amount
				from	dbo.application_asset_budget
				where	asset_no	  = @p_asset_no
						and cost_code = N'MBDC.2211.000003' ;
			
				if exists
				(
					select	1
					from	dbo.application_asset
					where	asset_no				   = @p_asset_no
							and is_use_gps			   = '0'
							and @old_budget_gps_amount > 0
				)
				begin
					set @old_budget_gps_amount = (isnull(@old_budget_gps_amount, 0) * @periode)
					set @budget_maintanance_amount = @budget_maintanance_amount - isnull(@old_budget_gps_amount, 0) ;
				end ;
			end ;

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
				
				set @budget_maintanance_amount = @budget_maintanance_amount + isnull(@budget_gps_amount, 0) ;
			end ;
			
			if exists (select 1 from dbo.application_asset_budget where asset_no = @p_asset_no and cost_code = N'MBDC.2211.000003')
			begin
				exec dbo.xsp_application_asset_budget_update @p_asset_no				= @p_asset_no
															 ,@p_cost_code				= N'MBDC.2211.000003'
															 ,@p_cost_amount_monthly	= @budget_maintanance_amount
															 ,@p_cost_amount_yearly		= @budget_maintanance_amount
															 ,@p_mod_date				= @p_mod_date
															 ,@p_mod_by					= @p_mod_by
															 ,@p_mod_ip_address			= @p_mod_ip_address  
			end
			else
			begin
				exec dbo.xsp_application_asset_budget_insert @p_id					 = 0
															 ,@p_asset_no			 = @p_asset_no
															 ,@p_cost_code			 = N'MBDC.2211.000003'
															 ,@p_cost_type			 = N'FIXED'
															 ,@p_cost_amount_monthly = @budget_maintanance_amount
															 ,@p_cost_amount_yearly  = @budget_maintanance_amount
															 ,@p_cre_date			 = @p_mod_date
															 ,@p_cre_by				 = @p_mod_by
															 ,@p_cre_ip_address		 = @p_mod_ip_address
															 ,@p_mod_date			 = @p_mod_date
															 ,@p_mod_by				 = @p_mod_by
															 ,@p_mod_ip_address		 = @p_mod_ip_address
			end
		end
		else if (@p_is_use_maintenance = '0')
		begin
			exec dbo.xsp_application_asset_primary_budget_delete @p_asset_no   = @p_asset_no
														 ,@p_cost_code = N'MBDC.2211.000003'
														 
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

				exec dbo.xsp_application_asset_budget_insert @p_id					 = 0
															 ,@p_asset_no			 = @p_asset_no
															 ,@p_cost_code			 = N'MBDC.2211.000003'
															 ,@p_cost_type			 = N'FIXED'
															 ,@p_cost_amount_monthly = @budget_gps_amount
															 ,@p_cost_amount_yearly  = @budget_gps_amount
															 ,@p_cre_date			 = @p_mod_date
															 ,@p_cre_by				 = @p_mod_by
															 ,@p_cre_ip_address		 = @p_mod_ip_address
															 ,@p_mod_date			 = @p_mod_date
															 ,@p_mod_by				 = @p_mod_by
															 ,@p_mod_ip_address		 = @p_mod_ip_address
			end ;
		end

		if(@p_is_use_insurance = '1')
		begin
			select	@budget_insurance_amount = isnull(total_premium_amount, 0)
			from	dbo.asset_insurance_detail
			where	asset_no = @p_asset_no ;

			if exists (select 1 from dbo.application_asset_budget where asset_no = @p_asset_no and cost_code = N'MBDC.2211.000001')
			begin
				exec dbo.xsp_application_asset_budget_update @p_asset_no				= @p_asset_no
															 ,@p_cost_code				= N'MBDC.2211.000001'
															 ,@p_cost_amount_monthly	= @budget_insurance_amount
															 ,@p_cost_amount_yearly		= @budget_insurance_amount
															 ,@p_mod_date				= @p_mod_date
															 ,@p_mod_by					= @p_mod_by
															 ,@p_mod_ip_address			= @p_mod_ip_address;  
			end;
			else
			begin
				exec dbo.xsp_application_asset_budget_insert @p_id					 = 0
															 ,@p_asset_no			 = @p_asset_no
															 ,@p_cost_code			 = N'MBDC.2211.000001'
															 ,@p_cost_type			 = N'FIXED'
															 ,@p_cost_amount_monthly = @budget_insurance_amount
															 ,@p_cost_amount_yearly  = @budget_insurance_amount
															 ,@p_cre_date			 = @p_mod_date
															 ,@p_cre_by				 = @p_mod_by
															 ,@p_cre_ip_address		 = @p_mod_ip_address
															 ,@p_mod_date			 = @p_mod_date
															 ,@p_mod_by				 = @p_mod_by
															 ,@p_mod_ip_address		 = @p_mod_ip_address;
			end; 
		end
		else if (@p_is_use_insurance = '0')
		begin  
			exec dbo.xsp_asset_insurance_detail_delete @p_asset_no = @p_asset_no ;

			exec dbo.xsp_application_asset_primary_budget_delete @p_asset_no   = @p_asset_no
														 ,@p_cost_code = N'MBDC.2211.000001'
		end

		select	@insurance_commission_rate = cast(value as decimal(9, 6))
		from	dbo.sys_global_param
		where	code = 'INSCOMM'

		select	@budget_insurance_amount = isnull(budget_amount, 0)
		from	dbo.application_asset_budget
		where	asset_no	  = @p_asset_no
				and cost_code = 'MBDC.2211.000001' ;

		if (@budget_insurance_amount > 0)
		begin
			set	@insurance_commission_amount = @budget_insurance_amount * (@insurance_commission_rate / 100)
		end
		
		set @periode_devider =ceiling((@periode * 1.00) / 12)

		if (@spaf_rate > 0 and @asset_condition <> 'USED')
		begin
			select	@spaf_otr_amount = spaf_otr_amount
			from	ifinbam.dbo.master_item
			where	code = @p_unit_code

			set @spaf_amount = @spaf_otr_amount * (@spaf_rate / 100) ;
		end ;   
		else
		begin
			set @spaf_amount = 0 ;
		end

		if (@top_days > 0)
		begin
			set @additional_charge_amount = (@p_asset_amount  + (@budget_insurance_amount / @periode_devider)) * (@borrowing_rate / 100) * @top_days / 360  ;
			--dapatkan angka monthly nya
			--SET @additional_charge_amount_m  = @additional_charge_amount /( @periode * @multiplier)
		end ;

		declare @total_insurance_subvention_bungaTop decimal(18,2)

		set @total_insurance_subvention_bungaTop = (isnull(@p_subvention_amount, 0) * -1) - isnull(@insurance_commission_amount, 0) + @additional_charge_amount
		
		--select	@total_budget_amount = ((isnull(sum(isnull(budget_amount, 0)), 0) + isnull(@p_mobilization_amount, 0) - isnull(@p_subvention_amount, 0)  - isnull(@insurance_commission_amount, 0)) / @periode)
		--from	dbo.application_asset_budget
		--where	asset_no = @p_asset_no ;

		select	@total_budget_amount = isnull(sum(isnull(budget_amount, 0)), 0)
		from	dbo.application_asset_budget
		where	asset_no = @p_asset_no ;

		set	@basic_lease_amount = ((@total_budget_amount  + isnull(@p_gps_installation_amount, 0) + @total_insurance_subvention_bungaTop) + (@pmt_amount * @periode) + @p_mobilization_amount) / ceiling((@periode * 1.00) / @multiplier) --+ @additional_charge_amount_m

		-- Louis Senin, 20 Mei 2024 10.19.04 -- untuk menghitung rental bulanan
		set @monthly_lease_rounded_amount = ((@total_budget_amount  + isnull(@p_gps_installation_amount, 0) + @total_insurance_subvention_bungaTop) + (@pmt_amount * @periode) + @p_mobilization_amount) / (@periode * 1.00) 
		
		if (@rounding_type = 'DOWN')
		begin
			--set @lease_rounded_amount = dbo.fn_get_floor((@basic_lease_amount), @rounding_value) ;
			set @monthly_lease_rounded_amount = dbo.fn_get_floor((@monthly_lease_rounded_amount), @rounding_value) ;
		end
		else if (@rounding_type = 'UP')
		begin
			--set @lease_rounded_amount = dbo.fn_get_ceiling((@basic_lease_amount), @rounding_value) ;
			set @monthly_lease_rounded_amount = dbo.fn_get_ceiling((@monthly_lease_rounded_amount), @rounding_value) ;
		end
		else
		begin
			--set @lease_rounded_amount = dbo.fn_get_round((@basic_lease_amount), @rounding_value) ;
			set @monthly_lease_rounded_amount = dbo.fn_get_round((@monthly_lease_rounded_amount), @rounding_value) ;
		end
		 
		-- Louis Senin, 20 Mei 2024 10.19.04 -- untuk menghitung rental rounded amount dari monthly lease
		set @lease_rounded_amount = @monthly_lease_rounded_amount * @multiplier
	
		update	dbo.application_asset
		set		basic_lease_amount				= @basic_lease_amount
				,lease_amount					= @basic_lease_amount
				,lease_rounded_amount			= @lease_rounded_amount
				,additional_charge_amount		= @additional_charge_amount
				,insurance_commission_amount	= @insurance_commission_amount
				,spaf_amount					= @spaf_amount
				,monthly_rental_rounded_amount	= @monthly_lease_rounded_amount
		where	asset_no						= @p_asset_no ;
		 
		--kebutuhan data maintenance
		begin
			exec dbo.xsp_mtn_application_rental @p_application_no	= @p_application_no
												,@p_mod_date		= @p_mod_date
												,@p_mod_by			= @p_mod_by
												,@p_mod_ip_address	= @p_mod_ip_address
			
		end

		exec dbo.xsp_application_amortization_calculate @p_asset_no			= @p_asset_no
														,@p_cre_date		= @p_mod_date
														,@p_cre_by			= @p_mod_by
														,@p_cre_ip_address	= @p_mod_ip_address
														,@p_mod_date		= @p_mod_date
														,@p_mod_by			= @p_mod_by
														,@p_mod_ip_address	= @p_mod_ip_address
		
		--digunakan untuk mengcalculate nilai application asset (ROA, avg asset, yearly profit)
		exec dbo.xsp_application_asset_calculate @p_asset_no		= @p_asset_no
												 ,@p_spaf_rate		= @spaf_rate
												 ,@p_mod_date		= @p_mod_date		
												 ,@p_mod_by			= @p_mod_by			
												 ,@p_mod_ip_address = @p_mod_ip_address 

		exec dbo.xsp_application_main_rental_amount_update @p_application_no	= @p_application_no
														   ,@p_mod_date			= @p_mod_date
														   ,@p_mod_by			= @p_mod_by
														   ,@p_mod_ip_address	= @p_mod_ip_address
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





