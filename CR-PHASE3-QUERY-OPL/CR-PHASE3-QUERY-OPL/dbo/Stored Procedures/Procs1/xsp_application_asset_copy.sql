CREATE PROCEDURE [dbo].[xsp_application_asset_copy]
(
	@p_asset_no		   nvarchar(50)
	,@p_number_of_copy int
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg			  nvarchar(max)
			,@year			  nvarchar(2)
			,@month			  nvarchar(2)
			,@code			  nvarchar(50)
			,@application_no  nvarchar(50)
			,@copy_count	  int		   = 0
			,@branch_code	  nvarchar(50)
			,@asset_type_code nvarchar(50) ;

	select	@branch_code = branch_code
			,@asset_type_code = aa.asset_type_code
			,@application_no = aa.application_no
	from	dbo.application_main am
			inner join application_asset aa on (aa.application_no = am.application_no)
	where	asset_no = @p_asset_no ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	if (@p_number_of_copy < 0)
	begin
		set @msg = 'Copy Asset cannot less than 0' ;

		raiserror(@msg, 16, -1) ;
	end ;

	begin try
		while (@copy_count < @p_number_of_copy)
		begin
			exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
														,@p_branch_code = @branch_code
														,@p_sys_document_code = N''
														,@p_custom_prefix = 'OPLAA'
														,@p_year = @year
														,@p_month = @month
														,@p_table_name = 'APPLICATION_ASSET'
														,@p_run_number_length = 6
														,@p_delimiter = '.'
														,@p_run_number_only = N'0' ;
														 
														 
			insert into dbo.application_asset
			(
				asset_no
				,application_no
				,asset_type_code
				,asset_name
				,asset_year
				,asset_condition
				,unit_code
				,billing_to
				,billing_to_name
				,billing_to_area_no
				,billing_to_phone_no
				,billing_to_address
				,billing_to_faktur_type
				,billing_type
				,billing_mode
				,billing_mode_date
				,billing_to_npwp
				,npwp_name
				,npwp_address
				,is_purchase_requirement_after_lease
				,deliver_to
				,deliver_to_name
				,deliver_to_area_no
				,deliver_to_phone_no
				,deliver_to_address
				,pickup_name
				,pickup_phone_area_no
				,pickup_phone_no
				,pickup_address
				,market_value
				,karoseri_amount
				,accessories_amount
				,mobilization_amount
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
				,handover_code
				,handover_bast_date
				,handover_status
				,handover_remark
				,purchase_code
				,purchase_status
				,purchase_gts_code
				,purchase_gts_status
				,fa_code
				,fa_name
				,fa_reff_no_01
				,fa_reff_no_02
				,fa_reff_no_03
				,replacement_fa_code
				,replacement_fa_name
				,replacement_fa_reff_no_01
				,replacement_fa_reff_no_02
				,replacement_fa_reff_no_03
				,realization_code
				,request_delivery_date
				,bast_date
				,first_rental_date
				,budget_approval_code
				,is_asset_delivery_request_printed
				,is_calculate_amortize
				,is_request_gts
				,estimate_po_date
				,email
				,is_auto_email
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
				,is_bbn_client
				,client_bbn_name
				,client_bbn_address
				,pmt_amount
				,initial_price_amount
				,subvention_amount
				,spaf_amount
				,insurance_commission_amount
				,average_asset_amount
				,yearly_profit_amount
				,roa_pct
				,mobilization_city_code
				,mobilization_city_description
				,mobilization_province_code
				,mobilization_province_description
				,borrowing_interest_rate
				,borrowing_interest_amount
				,discount_amount
				,discount_karoseri_amount
				,discount_accessories_amount
				,surat_no
				,agreement_no
				,otr_amount
				,monthly_rental_rounded_amount
				,is_cancel
				,is_use_gps
				,gps_monthly_amount
				,gps_installation_amount
				--Raffy CR NITKU
				,client_nitku
				-- Louis Senin, 07 Juli 2025 16.53.36 --
				,unit_source
				,start_due_date
				,prorate
				-- Louis Senin, 07 Juli 2025 16.53.36 --

				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	@code
					,application_no
					,asset_type_code
					,asset_name
					,asset_year
					,asset_condition
					,unit_code
					,billing_to
					,billing_to_name
					,billing_to_area_no
					,billing_to_phone_no
					,billing_to_address
					,billing_to_faktur_type
					,billing_type
					,billing_mode
					,billing_mode_date
					,billing_to_npwp
					,npwp_name
					,npwp_address
					,is_purchase_requirement_after_lease
					,deliver_to
					,deliver_to_name
					,deliver_to_area_no
					,deliver_to_phone_no
					,deliver_to_address
					,pickup_name
					,pickup_phone_area_no
					,pickup_phone_no
					,pickup_address
					,market_value
					,karoseri_amount
					,accessories_amount
					,mobilization_amount
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
					,handover_code
					,handover_bast_date
					,handover_status
					,handover_remark
					,purchase_code
					,purchase_status
					,purchase_gts_code
					,purchase_gts_status
					,fa_code
					,fa_name
					,fa_reff_no_01
					,fa_reff_no_02
					,fa_reff_no_03
					,replacement_fa_code
					,replacement_fa_name
					,replacement_fa_reff_no_01
					,replacement_fa_reff_no_02
					,replacement_fa_reff_no_03
					,realization_code
					,request_delivery_date
					,bast_date
					,first_rental_date
					,budget_approval_code
					,is_asset_delivery_request_printed
					,is_calculate_amortize
					,is_request_gts
					,estimate_po_date
					,email
					,is_auto_email
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
					,is_bbn_client
					,client_bbn_name
					,client_bbn_address
					,pmt_amount
					,initial_price_amount
					,subvention_amount
					,spaf_amount
					,insurance_commission_amount
					,average_asset_amount
					,yearly_profit_amount
					,roa_pct
					,mobilization_city_code
					,mobilization_city_description
					,mobilization_province_code
					,mobilization_province_description
					,borrowing_interest_rate
					,borrowing_interest_amount
					,discount_amount
					,discount_karoseri_amount
					,discount_accessories_amount
					,surat_no
					,agreement_no
					,otr_amount
					,monthly_rental_rounded_amount
					,is_cancel
					,is_use_gps
					,gps_monthly_amount
					,gps_installation_amount
					,client_nitku
					-- Louis Senin, 07 Juli 2025 16.53.36 --
					,unit_source
					,start_due_date
					,prorate
					-- Louis Senin, 07 Juli 2025 16.53.36 --
					--
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
			from	dbo.application_asset
			where	asset_no = @p_asset_no ;
			INSERT INTO dbo.APPLICATION_ASSET_DETAIL
			(
				code
				,asset_no
				,type
				,description
				,amount
				,merk_code
				,merk_description
				,model_code
				,model_description
				,type_code
				,type_description
				,purchase_code
				,purchase_status
				,is_subject_to_purchase
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)  
			select	code
					,@code
					,type
					,description
					,amount
					,merk_code
					,merk_description
					,model_code
					,model_description
					,type_code
					,type_description
					,purchase_code
					,purchase_status
					,is_subject_to_purchase
					--
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
			from	dbo.application_asset_detail
			where	asset_no = @p_asset_no ;

			insert into dbo.application_asset_budget
			(
				asset_no
				,cost_code
				,cost_type
				,cost_amount_monthly
				,cost_amount_yearly
				,budget_adjustment_amount
				,budget_amount
				,is_subject_to_purchase
				,purchase_code
				,purchase_status
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)  
			select	@code
					,cost_code
					,cost_type
					,cost_amount_monthly
					,cost_amount_yearly
					,budget_adjustment_amount
					,budget_amount
					,is_subject_to_purchase
					,purchase_code
					,purchase_status
					--
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
			from	dbo.application_asset_budget
			where	asset_no = @p_asset_no ;

			insert into dbo.asset_insurance_detail
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
				,is_tbod
				,tbod_premium_amount
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			) 
			select	@code
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
					,is_tbod
					,tbod_premium_amount
					--
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
			from	dbo.asset_insurance_detail
			where	asset_no = @p_asset_no ;

			if @asset_type_code = 'VHCL'
			begin
				insert into dbo.application_asset_vehicle
				(
					asset_no
					,vehicle_category_code
					,vehicle_subcategory_code
					,vehicle_merk_code
					,vehicle_model_code
					,vehicle_type_code
					,vehicle_unit_code
					,colour
					,transmisi
					,remarks
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select	@code
						,vehicle_category_code
						,vehicle_subcategory_code
						,vehicle_merk_code
						,vehicle_model_code
						,vehicle_type_code
						,vehicle_unit_code
						,colour
						,transmisi
						,remarks
						--
						,@p_cre_date
						,@p_cre_by
						,@p_cre_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
				from	dbo.application_asset_vehicle
				where	asset_no = @p_asset_no ;
			end ;
			else if @asset_type_code = 'MCHN'
			begin
				insert into dbo.application_asset_machine
				(
					asset_no
					,machinery_category_code
					,machinery_subcategory_code
					,machinery_merk_code
					,machinery_model_code
					,machinery_type_code
					,machinery_unit_code
					,colour
					,remarks
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select	@code
						,machinery_category_code
						,machinery_subcategory_code
						,machinery_merk_code
						,machinery_model_code
						,machinery_type_code
						,machinery_unit_code
						,colour
						,remarks
						--
						,@p_cre_date
						,@p_cre_by
						,@p_cre_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
				from	dbo.application_asset_machine
				where	asset_no = @p_asset_no ;
			end ;
			else if @asset_type_code = 'HE'
			begin
				insert into dbo.application_asset_he
				(
					asset_no
					,he_category_code
					,he_subcategory_code
					,he_merk_code
					,he_model_code
					,he_type_code
					,he_unit_code
					,colour
					,remarks
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select	@code
						,he_category_code
						,he_subcategory_code
						,he_merk_code
						,he_model_code
						,he_type_code
						,he_unit_code
						,colour
						,remarks
						--
						,@p_cre_date
						,@p_cre_by
						,@p_cre_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
				from	dbo.application_asset_he
				where	asset_no = @p_asset_no ;
			end ;
			else if @asset_type_code = 'ELEC'
			begin
				insert into dbo.application_asset_electronic
				(
					asset_no
					,electronic_category_code
					,electronic_subcategory_code
					,electronic_merk_code
					,electronic_model_code
					,electronic_unit_code
					,colour
					,remarks
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select	@code
						,electronic_category_code
						,electronic_subcategory_code
						,electronic_merk_code
						,electronic_model_code
						,electronic_unit_code
						,colour
						,remarks
						--
						,@p_cre_date
						,@p_cre_by
						,@p_cre_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
				from	dbo.application_asset_electronic
				where	asset_no = @p_asset_no ;
			end ;

			insert into dbo.application_amortization
			(
				application_no
				,installment_no
				,asset_no
				,due_date
				,billing_date
				,billing_amount
				,description
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	application_no
					,installment_no
					,@code
					,due_date
					,billing_date
					,billing_amount
					,description
					--
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
			from	dbo.application_amortization
			where	asset_no = @p_asset_no ;

			set @copy_count += 1 ;

			--update total rental amount pada application
			exec dbo.xsp_application_main_rental_amount_update @p_application_no = @application_no
															   ,@p_mod_date = @p_mod_date
															   ,@p_mod_by = @p_mod_by
															   ,@p_mod_ip_address = @p_mod_ip_address ;
		end ;
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
