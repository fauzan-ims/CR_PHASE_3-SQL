CREATE PROCEDURE dbo.xsp_register_main_realization_proceed_230924
(
	@p_code					nvarchar(50)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin

	declare @msg								nvarchar(max)
			,@regis_status						nvarchar(20)
			--,@public_service_settlement_amount	decimal(18,2)
			,@branch_code						nvarchar(50)
			,@branch_name						nvarchar(250)
			,@remarks							nvarchar(4000)
			,@name								nvarchar(250)
			,@interface_code					nvarchar(50)
			,@system_date						datetime = dbo.xfn_get_system_date()
			,@to_bank_account_name				nvarchar(250)
			,@to_bank_name						nvarchar(250)
			,@to_bank_account_no				nvarchar(50)
			,@pbs_settlement_date				datetime
			,@pbs_settlement_voucher			nvarchar(50)
			,@delivery_receive_by				nvarchar(250)
			,@realization_amount				decimal(18, 2)
			,@dp_amount							decimal(18, 2)
			,@gl_link_transaction_code			nvarchar(50)
			,@sp_name							nvarchar(250)
			,@debet_or_credit					nvarchar(10)
			,@gl_link_code						nvarchar(50)
			,@transaction_name					nvarchar(250)
			,@orig_amount_cr					decimal(18, 2)
			,@orig_amount_db					decimal(18, 2)
			,@amount							decimal(18, 2)
			,@return_value						decimal(18, 2)
			,@order_main_code					nvarchar(50)
			,@tax_file_type                     nvarchar(10)
			,@tax_file_no 				        nvarchar(50)
			,@public_service_code		        nvarchar(50)
			,@tax_file_name						nvarchar(250)
			,@public_service_name 				nvarchar(250)
			,@is_taxable						nvarchar(1)
			,@source_reff_remarks				nvarchar(4000)
			,@index								int = 1
			,@fa_code							nvarchar(50)
			,@realization_date					datetime
			,@reff_remark						nvarchar(4000)
			,@item_name							nvarchar(250)
			,@code								nvarchar(50)
			,@payment_to						nvarchar(250)
			,@agreement_no						nvarchar(50)
			,@client_name						nvarchar(250)
			,@remarks_realization				nvarchar(4000)
			,@is_reimburse						nvarchar(1)
			,@description_request				nvarchar(4000)
			,@asset_no							nvarchar(50)
			,@client_no							nvarchar(50)
			,@ppn_amount						decimal(18, 2)
			,@pph_amount						decimal(18, 2)
			,@prepaid_amount					decimal(18,2)
			,@year_periode						int
			,@usefull							int
			,@monthly_amount					decimal(18,2)
			,@prepaid_no						nvarchar(50)
			,@counter							int
			,@date_prepaid						datetime
			,@register_status					nvarchar(50)
			,@payment_status					nvarchar(50)
			,@expense							decimal(18,2)
			,@reimburse_fee						decimal(18,2)
			,@invoice_no						nvarchar(50)
			,@faktur_no							nvarchar(50)
			,@transaction_code					nvarchar(50)
			,@income_type						nvarchar(250)
			,@income_bruto_amount				decimal(18,2)
			,@tax_rate							decimal(5,2)
			,@ppn_pph_amount					decimal(18,2)
			,@ppn_pct							decimal(9,6)
			,@pph_pct							decimal(9,6)
			,@vendor_type						nvarchar(25)
			,@pph_type							nvarchar(20)
			,@total_amount						decimal(18,2)
			,@remarks_tax						nvarchar(4000)
			,@vendor_code						nvarchar(50)
			,@vendor_name						nvarchar(250)
			,@vendor_npwp						nvarchar(20)
			,@adress							nvarchar(4000)
			,@service_fee						decimal(18,2)
			,@to_bank_account_name_client		nvarchar(250)
			,@to_bank_name_client				nvarchar(250)
			,@to_bank_account_no_client			nvarchar(50)
			,@branch_code_asset					nvarchar(50)
			,@branch_name_asset					nvarchar(250)
			,@plat_no							nvarchar(50)
			,@agreement_external_no				nvarchar(50)
			,@asset_code						nvarchar(50) -- (+) Ari 2023-11-20
			,@faktur_no_invoice					NVARCHAR(50)
			,@faktur_date						datetime
			,@invoice_name						nvarchar(250)
			,@reimburse_to_cust					nvarchar(1)
			,@journal_code						nvarchar(50)
			,@journal_date						datetime
			,@journal_remark					nvarchar(4000)
			,@source_name						nvarchar(250)
			,@value1							int
			,@value2							int
			,@invoice_date						datetime

	begin try
		
		select	@regis_status						= register_status
				,@payment_status					= rm.payment_status
				--,@public_service_settlement_amount	= public_service_settlement_amount + (rm.realization_service_fee * rm.realization_service_tax_ppn_pct / 100) - (rm.realization_service_fee * rm.realization_service_tax_pph_pct / 100)
				,@branch_code						= rm.branch_code
				,@branch_name						= rm.branch_name
				,@dp_amount							= dp_to_public_service_amount
				,@realization_amount				= public_service_settlement_amount --isnull(realization_actual_fee + realization_service_fee + (rm.realization_service_fee * rm.realization_service_tax_ppn_pct / 100) -  (rm.realization_service_fee * rm.realization_service_tax_pph_pct / 100),0)
				,@fa_code							= fa_code
				,@realization_date					= realization_date
				,@item_name							= ass.item_name
				,@agreement_no						= ass.agreement_no
				,@client_name						= ass.client_name
				,@remarks_realization				= rm.register_remarks
				,@is_reimburse						= rm.is_reimburse
				,@asset_no							= ass.asset_no
				,@client_no							= ass.client_no
				,@ppn_amount						= rm.realization_service_fee * rm.realization_service_tax_ppn_pct / 100
				,@pph_amount						= rm.realization_service_fee * rm.realization_service_tax_pph_pct / 100
				,@expense							= rm.realization_actual_fee + rm.realization_service_fee
				,@reimburse_fee						= rm.realization_actual_fee + rm.realization_service_fee + (rm.realization_service_fee * rm.realization_service_tax_ppn_pct / 100) - (rm.realization_service_fee * rm.realization_service_tax_pph_pct / 100)
				,@invoice_no						= rm.realization_invoice_no
				,@ppn_pct							= rm.realization_service_tax_ppn_pct
				,@pph_pct							= rm.realization_service_tax_pph_pct
				,@service_fee						= rm.realization_service_fee
				,@to_bank_account_name_client		= rm.payment_bank_account_name
				,@to_bank_account_no_client			= rm.payment_bank_account_no
				,@to_bank_name_client				= rm.payment_bank_name
				,@plat_no							= avh.plat_no
				,@agreement_external_no				= ass.agreement_external_no
				,@asset_code						= ass.code -- (+) Ari 2023-11-20 ket : get asset code
				,@faktur_no							= rm.faktur_no
				,@reimburse_to_cust					= rm.is_reimburse_to_customer
				,@faktur_date						= rm.faktur_date
				,@branch_code_asset					= ass.branch_code
				,@branch_name_asset					= ass.branch_name
				,@invoice_date						= rm.realization_invoic_date
		from	dbo.register_main rm
		inner join dbo.asset ass on (ass.code = rm.fa_code)
		inner join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
		where	rm.code = @p_code


		set @agreement_external_no = isnull(@agreement_external_no,@asset_code)

		select	@payment_to				= mps.public_service_name
				,@to_bank_account_name	= mpsb.bank_account_name
				,@to_bank_name			= mpsb.bank_name
				,@to_bank_account_no	= mpsb.bank_account_no
				,@public_service_code	= om.public_service_code
		from	dbo.order_main om
				inner join dbo.order_detail od on od.order_code = om.code
				inner join dbo.master_public_service mps on mps.code = om.public_service_code
				left join dbo.master_public_service_bank mpsb on (mpsb.public_service_code = mps.code and mpsb.is_default = '1')
		where	od.register_code = @p_code

		select	@value1 = value
		from	dbo.sys_global_param
		where	CODE = 'RLZINV' ;

		select	@value2 = value
		from	dbo.sys_global_param
		where	CODE = 'RLZFKT' ;

		if(@invoice_date < dateadd(month, -@value1, dbo.xfn_get_system_date()))
		begin
			if(@value1 <> 0)
			begin
				set @msg = N'Realization invoice date cannot be back dated for more than ' + convert(varchar(1), @value1) + ' months.' ;

				raiserror(@msg, 16, -1) ;
			end
			else if (@value1 = 0)
			begin
				set @msg = N'Realization invoice date must be equal than system date.' ;

				raiserror(@msg, 16, -1) ;
			end
		end

		if(@faktur_date < dateadd(month, -@value2, dbo.xfn_get_system_date()))
		begin
			if(@value2 <> 0)
			begin
				set @msg = N'Faktur date cannot be back dated for more than ' + convert(varchar(1), @value2) + ' months.' ;

				raiserror(@msg, 16, -1) ;
			end
			else if (@value2 = 0)
			begin
				set @msg = N'Faktur date must be equal than system date.' ;

				raiserror(@msg, 16, -1) ;
			end
		end
		
		if(@ppn_amount > 0) and ((@faktur_no = '') or (isnull(@faktur_no,'')=''))
		begin
			set @msg = N'Please Input Faktur No!';
			raiserror(@msg, 16, 1)
		end;

		if @realization_amount = 0
		begin
			set @msg = 'Please input realization amount.'
			raiserror(@msg ,16,-1)
		end
		
		if @realization_amount = @dp_amount
		begin
			set @transaction_name = 'Public Service Realization for ' + @fa_code
			exec dbo.xsp_efam_interface_journal_gl_link_transaction_insert @p_code						= @gl_link_transaction_code output
																		   ,@p_company_code				= 'DSF'
																		   ,@p_branch_code				= @branch_code
																		   ,@p_branch_name				= @branch_name
																		   ,@p_transaction_status		= 'HOLD'
																		   ,@p_transaction_date			= @p_mod_date
																		   ,@p_transaction_value_date	= @p_mod_date
																		   ,@p_transaction_code			= 'AMS REALIZATION'
																		   ,@p_transaction_name			= @transaction_name
																		   ,@p_reff_module_code			= 'IFINAMS'
																		   ,@p_reff_source_no			= @p_code
																		   ,@p_reff_source_name			= 'PUBLIC SERVICE REALIZATION'
																		   ,@p_is_journal_reversal		= '0'
																		   ,@p_transaction_type			= null
																		   ,@p_cre_date					= @p_cre_date
																		   ,@p_cre_by					= @p_cre_by
																		   ,@p_cre_ip_address			= @p_cre_ip_address
																		   ,@p_mod_date					= @p_mod_date
																		   ,@p_mod_by					= @p_mod_by
																		   ,@p_mod_ip_address			= @p_mod_ip_address

		    
			-- loop tabel dbo.master_transaction_parameter mtp  mtp.process_code ='JURPBS01'
			--				join ke MASTER_TRANSACTION
			declare cur_parameter cursor local fast_forward read_only for
			select  mt.sp_name
					,mtp.debet_or_credit
					,mtp.gl_link_code
					,mt.transaction_name
			from	dbo.master_transaction_parameter mtp 
					left join dbo.sys_general_subcode sgs on (sgs.code = mtp.process_code)
					left join dbo.master_transaction mt on (mt.code = mtp.transaction_code)
			where	mtp.process_code = 'JURPBS02'
			
			open cur_parameter
			fetch cur_parameter 
			into @sp_name
				 ,@debet_or_credit
				 ,@gl_link_code
				 ,@transaction_name

			while @@fetch_status = 0
			begin
				-- nilainya exec dari MASTER_TRANSACTION.sp_name
				exec @return_value = @sp_name @p_code ; -- sp ini mereturn value angka 
					
				if (@debet_or_credit ='DEBIT')
					begin
						set @orig_amount_cr = 0
						set @orig_amount_db = @return_value
					end
				else
				begin
						set @orig_amount_cr = abs(@return_value)
						set @orig_amount_db = 0 
				end

				if (isnull(@gl_link_code, '') = '')
				begin
					set @msg = 'Please Setting GL Link For ' + @transaction_name;
					raiserror(@msg, 16, -1);
				end

					-- setial loop insert ke pbs_interface_cashier_received_request_detail
					set @remarks = 'Journal Gl Link ' + @p_code + ', FA Code ' + @fa_code

					exec dbo.xsp_efam_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code	= @gl_link_transaction_code
																						  ,@p_company_code				= 'DSF'
																						  ,@p_branch_code		        = @branch_code
																						  ,@p_branch_name			    = @branch_name
																						  ,@p_cost_center_code			= null
																						  ,@p_cost_center_name			= null
																						  ,@p_gl_link_code				= @gl_link_code
																						  ,@p_agreement_no				= @agreement_external_no
																						  ,@p_facility_code				= null
																						  ,@p_facility_name				= null
																						  ,@p_purpose_loan_code			= null
																						  ,@p_purpose_loan_name			= null
																						  ,@p_purpose_loan_detail_code	= null
																						  ,@p_purpose_loan_detail_name	= null
																						  ,@p_orig_currency_code		= 'IDR' --Kebutuhan sekarang di set IDR
																						  ,@p_orig_amount_db			= @orig_amount_db
																						  ,@p_orig_amount_cr			= @orig_amount_cr
																						  ,@p_exch_rate					= 1
																						  ,@p_base_amount_db			= @orig_amount_db
																						  ,@p_base_amount_cr			= @orig_amount_cr
																						  ,@p_division_code				= ''
																						  ,@p_division_name				= ''
																						  ,@p_department_code			= ''
																						  ,@p_department_name			= ''
																						  ,@p_remarks					= ''
																						  ,@p_cre_date					= @p_cre_date		 
																						  ,@p_cre_by					= @p_cre_by	
																						  ,@p_cre_ip_address			= @p_cre_ip_address
																						  ,@p_mod_date					= @p_mod_date		 
																						  ,@p_mod_by					= @p_mod_by	 
																						  ,@p_mod_ip_address			= @p_mod_ip_address	
					
			
					
				fetch cur_parameter 
				into @sp_name
						,@debet_or_credit
						,@gl_link_code
						,@transaction_name

			end
			close cur_parameter
			deallocate cur_parameter
			
			select @orig_amount_db = isnull(sum(orig_amount_db),0)
				   ,@orig_amount_cr = isnull(sum(orig_amount_cr),0)
			from  dbo.efam_interface_journal_gl_link_transaction_detail
			where gl_link_transaction_code = @gl_link_transaction_code


			--+ validasi : total detail =  payment_amount yang di header
			if (@orig_amount_db <> @orig_amount_cr)
			begin
				set @msg = 'Journal does not balance';
    			raiserror(@msg, 16, -1) ;
			end
		end

		-- jika realisasi < besar dari dp - maka lakukan rv
        if @realization_amount < 0
		begin
		    set @remarks = 'REALIZATION PUBLIC SERVICE FOR ' + @fa_code
			set @realization_amount = abs(@realization_amount)
			
			exec dbo.xsp_efam_interface_received_request_insert @p_id						= 0
																,@p_code					= @interface_code output
																,@p_company_code			= 'DSF'
																,@p_branch_code				= @branch_code
																,@p_branch_name				= @branch_name
																,@p_received_source			= 'REALIZATION FOR PUBLIC SERVICE'
																,@p_received_request_date	= @p_cre_date
																,@p_received_source_no		= @p_code
																,@p_received_status			= 'HOLD'
																,@p_received_currency_code	= 'IDR'
																,@p_received_amount			= @realization_amount
																,@p_received_remarks		= @remarks
																,@p_process_date			= null
																,@p_process_reff_no			= null
																,@p_process_reff_name		= null
																,@p_settle_date				= @p_cre_date
																,@p_job_status				= 'HOLD'
																,@p_failed_remarks			= null
																,@p_cre_date				= @p_cre_date
															    ,@p_cre_by					= @p_cre_by
															    ,@p_cre_ip_address			= @p_cre_ip_address
															    ,@p_mod_date				= @p_mod_date
															    ,@p_mod_by					= @p_mod_by
															    ,@p_mod_ip_address			= @p_mod_ip_address
			


			-- loop tabel dbo.master_transaction_parameter mtp  mtp.process_code ='JURPBS07'
			--				join ke MASTER_TRANSACTION
			declare cur_parameter cursor local fast_forward read_only for
			select  mt.sp_name
					,mtp.debet_or_credit
					,mtp.gl_link_code
					,mt.transaction_name
					,mtp.is_taxable
			from	dbo.master_transaction_parameter mtp 
					left join dbo.sys_general_subcode sgs on (sgs.code = mtp.process_code)
					left join dbo.master_transaction mt on (mt.code = mtp.transaction_code)
			where	mtp.process_code = 'JRRV'	
			
			open cur_parameter
			fetch cur_parameter 
			into @sp_name
				 ,@debet_or_credit
				 ,@gl_link_code
				 ,@transaction_name
				 ,@is_taxable

			while @@fetch_status = 0
			begin
				select	@order_main_code = code
				from	dbo.order_main om
				inner join dbo.order_detail od on (od.order_code = om.code)
				where od.register_code = @p_code

				-- nilainya exec dari MASTER_TRANSACTION.sp_name
				exec @return_value = @sp_name @p_code ; -- sp ini mereturn value angka
			
				if (@debet_or_credit ='DEBIT')
					begin
						set @orig_amount_db = @return_value
					end
				else
				begin
					set @orig_amount_db = @return_value * -1
				end
						
						--SET @remarks = 'REALIZATION PUBLIC SERVICE FOR ' + @payment_to + ' ' +  @transaction_name
						set @remarks = @transaction_name + ' ' + format (@orig_amount_db, '#,###.00', 'DE-de') + ', for ' + @payment_to
						exec dbo.xsp_efam_interface_received_request_detail_insert @p_id						= 0
																				   ,@p_received_request_code	= @interface_code
																				   ,@p_company_code				= 'DSF'
																				   ,@p_branch_code				= @branch_code
																				   ,@p_branch_name				= @branch_name
																				   ,@p_gl_link_code				= @gl_link_code
																				   ,@p_agreement_no				= @agreement_external_no
																				   ,@p_facility_code			= null
																				   ,@p_facility_name			= null
																				   ,@p_purpose_loan_code		= null
																				   ,@p_purpose_loan_name		= null
																				   ,@p_purpose_loan_detail_code = null
																				   ,@p_purpose_loan_detail_name = null
																				   ,@p_orig_currency_code		= 'IDR'
																				   ,@p_orig_amount				= @orig_amount_db
																				   ,@p_division_code			= null
																				   ,@p_division_name			= null
																				   ,@p_department_code			= null
																				   ,@p_department_name			= null
																				   ,@p_remarks					= @remarks
																			       ,@p_cre_date					= @p_cre_date		 
																				   ,@p_cre_by					= @p_cre_by	
																				   ,@p_cre_ip_address			= @p_cre_ip_address
																				   ,@p_mod_date					= @p_mod_date		 
																				   ,@p_mod_by					= @p_mod_by	 
																				   ,@p_mod_ip_address			= @p_mod_ip_address	 

				fetch cur_parameter 
				into @sp_name
					,@debet_or_credit
					,@gl_link_code
					,@transaction_name
					,@is_taxable

			end
			close cur_parameter
			deallocate cur_parameter

			select @amount  = isnull(sum(iipr.received_amount),0)
			from   dbo.efam_interface_received_request iipr
			where code = @interface_code


			select @orig_amount_db = isnull(sum(orig_amount),0)
			from  dbo.efam_interface_received_request_detail
			where received_request_code = @interface_code

			set @amount = @amount + @orig_amount_db

			--+ validasi : total detail =  payment_amount yang di header
			if (@amount <> 0)
			begin
				set @msg = 'Received Amount does not balance';
    			raiserror(@msg, 16, -1) ;
			end    
		end
		
		-- jika realisasi > besar dari dp - maka lakukan pv
		else if @realization_amount > 0
		begin
			select @tax_file_type        = tax_file_type
				   ,@tax_file_no         = tax_file_no
				   ,@tax_file_name       = tax_file_name
				   ,@public_service_name = public_service_name
			from dbo.master_public_service
			where code = @public_service_code

			--set @source_reff_remarks = 'Payment Realization Public Servoce fro ' + @public_service_name 

		    set @remarks = 'Realization public service for ' + @public_service_name + ', with invoice ' + @invoice_no + '. ' + @plat_no + ' - ' + @remarks_realization
			set @realization_amount = abs(@realization_amount)

			if @is_reimburse = '1'
			begin
				set @payment_to				= @client_name
				set @to_bank_name			= @to_bank_name_client
				set @to_bank_account_no		= @to_bank_account_no_client
				set @to_bank_account_name	= @to_bank_account_name_client
			end

			--journal cash basis
			if (month(@faktur_date) < month(dbo.xfn_get_system_date()))
			begin
				set @journal_date = dbo.xfn_get_system_date()
			end
			else if (isnull(@faktur_date,'') = '')
			begin
				set @journal_date = dbo.xfn_get_system_date()
			end
			else
			begin
				set @journal_date = @faktur_date
			end

			set @source_name = 'Realization public service for ' + @plat_no
			exec dbo.xsp_efam_interface_journal_gl_link_transaction_insert @p_code						= @journal_code output
																		  ,@p_company_code				= 'DSF'
																		  ,@p_branch_code				= @branch_code_asset
																		  ,@p_branch_name				= @branch_name_asset
																		  ,@p_transaction_status		= 'HOLD'
																		  ,@p_transaction_date			= @system_date --@journal_date
																		  ,@p_transaction_value_date	= @invoice_date --@journal_date
																		  ,@p_transaction_code			= @p_code
																		  ,@p_transaction_name			= 'REALIZATION ASSET'
																		  ,@p_reff_module_code			= 'IFINAMS'
																		  ,@p_reff_source_no			= @p_code
																		  ,@p_reff_source_name			= @source_name
																		  ,@p_is_journal_reversal		= '0'
																		  ,@p_transaction_type			= ''
																		  ,@p_cre_date					= @p_mod_date
																		  ,@p_cre_by					= @p_mod_by
																		  ,@p_cre_ip_address			= @p_mod_ip_address
																		  ,@p_mod_date					= @p_mod_date
																		  ,@p_mod_by					= @p_mod_by
																		  ,@p_mod_ip_address			= @p_mod_ip_address ;


			declare curr_journal cursor fast_forward read_only for
			select	mt.sp_name
					,mtp.debet_or_credit
					,mtp.gl_link_code
					,mtp.transaction_code
					,mt.transaction_name
					,mtp.is_taxable
					,mps.code
					,mps.public_service_name
					,mps.tax_file_address
					,rm.faktur_no
					,rm.realization_invoice_no  -- (+) Ari 2023-12-18 ket : req pah hary jika faktur null pakai invoice 
					,rm.faktur_date
					,mps.tax_file_type
					,ass.branch_code
					,ass.branch_name
					,mps.tax_file_no
			from	dbo.master_transaction_parameter			mtp
					left join dbo.sys_general_subcode			sgs on (sgs.code							= mtp.process_code)
					left join dbo.master_transaction			mt on (mt.code								= mtp.transaction_code)
					inner join dbo.register_main				rm on rm.code								= @p_code
					inner join dbo.order_main					om on (om.code collate Latin1_General_CI_AS = rm.order_code)
					inner join dbo.master_public_service		mps on mps.code								= om.public_service_code
					left join dbo.master_public_service_address mpsa on (
																			mpsa.public_service_code		= mps.code
																			and mpsa.is_latest				= '1'
																		)
					inner join dbo.asset						ass on (ass.code							= rm.fa_code)
			where	mtp.process_code = 'JRPV2' ;
			
			open curr_journal
			
			fetch next from curr_journal 
			into @sp_name
				 ,@debet_or_credit
				 ,@gl_link_code
				 ,@transaction_code
				 ,@transaction_name
				 ,@is_taxable
				 ,@vendor_code
				 ,@vendor_name
				 ,@adress
				 ,@faktur_no
				 ,@faktur_no_invoice
				 ,@faktur_date
				 ,@tax_file_type
				 ,@branch_code_asset
				 ,@branch_name_asset
				 ,@vendor_npwp
			
			while @@fetch_status = 0
			begin
				-- nilainya exec dari MASTER_TRANSACTION.sp_name
				exec @return_value = @sp_name @p_code ; -- sp ini mereturn value angka 
					
				--if(isnull(@return_value,0) <> 0 )
				begin
					if (@debet_or_credit = 'DEBIT')
					begin
						set @orig_amount_cr = 0 ;
						set @orig_amount_db = @return_value ;
					end ;
					else
					begin
						set @orig_amount_cr = abs(@return_value) ;
						set @orig_amount_db = 0 ;
					end ;
				end ;

				set @journal_remark = @transaction_name + ', ' + format (@orig_amount_db, '#,###.00', 'DE-de') +  ' for ' + @public_service_name
				set @remarks_tax =  @journal_remark

				if(@transaction_code in ('RLZPPN','RLZPPH','RLZPPH21'))
					begin
						if (@faktur_no = '0000000000000000') or (isnull(@faktur_no,'')='')-- hari 12 jan 2024 -- jika faktur default maka ambil invoice no
						begin
								if len(@faktur_no_invoice) = 16 -- Raffy 19/06/2024 Jika invoice nya 16 digit maka ditambahkan string baru agar invoice lebih dari 16 digit
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

				if(@transaction_code = 'RLZPPN')
				begin
					if(@return_value > 0)
					begin
						set @pph_type				= 'PPN MASUKAN'
						set @income_type			= 'PPN MASUKAN ' + convert(nvarchar(10), cast(@ppn_pct as int)) + '%'
						set @income_bruto_amount	= @service_fee
						set @tax_rate				= @ppn_pct
						set @ppn_pph_amount			= @return_value
					end
				end
				else if(@transaction_code = 'RLZPPH')
				begin
					if(@return_value > 0)
					begin
						if(@tax_file_type = 'N21' or @tax_file_type = 'P21')
						begin
							set @income_type			= 'PERANTARA' -- (+) Ari Ari 2024-01-30 ket : dibedakan berdasarkan personal / corporate
							set @pph_type				= 'PPH PASAL 21'
						end
						if(@tax_file_type = 'N23' or @tax_file_type = 'P23')
						begin
							set @income_type			= 'JASA PERANTARA/AGEN' -- (+) Ari 2024-01-30 ket : dibedakan berdasarkan personal / corporate
							set @pph_type				= 'PPH PASAL 23'
						end
						--set @income_type			= 'PERANTARA' -- (+) Ari 2024-01-30 ket : dibedakan berdasarkan personal / corporate
						set @income_bruto_amount	= @service_fee
						set @tax_rate				= @pph_pct
						set @ppn_pph_amount			= @return_value
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
					set @faktur_date = null
				end

			    exec dbo.xsp_efam_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code		= @journal_code
																				      ,@p_company_code					= 'DSF'
																				      ,@p_branch_code					= @branch_code_asset
																				      ,@p_branch_name					= @branch_name_asset
																				      ,@p_cost_center_code				= null
																				      ,@p_cost_center_name				= null
																				      ,@p_gl_link_code					= @gl_link_code
																				      ,@p_agreement_no					= @agreement_external_no
																				      ,@p_facility_code					= ''
																				      ,@p_facility_name					= ''
																				      ,@p_purpose_loan_code				= ''
																				      ,@p_purpose_loan_name				= ''
																				      ,@p_purpose_loan_detail_code		= ''
																				      ,@p_purpose_loan_detail_name		= ''
																				      ,@p_orig_currency_code			= 'IDR'
																				      ,@p_orig_amount_db				= @orig_amount_db
																				      ,@p_orig_amount_cr				= @orig_amount_cr
																				      ,@p_exch_rate						= 0
																				      ,@p_base_amount_db				= @orig_amount_db
																				      ,@p_base_amount_cr				= @orig_amount_cr
																				      ,@p_division_code					= ''
																				      ,@p_division_name					= ''
																				      ,@p_department_code				= ''
																				      ,@p_department_name				= ''
																				      ,@p_remarks						= @journal_remark
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
																				      ,@p_ext_sale_type					= ''
																				      ,@p_cre_date						= @p_mod_date
																				      ,@p_cre_by						= @p_mod_by
																				      ,@p_cre_ip_address				= @p_mod_ip_address
																				      ,@p_mod_date						= @p_mod_date
																				      ,@p_mod_by						= @p_mod_by
																				      ,@p_mod_ip_address				= @p_mod_ip_address ;
			
			    fetch next from curr_journal 
				into @sp_name
					,@debet_or_credit
					,@gl_link_code
					,@transaction_code
					,@transaction_name
					,@is_taxable
					,@vendor_code
					,@vendor_name
					,@adress
					,@faktur_no
					,@faktur_no_invoice
					,@faktur_date
					,@tax_file_type
					,@branch_code_asset
					,@branch_name_asset
					,@vendor_npwp
			end
			
			close curr_journal
			deallocate curr_journal

			-- balancing
			begin
				if ((
						select	sum(orig_amount_db) - sum(orig_amount_cr)
						from	dbo.efam_interface_journal_gl_link_transaction_detail
						where	gl_link_transaction_code = @journal_code
					) <> 0
				   )
				begin
					set @msg = N'Journal is not balance.' ;

					raiserror(@msg, 16, -1) ;
				end ;
			end ;

			select @branch_code		= value
					,@branch_name	= description
			from dbo.sys_global_param
			where code = 'HO'
		end

	-- tambahkan saat xsp_efam_interface_payment_request_insert --  di paid baru insert ke expense ledger
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

end





