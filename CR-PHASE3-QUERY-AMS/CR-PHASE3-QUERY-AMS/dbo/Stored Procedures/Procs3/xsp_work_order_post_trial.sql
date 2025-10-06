CREATE PROCEDURE dbo.xsp_work_order_post_trial
(
	@p_code			   NVARCHAR(50)
	--
	,@p_mod_date	   DATETIME
	,@p_mod_by		   NVARCHAR(15)
	,@p_mod_ip_address NVARCHAR(15)
)
AS
BEGIN
	declare @msg							nvarchar(max)
			,@status						nvarchar(20)
			,@company_code					nvarchar(50)
			,@maintenance_code				nvarchar(50)
			,@remarks						nvarchar(4000)
			,@asset_code					nvarchar(50)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@code_interface				nvarchar(50)
			,@payment_amount				decimal(18,2)
			,@sp_name						nvarchar(250)
			,@debet_or_credit				nvarchar(10)
			,@gl_link_code					nvarchar(50)
			,@transaction_name				nvarchar(250)
			,@orig_amount_cr				decimal(18, 2)
			,@orig_amount_db				decimal(18, 2)
			,@amount						decimal(18, 2)
			,@return_value					decimal(18, 2)
			,@year							nvarchar(4)
			,@month							nvarchar(2)
			,@code							nvarchar(50)
			,@vendor_name					nvarchar(250)
			,@requestor_name				nvarchar(250)
			,@adress						nvarchar(4000)
			,@phone_no						nvarchar(15)
			,@service_code					nvarchar(50)
			,@service_name					nvarchar(250)
			,@actual_km						bigint
			,@service_type					nvarchar(50)
			,@date							datetime
			,@reff_remark					nvarchar(4000)
			,@item_name						nvarchar(250)
			,@work_date						datetime
			,@hour_meter					int
			,@id_asset_maintenance_schedule	bigint
			,@trx_no						nvarchar(50)
			,@is_maintenance				nvarchar(1)
			,@code_payment_request			nvarchar(50)
			,@pph_amount_payment			decimal(18,2)
			,@ppn_amount_payment			decimal(18,2)
			,@payment_amount_payment		decimal(18,2)
			,@total_amount_payment			decimal(18,2)
			,@payment_remark				nvarchar(4000)
			,@base_amount					decimal(18, 2)
			,@base_amount_db				decimal(18, 2)
			,@base_amount_cr				decimal(18, 2)
			,@reff_source_name				nvarchar(250)
			,@gllink_trx_code				nvarchar(50)
			,@debit_or_credit				nvarchar(50)
			,@category_code					nvarchar(50)
			,@purchase_price				decimal(18,2)
			,@is_valid						int
			,@x_code						nvarchar(50)
			,@exch_rate						decimal(18, 2) = 1
			,@detail_remark					nvarchar(250)
			,@id_detail						int
			,@vendor_code					nvarchar(50)
			,@vendor_bank_name				nvarchar(250)
			,@vendor_bank_account_no		nvarchar(50)
			,@vendor_bank_account_name		nvarchar(250)
			,@is_reimburse					nvarchar(1)
			,@ppn_amount					decimal(18,2)
			,@pph_amount					decimal(18,2)
			,@agreement_no					nvarchar(50)
			,@asset_no						nvarchar(50)
			,@client_no						nvarchar(50)
			,@client_name					nvarchar(250)
			,@description_request			nvarchar(250)
			,@wod_id						bigint
			,@quantity						INT
            ,@remark						nvarchar(4000)
			,@process_code					nvarchar(50)
			,@maintenance_type				nvarchar(50)
			,@plat_no						nvarchar(50)
			,@invoice_no					nvarchar(50)	
			,@faktur_no						NVARCHAR(50)
			,@vendor_npwp					nvarchar(20)
			,@income_type					nvarchar(250)
			,@income_bruto_amount			decimal(18,2)
			,@tax_rate						decimal(5,2)
			,@ppn_pph_amount				decimal(18,2)
			,@transaction_code				nvarchar(50)
			,@ppn_pct						decimal(9,6)
			,@pph_pct						decimal(9,6)
			,@vendor_type					nvarchar(25)
			,@pph_type						nvarchar(20)
			,@total_amount					decimal(18,2)
			,@remarks_tax					nvarchar(4000)
			,@spk_no						NVARCHAR(50)
			,@bank_name						nvarchar(250)
			,@bank_account_no				nvarchar(50)
			,@bank_account_name				nvarchar(250)
			,@maintenance_by				nvarchar(50)
			,@branch_code_asset				nvarchar(50)
			,@branch_name_asset				nvarchar(250)
			,@agreement_external_no			nvarchar(50)
			,@faktur_no_invoice				nvarchar(50) -- (+) Ari 2023-12-18
			,@faktur_date					datetime
			,@faktur_date_source			datetime

	BEGIN TRY

		SELECT	@status						= wo.status
				,@company_code				= wo.company_code
				,@maintenance_code			= wo.maintenance_code
				,@asset_code				= wo.asset_code
				,@branch_code				= mnt.branch_code
				,@branch_name				= mnt.branch_name
				,@vendor_code				= mnt.vendor_code
				,@vendor_name				= mnt.vendor_name
				,@requestor_name			= ass.requestor_name
				,@adress					= mnt.vendor_address
				,@phone_no					= mnt.vendor_phone
				,@date						= mnt.transaction_date
				,@item_name					= ass.item_name
				,@hour_meter				= mnt.hour_meter
				,@actual_km					= mnt.actual_km
				,@service_type				= mnt.service_type
				,@work_date					= mnt.work_date
				,@vendor_bank_name			= mnt.vendor_bank_name
				,@vendor_bank_account_no	= mnt.vendor_bank_account_no
				,@vendor_bank_account_name  = mnt.vendor_bank_account_name
				,@vendor_npwp				= mnt.vendor_npwp
				,@is_reimburse				= mnt.is_reimburse
				,@payment_amount			= wo.payment_amount
				,@ppn_amount				= wo.total_ppn_amount
				,@pph_amount				= wo.total_pph_amount
				,@agreement_no				= ass.agreement_no
				,@asset_no					= ass.asset_no
				,@client_no					= ass.client_no
				,@client_name				= ass.client_name
				,@remark					= wo.remark
				,@maintenance_type			= mnt.service_type
				,@plat_no					= avh.plat_no
				,@invoice_no				= wo.invoice_no
				,@vendor_type				= mnt.vendor_type
				,@spk_no					= mnt.spk_no
				,@bank_name					= mnt.bank_name
				,@bank_account_no			= mnt.bank_account_no
				,@bank_account_name			= mnt.bank_account_name
				,@maintenance_by			= wo.maintenance_by
				,@branch_code_asset			= ass.branch_code
				,@branch_name_asset			= ass.branch_name
				,@agreement_external_no		= ISNULL(ass.agreement_external_no,'')
				,@faktur_date_source		= wo.faktur_date	
		from	dbo.work_order wo
		left join dbo.maintenance mnt on (mnt.code = wo.maintenance_code)
		left join ifinbam.dbo.master_vendor mv on (mnt.vendor_code = mv.code)
		left join dbo.asset ass on (ass.code = mnt.asset_code)
		left join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
		where	wo.code = @p_code ;

		select @faktur_no = faktur_no
				,@faktur_no_invoice = invoice_no -- (+) Ari 2023-12-18 ket : get invoice
		from dbo.work_order
		where code = @p_code

		if (ISNULL(@faktur_no,'') = '') AND (@pph_amount > 0)
		begin
			set @msg = 'Faktur Number cant be empty.';
			RAISERROR(@msg ,16,-1);
		END

		if exists (select 1 from dbo.work_order_detail where work_order_code = @p_code and isnull(service_code, '') = '')
		begin
			set @msg = 'Please add item service in work order detail.';
			RAISERROR(@msg ,16,-1);
		END
        
		IF (@status = 'ON PROCESS')
		BEGIN
				if(@service_type = 'ROUTINE')
				begin
					-- Cursor untuk update schedule maintenance di asset yang tidak dilakukan maintenance yang kurang dari work date
					if exists(select 1 from dbo.asset_maintenance_schedule 
								where asset_code = @asset_code 
								and (maintenance_date < @work_date or miles < @actual_km or hour < @hour_meter)
								and maintenance_status = 'SCHEDULE PENDING'
								and reff_trx_no = ''
								and id not in (select asset_maintenance_schedule_id 
													from dbo.maintenance_detail 
													where maintenance_code = @maintenance_code))
					begin
						declare curr_asset_non_main cursor fast_forward read_only for

						select id 
						from dbo.asset_maintenance_schedule
						where asset_code = @asset_code
						and (maintenance_date < @work_date or miles < @actual_km or hour < @hour_meter)
						and maintenance_status = 'SCHEDULE PENDING'
						and reff_trx_no = ''
						and id not in (select asset_maintenance_schedule_id 
						from dbo.maintenance_detail 
						where maintenance_code = @maintenance_code)
						
						open curr_asset_non_main
						
						fetch next from curr_asset_non_main 
						into @id_asset_maintenance_schedule
						
						while @@fetch_status = 0
						begin
						    update	dbo.asset_maintenance_schedule
							set		maintenance_status	= 'SERVICE SKIPED'
									,last_status_date	= @p_mod_date
									,reff_trx_no		= '-'
									--
									,mod_date			= @p_mod_date
									,mod_by				= @p_mod_by
									,mod_ip_address		= @p_mod_ip_address
							where	asset_code			= @asset_code
							and id = @id_asset_maintenance_schedule
						
						    FETCH NEXT FROM curr_asset_non_main 
							INTO @id_asset_maintenance_schedule
						END
						
						close curr_asset_non_main
						DEALLOCATE curr_asset_non_main
					END
				
					-- Cursor untuk update schedule maintenance di asset yang dilakukan maintenance
					declare curr_asset_main cursor fast_forward read_only for

					select asset_maintenance_schedule_id 
					from dbo.maintenance_detail
					where maintenance_code = @maintenance_code
					
					open curr_asset_main
					
					fetch next from curr_asset_main 
					into @trx_no
					
					while @@fetch_status = 0
					begin
					    update	dbo.asset_maintenance_schedule
						set		maintenance_status	= 'SCHEDULE DONE'
								,last_status_date	= @p_mod_date
								,reff_trx_no		= @maintenance_code
								,service_date		= @work_date
								--
								,mod_date			= @p_mod_date
								,mod_by				= @p_mod_by
								,mod_ip_address		= @p_mod_ip_address
						where	asset_code			= @asset_code
						and id = @trx_no
					
					    FETCH NEXT FROM curr_asset_main 
						INTO @trx_no
					END
					
					close curr_asset_main
					deallocate curr_asset_main

					-- Cursor untuk insert schedule baru diluar schedule asli dengan service type routin
					if exists(select 1 from dbo.work_order_detail where work_order_code =  @p_code and asset_maintenance_schedule_id = 0)
					begin
						declare curr_main_not_schedule cursor fast_forward read_only for
						select	service_code
								,service_name 
						from dbo.work_order_detail
						where work_order_code = @p_code
						and asset_maintenance_schedule_id = 0
						
						open curr_main_not_schedule
						
						fetch next from curr_main_not_schedule 
						into @service_code
							,@service_name
						
						while @@fetch_status = 0
						begin
						    exec dbo.xsp_asset_maintenance_schedule_insert @p_id						= 0
																			,@p_asset_code				= @asset_code
																			,@p_maintenance_no			= ''
																			,@p_maintenance_date		= @p_mod_date
																			,@p_maintenance_status		= 'AD HOC DONE'
																			,@p_last_status_date		= @p_mod_date
																			,@p_reff_trx_no				= @maintenance_code
																			,@p_miles					= @actual_km
																			,@p_month					= 0
																			,@p_hour					= 0
																			,@p_service_code			= @service_code
																			,@p_service_name			= @service_name
																			,@p_service_type			= @service_type
																			,@p_service_date			= @work_date
																			,@p_cre_by					= @p_mod_by
																			,@p_cre_date				= @p_mod_date
																			,@p_cre_ip_address			= @p_mod_ip_address
																			,@p_mod_by					= @p_mod_by
																			,@p_mod_date				= @p_mod_date
																			,@p_mod_ip_address			= @p_mod_ip_address
						
						    FETCH NEXT FROM curr_main_not_schedule 
							INTO @service_code
								,@service_name
						END
						
						close curr_main_not_schedule
						DEALLOCATE curr_main_not_schedule
					END

					--cek apakah di asset withmaintenance routin nya 1 apa 0
					select @is_maintenance = is_maintenance 
					from dbo.asset
					where code = @asset_code

					--jika 0 maka update jadi 1 untuk menampilkan jadwal maintenance yang diinput manual di menu maintenance
					IF(@is_maintenance = '0')
					BEGIN
						UPDATE	dbo.asset
						SET		is_maintenance		= '1'
								--
								,mod_date			= @p_mod_date
								,mod_by				= @p_mod_by
								,mod_ip_address		= @p_mod_ip_address
						WHERE	code				= @asset_code
					END
				END
				ELSE
				BEGIN
					--cek apakah di asset withmaintenance routin nya 1 apa 0
					select @is_maintenance = is_maintenance 
					from dbo.asset
					where code = @asset_code

					--jika 0 maka update jadi 1 untuk menampilkan jadwal maintenance yang diinput manual di menu maintenance
					if(@is_maintenance = '0')
					begin
						update	dbo.asset
						set		is_maintenance		= '1'
								--
								,mod_date			= @p_mod_date
								,mod_by				= @p_mod_by
								,mod_ip_address		= @p_mod_ip_address
						where	code				= @asset_code
					end

					declare curr_non_routin cursor fast_forward read_only for
					select	mnt.asset_code
							,mnt.actual_km
							,mnt.hour_meter
							,mnd.service_code
							,mnd.service_name
							,mnd.service_type 
					from dbo.maintenance_detail mnd
					inner join dbo.maintenance mnt on (mnt.code = mnd.maintenance_code)
					where mnt.code = @maintenance_code
					
					open curr_non_routin
					
					fetch next from curr_non_routin 
					into @asset_code
						,@actual_km
						,@hour_meter
						,@service_code
						,@service_name
						,@service_type
					
					while @@fetch_status = 0
					begin
					    exec dbo.xsp_asset_maintenance_schedule_insert @p_id						= 0
																		,@p_asset_code				= @asset_code
																		,@p_maintenance_no			= ''
																		,@p_maintenance_date		= @p_mod_date
																		,@p_maintenance_status		= 'AD HOC DONE'
																		,@p_last_status_date		= @p_mod_date
																		,@p_reff_trx_no				= @maintenance_code
																		,@p_miles					= @actual_km
																		,@p_month					= 0
																		,@p_hour					= @hour_meter
																		,@p_service_code			= @service_code
																		,@p_service_name			= @service_name
																		,@p_service_type			= @service_type
																		,@p_service_date			= @work_date
																		,@p_cre_by					= @p_mod_by
																		,@p_cre_date				= @p_mod_date
																		,@p_cre_ip_address			= @p_mod_ip_address
																		,@p_mod_by					= @p_mod_by
																		,@p_mod_date				= @p_mod_date
																		,@p_mod_ip_address			= @p_mod_ip_address
					
					    FETCH NEXT FROM curr_non_routin 
						INTO @asset_code
							,@actual_km
							,@hour_meter
							,@service_code
							,@service_name
							,@service_type
					END
					
					close curr_non_routin
					DEALLOCATE curr_non_routin
				END
					
			BEGIN
				--exec dbo.xsp_efam_interface_payment_request_insert @p_id						= 0
			--												   ,@p_code						= @code_interface output
			--												   ,@p_company_code				= 'DSF'
			--												   ,@p_branch_code				= @branch_code
			--												   ,@p_branch_name				= @branch_name
			--												   ,@p_payment_branch_code		= @branch_code
			--												   ,@p_payment_branch_name		= @branch_name
			--												   ,@p_payment_source			= 'PAYMENT SERVICE FEE ASET'
			--												   ,@p_payment_request_date		= @p_mod_date
			--												   ,@p_payment_source_no		= @maintenance_code
			--												   ,@p_payment_status			= 'HOLD'
			--												   ,@p_payment_currency_code	= 'IDR'
			--												   ,@p_payment_amount			= @payment_amount
			--												   ,@p_payment_remarks			= @remarks
			--												   ,@p_to_bank_account_name		= ''
			--												   ,@p_to_bank_name				= ''
			--												   ,@p_to_bank_account_no		= ''
			--												   ,@p_tax_type					= null
			--												   ,@p_tax_file_no				= null
			--												   ,@p_tax_payer_reff_code		= null
			--												   ,@p_tax_file_name			= null
			--												   ,@p_process_date				= null
			--												   ,@p_process_reff_no			= null
			--												   ,@p_process_reff_name		= null
			--												   ,@p_settle_date				= null
			--												   ,@p_job_status				= 'HOLD'
			--												   ,@p_failed_remarks			= ''
			--												   ,@p_cre_date					= @p_mod_date	  
			--												   ,@p_cre_by					= @p_mod_by		  
			--												   ,@p_cre_ip_address			= @p_mod_ip_address
			--												   ,@p_mod_date					= @p_mod_date	  
			--												   ,@p_mod_by					= @p_mod_by		  
			--												   ,@p_mod_ip_address			= @p_mod_ip_address

			
			--declare curr_wo_service cursor fast_forward read_only for
			--select  mt.sp_name
			--		,mtp.debet_or_credit
			--		,mtp.gl_link_code
			--		,mt.transaction_name
			--from	dbo.master_transaction_parameter mtp 
			--		left join dbo.sys_general_subcode sgs on (sgs.code = mtp.process_code)
			--		left join dbo.master_transaction mt on (mt.code = mtp.transaction_code)
			--where	mtp.process_code = 'WOPYT'
			
			--open curr_wo_service
			
			--fetch next from curr_wo_service 
			--into @sp_name
			--	 ,@debet_or_credit
			--	 ,@gl_link_code
			--	 ,@transaction_name
			
			--while @@fetch_status = 0
			--begin
			--    -- nilainya exec dari MASTER_TRANSACTION.sp_name
			--	exec @return_value = @sp_name @maintenance_code ; -- sp ini mereturn value angka 
					
			--	if (@debet_or_credit ='DEBIT')
			--		begin
			--			set @orig_amount_db = @return_value
			--		end
			--	else
			--	begin
			--			set @orig_amount_db = @return_value * -1
			--	end
			--	set @remarks = 'PAYMENT SERVICE FEE FOR ' + @asset_code
				
			--	exec dbo.xsp_efam_interface_payment_request_detail_insert @p_id							= 0
			--															  ,@p_payment_request_code		= @code_interface
			--															  ,@p_company_code				= 'DSF'
			--															  ,@p_branch_code				= @branch_code
			--															  ,@p_branch_name				= @branch_name
			--															  ,@p_gl_link_code				= @gl_link_code
			--															  ,@p_fa_code					= @asset_code
			--															  ,@p_facility_code				= null
			--															  ,@p_facility_name				= null
			--															  ,@p_purpose_loan_code			= null
			--															  ,@p_purpose_loan_name			= null
			--															  ,@p_purpose_loan_detail_code	= null
			--															  ,@p_purpose_loan_detail_name	= null
			--															  ,@p_orig_currency_code		= 'IDR'
			--															  ,@p_orig_amount				= @orig_amount_db
			--															  ,@p_division_code				= ''
			--															  ,@p_division_name				= ''
			--															  ,@p_department_code			= ''
			--															  ,@p_department_name			= ''
			--															  ,@p_is_taxable				= '0'
			--															  ,@p_remarks					= @remarks
			--															  ,@p_cre_date					= @p_mod_date	  
			--															  ,@p_cre_by					= @p_mod_by		  
			--															  ,@p_cre_ip_address			= @p_mod_ip_address
			--															  ,@p_mod_date					= @p_mod_date	  
			--															  ,@p_mod_by					= @p_mod_by		  
			--															  ,@p_mod_ip_address			= @p_mod_ip_address
				
			--    fetch next from curr_wo_service 
			--	into @sp_name
			--		,@debet_or_credit
			--		,@gl_link_code
			--		,@transaction_name
			--end
			
			--close curr_wo_service
			--deallocate curr_wo_service
			
			--select @amount  = sum(iipr.payment_amount)
			--from   dbo.efam_interface_payment_request iipr
			--where code = @code_interface

			--select @orig_amount_db = sum(orig_amount) 
			--from  dbo.efam_interface_payment_request_detail
			--where payment_request_code = @code_interface

			----set @amount = @amount + @orig_amount_db
			----+ validasi : total detail =  payment_amount yang di header
			--if (@amount <> @orig_amount_db)
			--begin
			--	set @msg = 'Payment Amount does not balance';
			-- 	raiserror(@msg, 16, -1) ;
			--end			
			
				--insert ke payment request

				set @payment_remark = 'Payment Work Order for : ' + @p_code + ' - ' + isnull(@plat_no,'') + ' - ' + 'Invoice : ' + isnull(@invoice_no,'') + ' - ' + ISNULL(@remark,'') + ' - SPK No. :' +  ISNULL(@spk_no,'')

				IF(@maintenance_by = 'EXT')
				BEGIN
					select	@branch_code		= value
							,@branch_name	= description
					from dbo.sys_global_param
					where code = 'HO'

					exec dbo.xsp_payment_request_insert @p_code							= @code_payment_request output
														,@p_branch_code					= @branch_code
														,@p_branch_name					= @branch_name
														,@p_payment_branch_code			= @branch_code
														,@p_payment_branch_name			= @branch_name
														,@p_payment_source				= 'WORK ORDER'
														,@p_payment_request_date		= @p_mod_date--@work_date
														,@p_payment_source_no			= @p_code
														,@p_payment_status				= 'HOLD'
														,@p_payment_currency_code		= 'IDR'
														,@p_payment_amount				= @payment_amount
														,@p_payment_to					= @vendor_name
														,@p_payment_remarks				= @payment_remark
														,@p_to_bank_name				= @vendor_bank_name
														,@p_to_bank_account_name		= @vendor_bank_account_name
														,@p_to_bank_account_no			= @vendor_bank_account_no
														,@p_payment_transaction_code	= ''
														,@p_tax_type					= ''
														,@p_tax_file_no					= ''
														,@p_tax_payer_reff_code			= ''
														,@p_tax_file_name				= ''
														,@p_cre_date					= @p_mod_date	  
														,@p_cre_by						= @p_mod_by		
														,@p_cre_ip_address				= @p_mod_ip_address
														,@p_mod_date					= @p_mod_date	  
														,@p_mod_by						= @p_mod_by		
														,@p_mod_ip_address				= @p_mod_ip_address


					declare curr_payment cursor fast_forward read_only for 
					select  mt.sp_name
							,mtp.debet_or_credit
							,mtp.gl_link_code
							,mtp.transaction_code
							,mt.transaction_name
							,wod.id
							,wod.service_name
							,wod.service_type
							,wod.quantity
							,wod.ppn_pct
							,wod.pph_pct
							,wod.total_amount
							,isnull(mnt.vendor_code,mv.code)
							,isnull(mnt.vendor_name, mv.npwp_name)
							,isnull(mnt.vendor_address, mv.npwp_address)
							,ISNULL(mnt.vendor_npwp, mv.npwp)
					from	dbo.master_transaction_parameter mtp 
							left join dbo.sys_general_subcode sgs on (sgs.code = mtp.process_code)
							left join dbo.master_transaction mt on (mt.code = mtp.transaction_code)
							inner join dbo.work_order_detail wod on (wod.work_order_code = @p_code)
							inner join dbo.work_order wo on (wo.code = wod.work_order_code)
							inner join dbo.maintenance mnt on (mnt.code = wo.maintenance_code)
							left join ifinbam.dbo.master_vendor mv on (mv.code = mnt.vendor_code)
					where	mtp.process_code = 'WOPC' ;
		

					open curr_payment
					
					fetch next from curr_payment 
					into @sp_name
						,@debet_or_credit
						,@gl_link_code
						,@transaction_code
						,@transaction_name
						,@wod_id
						,@service_name
						,@service_type
						,@quantity
						,@ppn_pct
						,@pph_pct
						,@total_amount
						,@vendor_code
						,@vendor_name
						,@adress
						,@vendor_npwp
				
					WHILE @@fetch_status = 0
					BEGIN
					    -- nilainya exec dari MASTER_TRANSACTION.sp_name
						exec @return_value = @sp_name @wod_id ; -- sp ini mereturn value angka 
						
						if (@debet_or_credit ='DEBIT')
							begin
								set @orig_amount_db = @return_value
							end
						ELSE
						BEGIN
								SET @orig_amount_db = @return_value * -1
						END

						set @remarks = isnull(@transaction_name,'') +' : '+ @p_code  + ', ' + convert(nvarchar(3), @quantity) + ' ' + isnull(@service_type,'') + ' ' + isnull(@service_name,'')
						set @remarks_tax = @remarks

						--(+) Ari 2023-12-18 ket : req pak hary jika faktur kosong, pakai invoice
						if(@transaction_code in ('MNTPPN','MNTPPH','MNTPPHP','SRVPPHP','SRVPPH'))
						begin
							if (@faktur_no = '0000000000000000') -- hari 12 jan 2024 -- jika faktur default maka ambil invoice no
							begin
									if len(@faktur_no_invoice) = 16
									begin
										set @faktur_no = @faktur_no_invoice + '-A2'
									end
									else
                                    begin
										set @faktur_no = @faktur_no_invoice
									end
							end 

							--set @faktur_no = isnull(@faktur_no,@faktur_no_invoice)
						end

						-- (+) Ari 2023-12-30 ket : get npwp name & npwp address (bukan name dan address,logic diatas dibiarin aja)
						select	@vendor_name = mv.npwp_name
								,@adress = mv.npwp_address
						from	ifinbam.dbo.master_vendor mv
						where	mv.code = @vendor_code


						if(@transaction_code = 'MNTPPN')
						begin
							if(@return_value > 0)
							begin
								set @pph_type = 'PPN MASUKAN'
								set @income_type = 'PPN MASUKAN ' + convert(nvarchar(10), cast(@ppn_pct as int)) + '%'
								set @income_bruto_amount = @total_amount
								set @tax_rate = @ppn_pct
								SET @ppn_pph_amount = @return_value
							END
						END
						ELSE IF(@transaction_code = 'MNTPPH') OR (@transaction_code = 'SRVPPH')
						begin
							if(@return_value > 0)
							begin
								set @pph_type = 'PPH PASAL 23'
								set @income_type = 'Jasa Perawatan Kendaraan'
								set @income_bruto_amount = @total_amount
								set @tax_rate = @pph_pct
								SET @ppn_pph_amount = @return_value
								set	@faktur_date = @faktur_date_source
							END
						END
						ELSE IF(@transaction_code = 'MNTPPHP') OR (@transaction_code = 'SRVPPHP')
						begin
							if(@return_value > 0)
							begin
								set @pph_type = 'PPH PASAL 21'
								set @income_type = 'Jasa Teknik'
								set @income_bruto_amount = @total_amount
								set @tax_rate = @pph_pct
								set @ppn_pph_amount = @return_value
								set @vendor_code = @vendor_code
								set @vendor_name = @vendor_name
								set @vendor_npwp = @vendor_npwp
								SET @adress = @adress
								set	@faktur_date = @faktur_date_source
							END
						END
						ELSE
						BEGIN
							set @income_type = ''
							set @pph_type = ''
							set @vendor_code = ''
							set @vendor_name = ''
							set @vendor_npwp = ''
							set @adress = ''
							set @income_bruto_amount = 0
							set @tax_rate = 0
							set @ppn_pph_amount = 0
							set @remarks_tax = ''
							SET @faktur_no = ''
							SET	@faktur_date = null
						END

						if @return_value <> 0
						begin
							exec dbo.xsp_payment_request_detail_insert @p_id						= 0
																   ,@p_payment_request_code			= @code_payment_request
																   ,@p_branch_code					= @branch_code_asset
																   ,@p_branch_name					= @branch_name_asset
																   ,@p_gl_link_code					= @gl_link_code
																   ,@p_agreement_no					= @agreement_external_no
																   ,@p_facility_code				= ''
																   ,@p_facility_name				= ''
																   ,@p_purpose_loan_code			= ''
																   ,@p_purpose_loan_name			= ''
																   ,@p_purpose_loan_detail_code		= ''
																   ,@p_purpose_loan_detail_name		= ''
																   ,@p_orig_currency_code			= 'IDR'
																   ,@p_exch_rate					= 0
																   ,@p_orig_amount					= @orig_amount_db
																   ,@p_division_code				= ''
																   ,@p_division_name				= ''
																   ,@p_department_code				= ''
																   ,@p_department_name				= ''
																   ,@p_remarks						= @remarks
																   ,@p_is_taxable					= '0'
																   ,@p_tax_amount					= 0
																   ,@p_tax_pct						= 0
																   ,@p_ext_pph_type					= @pph_type
																   ,@p_ext_vendor_code				= @vendor_code
																   ,@p_ext_vendor_name				= @vendor_name
																   ,@p_ext_vendor_npwp				= @vendor_npwp
																   ,@p_ext_vendor_address			= @adress
																   ,@p_ext_income_type				= @income_type
																   ,@p_ext_income_bruto_amount		= @income_bruto_amount
																   ,@p_ext_tax_rate_pct				= @tax_rate
																   ,@p_ext_pph_amount				= @ppn_pph_amount
																   ,@p_ext_description				= @remarks_tax
																   ,@p_ext_tax_number				= @faktur_no
																   ,@p_ext_tax_date					= @faktur_date
																   ,@p_ext_sale_type				= ''
																   ,@p_cre_date						= @p_mod_date	  
																   ,@p_cre_by						= @p_mod_by		
																   ,@p_cre_ip_address				= @p_mod_ip_address
																   ,@p_mod_date						= @p_mod_date	  
																   ,@p_mod_by						= @p_mod_by		
																   ,@p_mod_ip_address				= @p_mod_ip_address
						end
					    
					
					    FETCH NEXT FROM curr_payment 
						INTO @sp_name
							,@debet_or_credit
							,@gl_link_code
							,@transaction_code
							,@transaction_name
							,@wod_id
							,@service_name
							,@service_type
							,@quantity
							,@ppn_pct
							,@pph_pct
							,@total_amount
							,@vendor_code
							,@vendor_name
							,@adress
							,@vendor_npwp
					END
					
					CLOSE curr_payment
					DEALLOCATE curr_payment

								
					SELECT @amount  = SUM(ISNULL(iipr.payment_amount,0))
					FROM   dbo.payment_request iipr
					WHERE code = @code_payment_request

					SELECT @orig_amount_db = SUM(ISNULL(orig_amount,0)) 
					FROM  dbo.payment_request_detail
					WHERE payment_request_code = @code_payment_request

					--set @amount = @amount + @orig_amount_db
					--+ validasi : total detail =  payment_amount yang di header

					IF (@amount <> @orig_amount_db)
					BEGIN
						SET @msg = 'Payment Amount does not balance';
			 			RAISERROR(@msg, 16, -1) ;
					END			
				END
				ELSE IF (@maintenance_by = 'CST')
				BEGIN
					SELECT	@branch_code		= value
							,@branch_name	= description
					FROM dbo.sys_global_param
					WHERE code = 'HO'

					EXEC dbo.xsp_payment_request_insert @p_code							= @code_payment_request OUTPUT
														,@p_branch_code					= @branch_code
														,@p_branch_name					= @branch_name
														,@p_payment_branch_code			= @branch_code
														,@p_payment_branch_name			= @branch_name
														,@p_payment_source				= 'WORK ORDER'
														,@p_payment_request_date		= @p_mod_date--@work_date
														,@p_payment_source_no			= @p_code
														,@p_payment_status				= 'HOLD'
														,@p_payment_currency_code		= 'IDR'
														,@p_payment_amount				= @payment_amount
														,@p_payment_to					= @vendor_name
														,@p_payment_remarks				= @payment_remark
														,@p_to_bank_name				= @bank_name
														,@p_to_bank_account_name		= @bank_account_name
														,@p_to_bank_account_no			= @bank_account_no
														,@p_payment_transaction_code	= ''
														,@p_tax_type					= ''
														,@p_tax_file_no					= ''
														,@p_tax_payer_reff_code			= ''
														,@p_tax_file_name				= ''
														,@p_cre_date					= @p_mod_date	  
														,@p_cre_by						= @p_mod_by		
														,@p_cre_ip_address				= @p_mod_ip_address
														,@p_mod_date					= @p_mod_date	  
														,@p_mod_by						= @p_mod_by		
														,@p_mod_ip_address				= @p_mod_ip_address

					declare curr_payment cursor fast_forward read_only for 
					select  mt.sp_name
							,mtp.debet_or_credit
							,mtp.gl_link_code
							,mtp.transaction_code
							,mt.transaction_name
							,wod.id
							,wod.service_name
							,wod.service_type
							,wod.quantity
							,wod.ppn_pct
							,wod.pph_pct
							,wod.total_amount
							,mnt.vendor_code
							,mnt.vendor_name
							,mnt.vendor_address
							,mnt.vendor_npwp
					from	dbo.master_transaction_parameter mtp 
							left join dbo.sys_general_subcode sgs on (sgs.code = mtp.process_code)
							left join dbo.master_transaction mt on (mt.code = mtp.transaction_code)
							inner join dbo.work_order_detail wod on (wod.work_order_code = @p_code)
							inner join dbo.work_order wo on (wo.code = wod.work_order_code)
							inner join dbo.maintenance mnt on (mnt.code = wo.maintenance_code)
					where	mtp.process_code = 'WOPC' ;
		

					open curr_payment
					
					fetch next from curr_payment 
					into @sp_name
						,@debet_or_credit
						,@gl_link_code
						,@transaction_code
						,@transaction_name
						,@wod_id
						,@service_name
						,@service_type
						,@quantity
						,@ppn_pct
						,@pph_pct
						,@total_amount
						,@vendor_code
						,@vendor_name
						,@adress
						,@vendor_npwp
				
					while @@fetch_status = 0
					begin
					    -- nilainya exec dari MASTER_TRANSACTION.sp_name
						exec @return_value = @sp_name @wod_id ; -- sp ini mereturn value angka 
						
						if (@debet_or_credit ='DEBIT')
							begin
								set @orig_amount_db = @return_value
							end
						else
						begin
								set @orig_amount_db = @return_value * -1
						end

						set @remarks = isnull(@transaction_name,'') +' : '+ @p_code + ', ' + convert(nvarchar(3), @quantity) + ' ' + isnull(@service_type,'') + ' ' + isnull(@service_name,'')
						set @remarks_tax = @remarks


						-- (+) Ari 2023-12-30 ket : get npwp name & npwp address (bukan name dan address,logic diatas dibiarin aja)
						select	@vendor_name = mv.npwp_name
								,@adress = mv.npwp_address
						from	ifinbam.dbo.master_vendor mv
						where	mv.code = @vendor_code

						if(@transaction_code = 'MNTPPN')
						begin
							if(@return_value > 0)
							begin
								set @pph_type = 'PPN MASUKAN'
								set @income_type = 'PPN MASUKAN ' + convert(nvarchar(10), cast(@ppn_pct as int)) + '%'
								set @income_bruto_amount = @total_amount
								set @tax_rate = @ppn_pct
								set @ppn_pph_amount = @return_value
							end
						end
						else if(@transaction_code = 'MNTPPH') OR (@transaction_code = 'SRVPPH')
						begin
							if(@return_value > 0)
							begin
								set @pph_type = 'PPH PASAL 23'
								set @income_type = 'Jasa Perawatan Kendaraan'
								set @income_bruto_amount = @total_amount
								set @tax_rate = @pph_pct
								set @ppn_pph_amount = @return_value
							end
						end
						else if(@transaction_code = 'MNTPPHP') OR (@transaction_code = 'SRVPPHP')
						begin
							if(@return_value > 0)
							begin
								set @pph_type = 'PPH PASAL 21'
								set @income_type = 'Jasa Tehnik'
								set @income_bruto_amount = @total_amount
								set @tax_rate = @pph_pct
								set @ppn_pph_amount = @return_value
								set @vendor_code = @vendor_code
								set @vendor_name = @vendor_name
								set @vendor_npwp = @vendor_npwp
								set @adress = @adress
							end
						end
						else
						begin
							set @income_type = ''
							set @pph_type = ''
							set @vendor_code = ''
							set @vendor_name = ''
							set @vendor_npwp = ''
							set @adress = ''
							set @income_bruto_amount = 0
							set @tax_rate = 0
							set @ppn_pph_amount = 0
							set @remarks_tax = ''
							set @faktur_no = ''
							SET @faktur_date = null
						end
												

						if @return_value <> 0
						BEGIN
                        
						IF (isnull(@pph_type,'')<>'' and isnull(@faktur_no,'')='')
						begin
							set @msg = 'Data Faktur Number for Tax is Incomplete'
							raiserror (@msg, 16, -1)
						end 

							exec dbo.xsp_payment_request_detail_insert @p_id						= 0
																   ,@p_payment_request_code			= @code_payment_request
																   ,@p_branch_code					= @branch_code_asset
																   ,@p_branch_name					= @branch_name_asset
																   ,@p_gl_link_code					= @gl_link_code
																   ,@p_agreement_no					= @agreement_external_no
																   ,@p_facility_code				= ''
																   ,@p_facility_name				= ''
																   ,@p_purpose_loan_code			= ''
																   ,@p_purpose_loan_name			= ''
																   ,@p_purpose_loan_detail_code		= ''
																   ,@p_purpose_loan_detail_name		= ''
																   ,@p_orig_currency_code			= 'IDR'
																   ,@p_exch_rate					= 0
																   ,@p_orig_amount					= @orig_amount_db
																   ,@p_division_code				= ''
																   ,@p_division_name				= ''
																   ,@p_department_code				= ''
																   ,@p_department_name				= ''
																   ,@p_remarks						= @remarks
																   ,@p_is_taxable					= '0'
																   ,@p_tax_amount					= 0
																   ,@p_tax_pct						= 0
																   ,@p_ext_pph_type					= @pph_type
																   ,@p_ext_vendor_code				= @vendor_code
																   ,@p_ext_vendor_name				= @vendor_name
																   ,@p_ext_vendor_npwp				= @vendor_npwp
																   ,@p_ext_vendor_address			= @adress
																   ,@p_ext_income_type				= @income_type
																   ,@p_ext_income_bruto_amount		= @income_bruto_amount
																   ,@p_ext_tax_rate_pct				= @tax_rate
																   ,@p_ext_pph_amount				= @ppn_pph_amount
																   ,@p_ext_description				= @remarks_tax
																   ,@p_ext_tax_number				= @faktur_no
																   ,@p_ext_tax_date					= @faktur_date
																   ,@p_ext_sale_type				= ''
																   ,@p_cre_date						= @p_mod_date	  
																   ,@p_cre_by						= @p_mod_by		
																   ,@p_cre_ip_address				= @p_mod_ip_address
																   ,@p_mod_date						= @p_mod_date	  
																   ,@p_mod_by						= @p_mod_by		
																   ,@p_mod_ip_address				= @p_mod_ip_address
						end
					    
					
					    fetch next from curr_payment 
						into @sp_name
							,@debet_or_credit
							,@gl_link_code
							,@transaction_code
							,@transaction_name
							,@wod_id
							,@service_name
							,@service_type
							,@quantity
							,@ppn_pct
							,@pph_pct
							,@total_amount
							,@vendor_code
							,@vendor_name
							,@adress
							,@vendor_npwp
					end
					
					close curr_payment
					deallocate curr_payment

								
					select @amount  = sum(isnull(iipr.payment_amount,0))
					from   dbo.payment_request iipr
					where code = @code_payment_request

					select @orig_amount_db = sum(isnull(orig_amount,0)) 
					from  dbo.payment_request_detail
					where payment_request_code = @code_payment_request

					--set @amount = @amount + @orig_amount_db
					--+ validasi : total detail =  payment_amount yang di header

					if (@amount <> @orig_amount_db)
					begin
						set @msg = 'Payment Amount does not balance';
			 			raiserror(@msg, 16, -1) ;
					end			
				end
				else
				begin
					if @is_reimburse = '0'
					begin
						--insert ke expense ledger
						set @reff_remark = 'Maintenance for ' + @asset_code + ' - ' + @item_name
						exec dbo.xsp_asset_expense_ledger_insert @p_id					= 0
																 ,@p_asset_code			= @asset_code
																 ,@p_date				= @date
																 ,@p_reff_code			= @maintenance_code
																 ,@p_reff_name			= 'WORK ORDER'
																 ,@p_reff_remark		= @reff_remark
																 ,@p_expense_amount		= @payment_amount
																 ,@p_agreement_no		= @agreement_no
																 ,@p_client_name		= @client_name
																 ,@p_cre_date			= @p_mod_date	  
																 ,@p_cre_by				= @p_mod_by		
																 ,@p_cre_ip_address		= @p_mod_ip_address
																 ,@p_mod_date			= @p_mod_date	  
																 ,@p_mod_by				= @p_mod_by		
																 ,@p_mod_ip_address		= @p_mod_ip_address
					end
				end


				--declare curr_payment cursor fast_forward read_only for 
				--select  mt.sp_name
				--		,mtp.debet_or_credit
				--		,mtp.gl_link_code
				--		,mtp.transaction_code
				--		,mt.transaction_name
				--		,wod.id
				--		,wod.service_name
				--		,wod.service_type
				--		,wod.quantity
				--		,wod.ppn_pct
				--		,wod.pph_pct
				--		,wod.total_amount
				--		,mnt.vendor_code
				--		,mnt.vendor_name
				--		,mnt.vendor_address
				--		,mnt.vendor_npwp
				--from	dbo.master_transaction_parameter mtp 
				--		left join dbo.sys_general_subcode sgs on (sgs.code = mtp.process_code)
				--		left join dbo.master_transaction mt on (mt.code = mtp.transaction_code)
				--		inner join dbo.work_order_detail wod on (wod.work_order_code = @p_code)
				--		inner join dbo.work_order wo on (wo.code = wod.work_order_code)
				--		inner join dbo.maintenance mnt on (mnt.code = wo.maintenance_code)
				--where	mtp.process_code = 'WOPC' ;
		

				--open curr_payment
				
				--fetch next from curr_payment 
				--into @sp_name
				--	,@debet_or_credit
				--	,@gl_link_code
				--	,@transaction_code
				--	,@transaction_name
				--	,@wod_id
				--	,@service_name
				--	,@service_type
				--	,@quantity
				--	,@ppn_pct
				--	,@pph_pct
				--	,@total_amount
				--	,@vendor_code
				--	,@vendor_name
				--	,@adress
				--	,@vendor_npwp
				
				--while @@fetch_status = 0
				--begin
				--    -- nilainya exec dari MASTER_TRANSACTION.sp_name
				--	exec @return_value = @sp_name @wod_id ; -- sp ini mereturn value angka 
					
				--	if (@debet_or_credit ='DEBIT')
				--		begin
				--			set @orig_amount_db = @return_value
				--		end
				--	else
				--	begin
				--			set @orig_amount_db = @return_value * -1
				--	end

				--	set @remarks = isnull(@transaction_name,'') + ', ' + convert(nvarchar(3), @quantity) + ' ' + isnull(@service_type,'') + ' ' + isnull(@service_name,'')
				--	set @remarks_tax = @remarks

				--	if(@transaction_code = 'MNTPPN')
				--	begin
				--		if(@return_value > 0)
				--		begin
				--			set @pph_type = 'PPN MASUKAN'
				--			set @income_type = 'PPN MASUKAN ' + convert(nvarchar(10), cast(@ppn_pct as int)) + '%'
				--			set @income_bruto_amount = @total_amount
				--			set @tax_rate = @ppn_pct
				--			set @ppn_pph_amount = @return_value
				--		end
				--	end
				--	else if(@transaction_code = 'MNTPPH')
				--	begin
				--		if(@return_value > 0)
				--		begin
				--			set @pph_type = 'PPH PASAL 23'
				--			set @income_type = 'Jasa Perawatan Kendaraan'
				--			set @income_bruto_amount = @total_amount
				--			set @tax_rate = @pph_pct
				--			set @ppn_pph_amount = @return_value
				--		end
				--	end
				--	else if(@transaction_code = 'MNTPPHP')
				--	begin
				--		if(@return_value > 0)
				--		begin
				--			set @pph_type = 'PPH PASAL 21'
				--			set @income_type = 'Jasa Tehnik'
				--			set @income_bruto_amount = @total_amount
				--			set @tax_rate = @pph_pct
				--			set @ppn_pph_amount = @return_value
				--			set @vendor_code = @vendor_code
				--			set @vendor_name = @vendor_name
				--			set @vendor_npwp = @vendor_npwp
				--			set @adress = @adress
				--		end
				--	end
				--	else
				--	begin
				--		set @income_type = ''
				--		set @pph_type = ''
				--		set @vendor_code = ''
				--		set @vendor_name = ''
				--		set @vendor_npwp = ''
				--		set @adress = ''
				--		set @income_bruto_amount = 0
				--		set @tax_rate = 0
				--		set @ppn_pph_amount = 0
				--		set @remarks_tax = ''
				--		set @faktur_no = ''
				--	end

				--	if @return_value <> 0
				--	begin
				--		exec dbo.xsp_payment_request_detail_insert @p_id						= 0
			 --   											   ,@p_payment_request_code			= @code_payment_request
			 --   											   ,@p_branch_code					= @branch_code_asset
			 --   											   ,@p_branch_name					= @branch_name_asset
			 --   											   ,@p_gl_link_code					= @gl_link_code
			 --   											   ,@p_agreement_no					= ''
			 --   											   ,@p_facility_code				= ''
			 --   											   ,@p_facility_name				= ''
			 --   											   ,@p_purpose_loan_code			= ''
			 --   											   ,@p_purpose_loan_name			= ''
			 --   											   ,@p_purpose_loan_detail_code		= ''
			 --   											   ,@p_purpose_loan_detail_name		= ''
			 --   											   ,@p_orig_currency_code			= 'IDR'
			 --   											   ,@p_exch_rate					= 0
			 --   											   ,@p_orig_amount					= @orig_amount_db
			 --   											   ,@p_division_code				= ''
			 --   											   ,@p_division_name				= ''
			 --   											   ,@p_department_code				= ''
			 --   											   ,@p_department_name				= ''
			 --   											   ,@p_remarks						= @remarks
			 --   											   ,@p_is_taxable					= '0'
			 --   											   ,@p_tax_amount					= 0
			 --   											   ,@p_tax_pct						= 0
				--											   ,@p_ext_pph_type					= @pph_type
				--											   ,@p_ext_vendor_code				= @vendor_code
				--											   ,@p_ext_vendor_name				= @vendor_name
				--											   ,@p_ext_vendor_npwp				= @vendor_npwp
				--											   ,@p_ext_vendor_address			= @adress
				--											   ,@p_ext_income_type				= @income_type
				--											   ,@p_ext_income_bruto_amount		= @income_bruto_amount
				--											   ,@p_ext_tax_rate_pct				= @tax_rate
				--											   ,@p_ext_pph_amount				= @ppn_pph_amount
				--											   ,@p_ext_description				= @remarks_tax
				--											   ,@p_ext_tax_number				= @faktur_no
				--											   ,@p_ext_sale_type				= ''
			 --   											   ,@p_cre_date						= @p_mod_date	  
			 --   											   ,@p_cre_by						= @p_mod_by		
			 --   											   ,@p_cre_ip_address				= @p_mod_ip_address
			 --   											   ,@p_mod_date						= @p_mod_date	  
			 --   											   ,@p_mod_by						= @p_mod_by		
			 --   											   ,@p_mod_ip_address				= @p_mod_ip_address
				--	end
				    
				
				--    fetch next from curr_payment 
				--	into @sp_name
				--		,@debet_or_credit
				--		,@gl_link_code
				--		,@transaction_code
				--		,@transaction_name
				--		,@wod_id
				--		,@service_name
				--		,@service_type
				--		,@quantity
				--		,@ppn_pct
				--		,@pph_pct
				--		,@total_amount
				--		,@vendor_code
				--		,@vendor_name
				--		,@adress
				--		,@vendor_npwp
				--end
				
				--close curr_payment
				--deallocate curr_payment

							
				--select @amount  = sum(isnull(iipr.payment_amount,0))
				--from   dbo.payment_request iipr
				--where code = @code_payment_request

				--select @orig_amount_db = sum(isnull(orig_amount,0)) 
				--from  dbo.payment_request_detail
				--where payment_request_code = @code_payment_request

				----set @amount = @amount + @orig_amount_db
				----+ validasi : total detail =  payment_amount yang di header

				--if (@amount <> @orig_amount_db)
				--begin
				--	set @msg = 'Payment Amount does not balance';
			 --		raiserror(@msg, 16, -1) ;
				--end			
			end

			if @is_reimburse = '1'
			begin
				set @description_request = 'Invoice Maintenance ' + format (@payment_amount, '#,###.00', 'DE-de') + ' for ' + @asset_code + ' - ' + @item_name + '.'
				exec dbo.xsp_ifinams_interface_additional_request_insert @p_id					= 0
																	 ,@p_agreement_no			= @agreement_no
																	 ,@p_asset_no				= @asset_no
																	 ,@p_branch_code			= @branch_code
																	 ,@p_branch_name			= @branch_name
																	 ,@p_invoice_type			= 'OTHRS'
																	 ,@p_invoice_date			= @date
																	 ,@p_invoice_name			= 'Invoice Maintenance'
																	 ,@p_client_no				= @client_no
																	 ,@p_client_name			= @client_name
																	 ,@p_client_address			= ''
																	 ,@p_client_area_phone_no	= ''
																	 ,@p_client_phone_no		= ''
																	 ,@p_client_npwp			= ''
																	 ,@p_currency_code			= 'IDR'
																	 ,@p_tax_scheme_code		= ''
																	 ,@p_tax_scheme_name		= ''
																	 ,@p_billing_no				= 0
																	 ,@p_description			= @description_request
																	 ,@p_quantity				= 1
																	 ,@p_billing_amount			= @payment_amount
																	 ,@p_discount_amount		= 0
																	 ,@p_ppn_pct				= 0
																	 ,@p_ppn_amount				= 0
																	 ,@p_pph_pct				= 0
																	 ,@p_pph_amount				= 0
																	 ,@p_total_amount			= @payment_amount
																	 ,@p_request_status			= 'HOLD'
																	 ,@p_reff_code				= @p_code
																	 ,@p_reff_name				= 'WORKORDER'
																	 ,@p_settle_date			= null
																	 ,@p_job_status				= 'HOLD'
																	 ,@p_failed_remarks			= ''
																	 ,@p_cre_date				= @p_mod_date	  
																	 ,@p_cre_by					= @p_mod_by		  
																	 ,@p_cre_ip_address			= @p_mod_ip_address
																	 ,@p_mod_date				= @p_mod_date	  
																	 ,@p_mod_by					= @p_mod_by		  
																	 ,@p_mod_ip_address			= @p_mod_ip_address
				
			end

			--Insert into Handover Request
			set @year = substring(cast(datepart(year, @p_mod_date) as nvarchar), 3, 2) ;
			set @month = replace(str(cast(datepart(month, @p_mod_date) as nvarchar), 2, 0), ' ', '0') ;

			exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			 = @code output
														,@p_branch_code			 = @branch_code
														,@p_sys_document_code	 = ''
														,@p_custom_prefix		 = 'WOHR'
														,@p_year				 = @year
														,@p_month				 = @month
														,@p_table_name			 = 'HANDOVER_REQUEST'
														,@p_run_number_length	 = 5
														,@p_delimiter			 = '.'
														,@p_run_number_only		 = '0' ;

			--insert into handover (maintenance out)
			--set @remarks = 'Pengembalian Asset ' + @asset_code
			--insert into dbo.handover_request
			--	(
			--		code
			--		,branch_code
			--		,branch_name
			--		,type
			--		,status
			--		,date
			--		,handover_from
			--		,handover_to
			--		,handover_address
			--		,handover_phone_area
			--		,handover_phone_no
			--		,eta_date
			--		,fa_code
			--		,remark
			--		,reff_code
			--		,reff_name
			--		,handover_code
			--		,cre_date
			--		,cre_by
			--		,cre_ip_address
			--		,mod_date
			--		,mod_by
			--		,mod_ip_address
			--	)
			--	values
			--	(
			--		@code
			--		,@branch_code
			--		,@branch_name
			--		,'MAINTENANCE IN'
			--		,'HOLD'
			--		,@p_mod_date
			--		,isnull(@vendor_name,'')
			--		,@requestor_name
			--		,@adress
			--		,''
			--		,@phone_no
			--		,NULL
			--		,@asset_code
			--		,@remarks
			--		,@maintenance_code
			--		,'ASSET MAINTENANCE'
			--		,null
			--		,@p_mod_date	  
			--		,@p_mod_by		  
			--		,@p_mod_ip_address
			--		,@p_mod_date	  
			--		,@p_mod_by		  
			--		,@p_mod_ip_address
			--	)

			--Update status WO jadi POST
			update	dbo.work_order
			set		status			= 'POST'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @p_code ;

			if(@maintenance_by = 'INT')
			begin
				update	dbo.work_order
				set		status			= 'PAID'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code			= @p_code ;
			end

			--kosongkan nomor work order
			update dbo.asset
			set		wo_no			= null
					,wo_status		= 'DONE'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @asset_code ;

			--Region Journal Maintenance
			--set @reff_source_name = 'Maintenance asset ' + @p_code + ' for ' + @item_name
			--exec dbo.xsp_efam_interface_journal_gl_link_transaction_insert @p_code						= @gllink_trx_code output
			--																,@p_company_code			= 'DSF'
			--																,@p_branch_code				= @branch_code
			--																,@p_branch_name				= @branch_name
			--																,@p_transaction_status		= 'HOLD'
			--																,@p_transaction_date		= @work_date
			--																,@p_transaction_value_date	= @work_date
			--																,@p_transaction_code		= @p_code
			--																,@p_transaction_name		= 'MAINTENANCE ASSET'
			--																,@p_reff_module_code		= 'IFINAMS'
			--																,@p_reff_source_no			= @p_code
			--																,@p_reff_source_name		= @reff_source_name
			--																,@p_transaction_type		= 'FAMDSP'
			--																---
			--																,@p_cre_date				= @p_mod_date	  
			--																,@p_cre_by					= @p_mod_by		  
			--																,@p_cre_ip_address			= @p_mod_ip_address
			--																,@p_mod_date				= @p_mod_date	  
			--																,@p_mod_by					= @p_mod_by		  
			--																,@p_mod_ip_address			= @p_mod_ip_address

				--declare c_inf_jour_gl cursor fast_forward for
				--select	mt.sp_name
				--		,mtp.debet_or_credit
				--		,mtp.gl_link_code
				--		,mt.transaction_name
				--		,mnt.branch_code
				--		,mnt.branch_name
				--		,wod.id
				--from	dbo.master_transaction_parameter mtp
				--		inner join dbo.master_transaction mt on mt.code				= mtp.transaction_code
				--												and mt.company_code = mtp.company_code
				--		inner join work_order wo on (wo.code						= @p_code)
				--		inner join dbo.work_order_detail wod on (wod.work_order_code = wo.code)
				--		inner join dbo.maintenance mnt on (mnt.code = wo.maintenance_code)
				--		inner join dbo.asset ass on (ass.code = mnt.asset_code)
				--where	process_code		 = 'WOPYT'
				--		and mtp.company_code = 'DSF'
				--		order by wod.service_code

				--open c_inf_jour_gl ;

				--fetch c_inf_jour_gl
				--into @sp_name
				--	,@debit_or_credit
				--	,@gl_link_code
				--	,@transaction_name 
				--	,@branch_code
				--	,@branch_name
				--	,@id_detail

				--while @@fetch_status = 0
				--begin
				--	-- nilainya exec dari MASTER_TRANSACTION.sp_name
				--	exec @return_value = @sp_name @id_detail ; -- sp ini mereturn value angka 

				--	--if(@return_value <> 0 )
				--	begin
				--		if (@debit_or_credit ='DEBIT')
				--		begin
				--			set @orig_amount_cr = 0
				--			set @orig_amount_db = @return_value
				--		end
				--		else
				--		begin
				--				set @orig_amount_cr = abs(@return_value)
				--				set @orig_amount_db = 0
				--		end		
				--	end

				--	set @detail_remark  = 'MAINTENANCE '+ @transaction_name + ' - ASSET CODE ' +@asset_code +' '+@item_name ;

				--	select @gl_link_code = dbo.xfn_get_gl_code_from_category(@asset_code, 'DSF', @gl_link_code)
					
				--	if @gl_link_code in ('DFASST','DFASIN','DFEXIN')
				--		select @gl_link_code = dbo.xfn_get_gl_code_from_item_grup_gl(@asset_code, 'DSF', @gl_link_code)
						
				--	set @gl_link_code = isnull(@gl_link_code,'')

				--	exec dbo.xsp_efam_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code		= @gllink_trx_code -- nvarchar(50)
				--																			,@p_company_code				= 'DSF'
				--																			,@p_branch_code					= @branch_code
				--																			,@p_branch_name					= @branch_name
				--																			,@p_cost_center_code			= null
				--																			,@p_cost_center_name			= null
				--																			,@p_gl_link_code				= @gl_link_code
				--																			,@p_agreement_no				= @asset_code
				--																			,@p_facility_code				= '' -- kosong
				--																			,@p_facility_name				= '' -- kosong
				--																			,@p_purpose_loan_code			= '' -- kosong
				--																			,@p_purpose_loan_name			= '' -- kosong
				--																			,@p_purpose_loan_detail_code	= '' -- kosong
				--																			,@p_purpose_loan_detail_name	= '' -- kosong
				--																			,@p_orig_currency_code			= 'IDR'
				--																			,@p_orig_amount_db				= @orig_amount_db
				--																			,@p_orig_amount_cr				= @orig_amount_cr
				--																			,@p_exch_rate					= @exch_rate 
				--																			,@p_base_amount_db				= @orig_amount_db
				--																			,@p_base_amount_cr				= @orig_amount_cr
				--																			,@p_division_code				= '' -- kosong
				--																			,@p_division_name				= '' -- kosong
				--																			,@p_department_code				= '' -- kosong
				--																			,@p_department_name				= '' -- kosongr
				--																			,@p_remarks						= @detail_remark
				--																			---
				--																			,@p_cre_date					= @p_mod_date	  
				--																			,@p_cre_by						= @p_mod_by		  
				--																			,@p_cre_ip_address				= @p_mod_ip_address
				--																			,@p_mod_date					= @p_mod_date	  
				--																			,@p_mod_by						= @p_mod_by		  
				--																			,@p_mod_ip_address				= @p_mod_ip_address

				--	fetch c_inf_jour_gl
				--	into @sp_name
				--		,@debit_or_credit
				--		,@gl_link_code
				--		,@transaction_name 
				--		,@branch_code
				--		,@branch_name
				--		,@id_detail
				--end ;

				--close c_inf_jour_gl ;
				--deallocate c_inf_jour_gl ;
		
				--select	@orig_amount_db = sum(orig_amount_db) 
				--		,@orig_amount_cr = sum(orig_amount_cr) 
				--from  dbo.efam_interface_journal_gl_link_transaction_detail
				--where gl_link_transaction_code = @gl_link_code

				----+ validasi : total detail =  payment_amount yang di header
				--if (@orig_amount_db <> @orig_amount_cr)
				--begin
				--	set @msg = 'Journal does not balance';
				--	raiserror(@msg, 16, -1) ;
				--end
				----EndRegion Journal Maintenance
					
			end
		else
		begin
			set @msg = 'Data already proceed';
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




