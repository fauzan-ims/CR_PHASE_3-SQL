CREATE PROCEDURE dbo.xsp_realization_to_agreement_insert
(
	@p_code			   nvarchar(50)
	,@p_agreement_no   nvarchar(50)
	,@p_application_no nvarchar(50)
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
	declare @msg				   nvarchar(max)
			,@ppn_pct			   decimal(9, 6)
			,@pph_pct			   decimal(9, 6)
			,@os_rental_amount	   decimal(18, 2)
			,@os_period			   int
			,@installment_due_date datetime
			,@maturity_date		   datetime
			,@installment_amount   decimal(18, 2)
			,@deskcoll_staff_code  nvarchar(50)
			,@deskcoll_staff_name  nvarchar(250)
			,@asset_no			   nvarchar(50)
			,@handover_bast_date   datetime
			,@first_payment_type   nvarchar(3)
			,@log_remarks		   nvarchar(4000) ;

	begin try 		
		-- interface application main
		begin
			select	@ppn_pct = value
			from	dbo.sys_global_param
			where	code = 'RTAXPPN' ;

			select	@pph_pct = value
			from	dbo.sys_global_param
			where	code = 'RTAXPPH' ;

			insert into dbo.agreement_main
			(
				agreement_no
				,agreement_external_no
				,application_no
				,application_no_external
				,agreement_date
				,agreement_status
				,agreement_sub_status
				,termination_date
				,termination_status
				,collection_status
				,branch_code
				,branch_name
				,initial_branch_code
				,initial_branch_name
				,currency_code
				,facility_code
				,facility_name
				,client_type
				,client_id
				,client_no
				,client_name
				,tax_scheme_code
				,ppn_pct
				,pph_pct
				,old_agreement_no
				,maturity_code
				,is_stop_billing
				,is_pending_billing
				,periode
				,billing_type
				,credit_term
				,first_payment_type
				,is_purchase_requirement_after_lease
				,lease_option
				,round_type
				,round_amount
				,marketing_code
				,marketing_name
				,agreement_sign_date
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	rz.agreement_no
					,rz.agreement_external_no
					,rz.application_no
					,am.application_external_no
					,dbo.xfn_get_system_date()
					,'GO LIVE'
					,''
					,null
					,null
					,''
					,rz.branch_code
					,rz.branch_name
					,rz.branch_code
					,rz.branch_name
					,am.currency_code
					,am.facility_code
					,mf.description
					,cm.client_type
					,cm.client_id
					,cm.client_no
					,cm.client_name
					,null
					,@ppn_pct
					,@pph_pct
					,null
					,null
					,'0'
					,'0'
					,am.periode
					,am.billing_type
					,am.credit_term
					,am.first_payment_type
					,am.is_purchase_requirement_after_lease
					,am.lease_option
					,am.round_type
					,am.round_amount
					,am.marketing_code
					,am.marketing_name
					,rz.agreement_date
					--
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
			from	dbo.realization rz
					inner join dbo.application_main am on (am.application_no = rz.application_no)
					inner join dbo.client_main cm on (cm.code				 = am.client_code)
					inner join dbo.master_facility mf on (mf.code			 = am.facility_code)
			where	rz.code = @p_code ;

			--insert ke application charges
			begin

				delete	dbo.application_charges
				where	application_no in
						(
							select	application_no
							from	dbo.realization
							where	code = @p_code
						) ;

				insert into dbo.application_charges
				(
					application_no
					,charges_code
					,dafault_charges_rate
					,dafault_charges_amount
					,calculate_by
					,charges_rate
					,charges_amount
					,new_calculate_by
					,new_charges_rate
					,new_charges_amount
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select	ae.application_no
						,mcc.charges_code
						,mcc.dafault_charges_rate
						,mcc.dafault_charges_amount
						,mcc.calculate_by
						,mcc.charges_rate
						,mcc.charges_amount
						,mcc.new_calculate_by
						,mcc.new_charges_rate
						,mcc.new_charges_amount
						--
						,@p_cre_date
						,@p_cre_by
						,@p_cre_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
				from	dbo.main_contract_charges mcc
						inner join dbo.application_extention ae on (ae.main_contract_no = mcc.main_contract_no)
						inner join dbo.realization rz on (rz.application_no				= ae.application_no)
				where	rz.code = @p_code ;
			end ;

			insert into dbo.agreement_charges
			(
				agreement_no
				,charges_code
				,charges_name
				,calculate_by
				,charges_rate
				,charges_amount
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	rz.agreement_no
					,ac.charges_code
					,mc.description
					,ac.calculate_by
					,isnull(ac.new_charges_rate, ac.charges_rate)
					,isnull(ac.new_charges_amount, ac.charges_amount)
					--
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
			from	dbo.application_charges ac
					inner join dbo.master_charges mc on (mc.code		= ac.charges_code)
					inner join dbo.realization rz on (rz.application_no = ac.application_no)
			where	rz.code = @p_code ;

			-- asset
			begin
				insert into dbo.agreement_asset
				(
					asset_no
					,agreement_no
					,asset_type_code
					,asset_name
					,asset_year
					,asset_condition
					,asset_status
					,billing_to
					,billing_to_name
					,billing_to_area_no
					,billing_to_phone_no
					,billing_to_address
					,billing_to_npwp
					,billing_to_faktur_type
					,billing_type
					,billing_mode
					,billing_mode_date
					,npwp_address
					,is_purchase_requirement_after_lease
					,deliver_to
					,deliver_to_name
					,deliver_to_area_no
					,deliver_to_phone_no
					,deliver_to_address
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
					,first_payment_type
					,lease_option
					,cogs_amount
					,basic_lease_amount
					,margin_by
					,margin_rate
					,margin_amount
					,additional_charge_rate
					,additional_charge_amount
					,lease_amount
					,lease_round_type
					,lease_round_amount
					,lease_rounded_amount
					,net_margin_amount
					,handover_code
					,handover_bast_date
					,handover_status
					,handover_remark
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
					,replacement_end_date
					,return_date
					,return_status
					,return_remark
					,email
					,is_auto_email
					,npwp_name
					,pickup_phone_area_no
					,pickup_phone_no
					,pickup_name
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
					,estimate_delivery_date
					,estimate_po_date
					,is_request_gts
					,is_bbn_client
					,client_bbn_name
					,client_bbn_address
					,pmt_amount
					,subvention_amount
					,insurance_commission_amount
					,spaf_amount
					,average_asset_amount
					,yearly_profit_amount
					,roa_pct
					,total_budget_amount
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
					,budget_maintenance_amount
					,budget_insurance_amount
					,budget_replacement_amount
					,budget_registration_amount
					,is_invoice_deduct_pph
					,is_receipt_deduct_pph
					,otr_amount
					,monthly_rental_rounded_amount
					,is_use_gps
					,gps_monthly_amount
					,gps_installation_amount
					,client_nitku -- raffy(+) 2025/02/13 CR NITKU
					--									   		 
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select	rzd.asset_no
						,rz.agreement_no
						,aa.asset_type_code
						,aa.asset_name
						,aa.asset_year
						,aa.asset_condition
						,'RENTED'
						,aa.billing_to
						,aa.billing_to_name
						,aa.billing_to_area_no
						,aa.billing_to_phone_no
						,aa.billing_to_address
						,aa.billing_to_npwp
						,aa.billing_to_faktur_type
						,aa.billing_type
						,aa.billing_mode
						,aa.billing_mode_date
						,aa.npwp_address
						,aa.is_purchase_requirement_after_lease
						,aa.deliver_to
						,aa.deliver_to_name
						,aa.deliver_to_area_no
						,aa.deliver_to_phone_no
						,aa.deliver_to_address
						,aa.pickup_address
						,aa.market_value
						,aa.karoseri_amount
						,aa.accessories_amount
						,aa.mobilization_amount
						,aa.asset_amount
						,aa.asset_interest_rate
						,aa.asset_interest_amount
						,aa.asset_rv_pct
						,aa.asset_rv_amount
						,aa.periode
						,am.first_payment_type
						,aa.lease_option
						,aa.cogs_amount
						,aa.basic_lease_amount
						,aa.margin_by
						,aa.margin_rate
						,aa.margin_amount
						,aa.additional_charge_rate
						,aa.additional_charge_amount
						,aa.lease_amount
						,aa.round_type
						,aa.round_amount
						,aa.lease_rounded_amount
						,aa.net_margin_amount
						,aa.handover_code
						,aa.handover_bast_date
						,aa.handover_status
						,aa.handover_remark
						,case when isnull(aa.is_request_gts, '0') = '0' then aa.fa_code else null end
						,case when isnull(aa.is_request_gts, '0') = '0' then aa.fa_name else null end
						,case when isnull(aa.is_request_gts, '0') = '0' then aa.fa_reff_no_01 else null end
						,case when isnull(aa.is_request_gts, '0') = '0' then aa.fa_reff_no_02 else null end
						,case when isnull(aa.is_request_gts, '0') = '0' then aa.fa_reff_no_03 else null end
						,case when isnull(aa.is_request_gts, '0') = '1' then aa.replacement_fa_code else null end 
						,case when isnull(aa.is_request_gts, '0') = '1' then aa.replacement_fa_name else null end 
						,case when isnull(aa.is_request_gts, '0') = '1' then aa.replacement_fa_reff_no_01 else null end 
						,case when isnull(aa.is_request_gts, '0') = '1' then aa.replacement_fa_reff_no_02 else null end 
						,case when isnull(aa.is_request_gts, '0') = '1' then aa.replacement_fa_reff_no_03 else null end 
						,null
						,null
						,null
						,null
						,aa.email
						,aa.is_auto_email
						,aa.npwp_name
						,aa.pickup_phone_area_no
						,aa.pickup_phone_no
						,aa.pickup_name
						,aa.is_otr
						,aa.bbn_location_code
						,aa.bbn_location_description
						,aa.plat_colour
						,aa.usage
						,aa.start_miles
						,aa.monthly_miles
						,aa.is_use_registration
						,aa.is_use_replacement
						,aa.is_use_maintenance
						,aa.request_delivery_date
						,aa.estimate_po_date
						,aa.is_request_gts
						,aa.is_bbn_client
						,aa.client_bbn_name
						,aa.client_bbn_address
						,aa.pmt_amount
						,aa.subvention_amount
						,aa.insurance_commission_amount
						,aa.spaf_amount
						,aa.average_asset_amount
						,aa.yearly_profit_amount
						,aa.roa_pct
						,aab.total_budget
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
						,isnull(bma.budget_maintenance_amount, 0)
						,isnull(bia.budget_insurance_amount, 0)
						,isnull(bra.budget_replacement_amount, 0)
						,isnull(brega.budget_registration_amount, 0)
						,'1'
						,'1'
						,otr_amount
						,isnull(aa.monthly_rental_rounded_amount, 0)
						,is_use_gps
						,gps_monthly_amount
						,gps_installation_amount
						,aa.client_nitku
						--
						,@p_cre_date
						,@p_cre_by
						,@p_cre_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
				from	dbo.application_asset aa
						inner join dbo.realization_detail rzd on (rzd.asset_no	 = aa.asset_no)
						inner join dbo.realization rz on (rz.code				 = rzd.realization_code)
						inner join dbo.application_main am on (am.application_no = rz.application_no)
						outer apply
				(
					select	sum(aab.budget_amount) 'total_budget'
					from	dbo.application_asset_budget aab
					where	aab.asset_no = aa.asset_no
				) aab
						outer apply
				(
					select	aab.budget_amount 'budget_maintenance_amount'
					from	dbo.application_asset_budget aab
					where	aab.asset_no	  = aa.asset_no
							and aab.cost_code = 'MBDC.2211.000003'
				) bma
						outer apply
				(
					select	aab.budget_amount 'budget_insurance_amount'
					from	dbo.application_asset_budget aab
					where	aab.asset_no	  = aa.asset_no
							and aab.cost_code = 'MBDC.2211.000001'
				) bia
						outer apply
				(
					select	aab.budget_amount 'budget_replacement_amount'
					from	dbo.application_asset_budget aab
					where	aab.asset_no	  = aa.asset_no
							and aab.cost_code = 'MBDC.2208.000001'
				) bra
						outer apply
				(
					select	aab.budget_amount 'budget_registration_amount'
					from	dbo.application_asset_budget aab
					where	aab.asset_no	  = aa.asset_no
							and aab.cost_code = 'MBDC.2301.000001'
				) brega
				where	rz.code = @p_code ;


				SELECT * FROM dbo.APPLICATION_ASSET_BUDGET WHERE ASSET_NO = '2001.OPLAA.2508.000289'

				insert into dbo.agreement_asset_amortization
				(
					agreement_no
					,billing_no
					,asset_no
					,due_date
					,billing_date
					,billing_amount
					,description
					,invoice_no
					,generate_code
					,hold_billing_status
					,hold_date
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select	rz.agreement_no
						,aa.installment_no
						,rzd.asset_no
						,aa.due_date
						,aa.billing_date
						,aa.billing_amount
						,aa.description
						,null
						,null
						,''
						,null
						--
						,@p_cre_date
						,@p_cre_by
						,@p_cre_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
				from	dbo.application_amortization aa
						inner join dbo.realization_detail rzd on (rzd.asset_no = aa.asset_no)
						inner join dbo.realization rz on (rz.code			   = rzd.realization_code)
				where	rz.code = @p_code ;

				insert into dbo.agreement_asset_vehicle
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
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				select	aav.asset_no
						,aav.vehicle_category_code
						,aav.vehicle_subcategory_code
						,aav.vehicle_merk_code
						,aav.vehicle_model_code
						,aav.vehicle_type_code
						,aav.vehicle_unit_code
						,aav.colour
						,aav.transmisi
						,aav.remarks
						--
						,@p_cre_date
						,@p_cre_by
						,@p_cre_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
				from	dbo.application_asset_vehicle aav
						inner join dbo.realization_detail rzd on (rzd.asset_no = aav.asset_no)
				where	rzd.realization_code = @p_code ;

				insert into dbo.agreement_asset_machine
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
				select	aam.asset_no
						,aam.machinery_category_code
						,aam.machinery_subcategory_code
						,aam.machinery_merk_code
						,aam.machinery_model_code
						,aam.machinery_type_code
						,aam.machinery_unit_code
						,aam.colour
						,aam.remarks
						--
						,@p_cre_date
						,@p_cre_by
						,@p_cre_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
				from	dbo.application_asset_machine aam
						inner join dbo.realization_detail rzd on (rzd.asset_no = aam.asset_no)
				where	rzd.realization_code = @p_code ;

				insert into dbo.agreement_asset_he
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
				select	aah.asset_no
						,aah.he_category_code
						,aah.he_subcategory_code
						,aah.he_merk_code
						,aah.he_model_code
						,aah.he_type_code
						,aah.he_unit_code
						,aah.colour
						,aah.remarks
						--
						,@p_cre_date
						,@p_cre_by
						,@p_cre_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
				from	dbo.application_asset_he aah
						inner join dbo.realization_detail rzd on (rzd.asset_no = aah.asset_no)
				where	rzd.realization_code = @p_code ;

				insert into dbo.agreement_asset_electronic
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
				select	aae.asset_no
						,aae.electronic_category_code
						,aae.electronic_subcategory_code
						,aae.electronic_merk_code
						,aae.electronic_model_code
						,aae.electronic_unit_code
						,aae.colour
						,aae.remarks
						--
						,@p_cre_date
						,@p_cre_by
						,@p_cre_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
				from	dbo.application_asset_electronic aae
						inner join dbo.realization_detail rzd on (rzd.asset_no = aae.asset_no)
				where	rzd.realization_code = @p_code ;
				
				select	@deskcoll_staff_code = am.marketing_code
						,@deskcoll_staff_name = am.marketing_name
				from	dbo.realization rz
						inner join dbo.application_main am on (am.application_no = rz.application_no)
				where	rz.code = @p_code ;

				select	@os_period = periode
						,@first_payment_type = first_payment_type
						,@handover_bast_date = handover_bast_date
				from	dbo.agreement_asset
				where	agreement_no = @p_agreement_no ; 

				select	@installment_amount = isnull(sum(isnull(lease_rounded_amount,0)),0)
				from	dbo.agreement_asset
				where	agreement_no = @p_agreement_no ; 

				select	@os_rental_amount = isnull(sum(isnull(billing_amount, 0)), 0)
						,@installment_due_date = min(due_date)
						,@maturity_date = dateadd(month, @os_period, @handover_bast_date)
				from	dbo.agreement_asset_amortization
				where	agreement_no = @p_agreement_no ;

				insert into dbo.agreement_information
				(
					agreement_no
					,deskcoll_staff_code
					,deskcoll_staff_name
					,installment_amount
					,installment_due_date
					,next_due_date
					,last_paid_period
					,ovd_period
					,ovd_days
					,ovd_rental_amount
					,ovd_penalty_amount
					,os_rental_amount
					,os_deposit_installment_amount
					,os_period
					,last_payment_installment_date
					,last_payment_obligation_date
					,maturity_date
					,max_ovd_days
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				values
				(	@p_agreement_no
					,@deskcoll_staff_code
					,@deskcoll_staff_name
					,@installment_amount
					,@installment_due_date
					,@installment_due_date
					,0
					,0
					,0
					,0
					,0
					,@os_rental_amount 
					,0
					,@os_period 
					,null
					,null
					,@maturity_date
					,0
					--
					,@p_cre_date	   
					,@p_cre_by		   
					,@p_cre_ip_address 
					,@p_mod_date	   
					,@p_mod_by		   
					,@p_mod_ip_address 
				) 
				
				update	dbo.application_asset
				set		agreement_no	 = @p_agreement_no 
						--
						,mod_date		 = @p_mod_date
						,mod_by			 = @p_mod_by
						,mod_ip_address  = @p_mod_ip_address 
				where   realization_code = @p_code
		
				--insert to agreement out untuk intergrasi
				exec dbo.xsp_opl_interface_agreement_main_out_insert @p_agreement_no	= @p_agreement_no
																	 --
																	 ,@p_cre_date		= @p_mod_date
																	 ,@p_cre_by			= @p_mod_by
																	 ,@p_cre_ip_address = @p_mod_ip_address
																	 ,@p_mod_date		= @p_mod_date
																	 ,@p_mod_by			= @p_mod_by
																	 ,@p_mod_ip_address = @p_mod_ip_address
																	 
				select top 1
						@asset_no = asset_no
				from	dbo.realization_detail
				where	realization_code = @p_code ;

				set @log_remarks = 'Realization Application : ' + @p_application_no

				exec dbo.xsp_agreement_log_insert @p_id					= 0
												  ,@p_agreement_no		= @p_agreement_no
												  ,@p_log_date			= @p_mod_date
												  ,@p_asset_no			= @asset_no
												  ,@p_log_source_no		= @p_code
												  ,@p_log_remarks		= @log_remarks
												  ,@p_cre_date			= @p_mod_date
												  ,@p_cre_by			= @p_mod_by
												  ,@p_cre_ip_address	= @p_mod_ip_address
												  ,@p_mod_date			= @p_mod_date
												  ,@p_mod_by			= @p_mod_by
												  ,@p_mod_ip_address	= @p_mod_ip_address
			end ;
		end ;
	end try
	begin catch 

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