 CREATE PROCEDURE [dbo].[xsp_realization_subcription_gps_proceed_after_approve]
 (
 	@p_code				NVARCHAR(50)
 	--
 	,@p_cre_date		DATETIME
 	,@p_cre_by			NVARCHAR(15)
 	,@p_cre_ip_address	NVARCHAR(15)
 	,@p_mod_date		DATETIME
 	,@p_mod_by			NVARCHAR(15)
 	,@p_mod_ip_address	NVARCHAR(15)
 )
 AS
 BEGIN
 	DECLARE @msg							NVARCHAR(MAX)
 			,@policy_payment_type			NVARCHAR(5)
 			,@insurance_code				NVARCHAR(50)
 			,@branch_code					NVARCHAR(50)
 			,@branch_name					NVARCHAR(250)
 			,@total_premi_buy_amount		decimal(18, 2)
 			,@bank_name						nvarchar(250)
 			,@bank_account_no				nvarchar(50)
 			,@bank_account_name				nvarchar(250)
 			,@payment_remarks				nvarchar(4000)
 			,@system_date					datetime	   = dbo.xfn_get_system_date()
 			,@payment_request_code			nvarchar(50)
 			,@fa_code						nvarchar(50)
 			,@fa_name						nvarchar(250)
 			,@sp_name						nvarchar(250)
 			,@debet_or_credit				nvarchar(10)
 			,@orig_amount					decimal(18, 2)
 			,@payment_amount				decimal(18, 2)
 			,@gl_link_code					nvarchar(50)
 			,@currency						nvarchar(3)
 			,@return_value					decimal(18, 2)
 			,@tax_file_type					nvarchar(10)
 			,@tax_file_no					nvarchar(50)
 			,@max_year						int
 			,@tax_file_name					nvarchar(250)
 			,@policy_eff_date				datetime
 			,@policy_exp_date				datetime
 			,@year_periode					int
 			,@period_eff_date				datetime
 			,@period_exp_date				datetime
 			,@sell_amount					decimal(18, 2)
 			,@initial_discount_amount		decimal(18, 2)
 			,@buy_amount					decimal(18, 2)
 			,@adjustment_discount_amount	decimal(18, 2)
 			,@adjustment_buy_amount			decimal(18, 2)
 			,@total_amount					decimal(18, 2)
 			,@ppn_amount					decimal(18, 2)
 			,@pph_amount					decimal(18, 2)
 			,@total_payment_amount			decimal(18, 2)
 			,@code_payment_request			nvarchar(50)
 			,@total_buy_amount				decimal(18,2)
 			,@payment_name					nvarchar(50)
 			,@prepaid_no					nvarchar(50)
 			,@total_net_premi_amount		decimal(18,2)
 			,@usefull						int
 			,@monthly_amount				decimal(18,2)
 			,@counter						int
 			,@sisa							decimal(18,2)
 			,@amount						decimal(18,2)
 			,@date_prepaid					datetime
 			,@invoice_code					nvarchar(50)
 			,@reff_remark					nvarchar(4000)
 			,@date							datetime
 			,@agreement_no					nvarchar(50)
 			,@client_name					nvarchar(250)
 			,@remarks_journal				nvarchar(4000)
 			,@transaction_name				nvarchar(250)
 			,@policy_no						nvarchar(50)
 			,@insured_name					nvarchar(250)
 			,@faktur_no						nvarchar(50)
 			,@vendor_npwp					nvarchar(20)
 			,@income_type					nvarchar(250)
 			,@income_bruto_amount			decimal(18,2)
 			,@tax_rate						decimal(5,2)
 			,@ppn_pph_amount				decimal(18,2)
 			,@transaction_code				nvarchar(50)
 			,@ppn_pct						decimal(9,6)
 			,@pph_pct						decimal(9,6)
 			,@pph_type						nvarchar(20)
 			,@vendor_code					nvarchar(50)
 			,@vendor_name					nvarchar(250)
 			,@adress						nvarchar(4000)
 			,@remarks_tax					nvarchar(4000)
 			,@branch_code_asset				nvarchar(50)
 			,@branch_name_asset				nvarchar(250)
 			,@agreement_external_no			nvarchar(50)
 			,@agreement_fa_code				NVARCHAR(50)
 			,@faktur_date					datetime
			,@journal_code					nvarchar(50)
			,@journal_date					datetime
			,@source_name					nvarchar(250)
			,@journal_remark				nvarchar(4000)
			,@orig_amount_db				decimal(18,2)
			,@orig_amount_cr				decimal(18,2)
			,@value1						int
			,@value2						int
			,@invoice_date					datetime
			,@cre_by						nvarchar(50)
			,@ext_vendor_nitku				nvarchar(50)
			,@ext_vendor_npwp_pusat			nvarchar(50)
			,@realization_no				NVARCHAR(50)
			,@asset_name					NVARCHAR(250)
			,@plat_no						NVARCHAR(250)
			,@engine_no						NVARCHAR(250)
			,@chassis_no					NVARCHAR(250)
			,@realization_status			NVARCHAR(50)
			,@subcribe_amount				decimal(18,2)
			,@payment_date					DATETIME
			,@invoice_no					NVARCHAR(50)
			,@invoice_amout					decimal(18,2)
			,@realization_date				DATETIME
			,@tax_code						NVARCHAR(50)
			,@billing_amount				decimal(18,2)
			,@invoice_amount				decimal(18,2)
			,@invoice_file_name				NVARCHAR(250)
			,@invoice_path					NVARCHAR(500)
			,@voucher						NVARCHAR(50)
			,@id_asset_schedule				BIGINT
			,@installment_no				NVARCHAR(50)
			,@subcribe_amount_month			DECIMAL(18,2)
			,@payment_date_asset_schedule	DATETIME
			,@paid_date						DATETIME
			,@next_billing					DATETIME
            ,@status_asset_schedule			NVARCHAR(25)
 
 		BEGIN TRY
 		SET @date = dbo.xfn_get_system_date()

		SELECT	@realization_no			= grs.REALIZATION_NO
				,@fa_code				= ast.code
				,@asset_name			= ast.item_name
				,@plat_no				= av.plat_no
				,@engine_no				= av.engine_no
				,@chassis_no			= av.chassis_no
				,@agreement_external_no	= ast.agreement_external_no
				,@agreement_no          = grs.agreement_no
				,@vendor_name			= ags.vendor_name
				,@realization_status	= grs.status
				,@subcribe_amount		= ags.subcribe_amount_month
				,@payment_date          = grs.PAYMENT_DATE
				,@vendor_name           = grs.VENDOR_NAME
				,@invoice_no            = grs.INVOICE_NO
				,@invoice_amout         = grs.INVOICE_AMOUNT
				,@bank_name             = grs.BANK_NAME
				,@bank_account_no       = grs.BANK_ACCOUNT_NO
				,@bank_account_name     = grs.BANK_ACCOUNT_NAME
				,@realization_date      = grs.REALIZATION_DATE
				,@invoice_date          = grs.INVOICE_DATE
				,@faktur_no             = grs.FAKTUR_NO
				,@faktur_date           = grs.FAKTUR_DATE
				,@tax_code              = grs.TAX_CODE
				,@billing_amount        = grs.BILLING_AMOUNT
				,@ppn_amount            = grs.PPN_AMOUNT
				,@pph_amount            = grs.pph_amount
				,@invoice_amount        = grs.invoice_amount
				,@invoice_file_name     = grs.invoice_file_name
				,@invoice_path          = grs.invoice_path
				,@voucher               = grs.voucher
				,@branch_code			= grs.branch_code
				,@branch_name			= grs.branch_name
				,@payment_remarks		= 'Payment Realization subcription GPS ' + isnull(grs.REALIZATION_NO, '') + ' For Asset Code ' + grs.FA_CODE   
		from	dbo.GPS_REALIZATION_SUBCRIBE grs
				LEFT JOIN dbo.ASSET						ast		ON ast.CODE = grs.FA_CODE
				left JOIN dbo.ASSET_VEHICLE				av		ON av.ASSET_CODE = ast.CODE
				left JOIN dbo.ASSET_GPS_SCHEDULE 		ags		ON ags.FA_CODE = ast.CODE
				left JOIN IFINOPL.dbo.AGREEMENT_ASSET	agast	ON agast.ASSET_NO = ast.ASSET_NO
		where	grs.REALIZATION_NO = @p_code ;

		select	@value1 = value
		from	dbo.sys_global_param
		where	CODE = 'GPSINV' ;

		select	@value2 = value
		from	dbo.sys_global_param
		where	CODE = 'GPSFKT' ;

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
		END

 
 		if exists (select 1 from dbo.gps_realization_subcribe where REALIZATION_NO = @p_code and STATUS = 'APPROVE')
 		begin
 			
 			--journal cash basis
			if(convert(nvarchar(6), @faktur_date, 112) < convert(nvarchar(6), dbo.xfn_get_system_date(), 112))
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
			set @source_name = N'Realization subcription GPS for ' + @p_code;

			declare curr_branch cursor fast_forward read_only for
			select	distinct
					branch_code
					,branch_name
			from	dbo.GPS_REALIZATION_SUBCRIBE
			where	REALIZATION_NO = @p_code ;
			
			OPEN curr_branch
			
			FETCH NEXT FROM curr_branch 
			INTO @branch_code_asset
				,@branch_name_asset
			
			WHILE @@fetch_status = 0
			BEGIN
			    EXEC dbo.xsp_efam_interface_journal_gl_link_transaction_insert @p_code						= @journal_code OUTPUT
																			  ,@p_company_code				= 'DSF'
																			  ,@p_branch_code				= @branch_code_asset
																			  ,@p_branch_name				= @branch_name_asset
																			  ,@p_transaction_status		= 'HOLD'
																			  ,@p_transaction_date			= @system_date--@journal_date
																			  ,@p_transaction_value_date	= @invoice_date--@journal_date
																			  ,@p_transaction_code			= @p_code
																			  ,@p_transaction_name			= 'REALIZATION SUBCRIPTION GPS'
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
				select  mt.sp_name
 						,mtp.debet_or_credit
 						,mtp.transaction_code
 						,mt.transaction_name
 						,mtp.gl_link_code
 						,grs.fa_code
 						,grs.invoice_amout
 						,ags.vendor_code
 						,ags.vendor_name
 						,ass.contractor_address
 						,grs.faktur_no
 						,grs.faktur_date
 						,isnull(grs.branch_code,'2001')
 						,isnull(grs.branch_name,'jakarta central')
 						,ass.agreement_external_no
 						,ags.vendor_npwp
						,ags.vendor_nitku
						,ags.vendor_npwp_pusat
 				from	dbo.master_transaction_parameter mtp 
 						inner join dbo.sys_general_subcode sgs on (sgs.code = mtp.process_code)
 						inner join dbo.master_transaction mt on (mt.code = mtp.transaction_code)
 						inner join dbo.gps_realization_subcribe grs on (grs.realization_no = @p_code)
 						inner join dbo.asset_gps_schedule ags on (ags.fa_code = grs.fa_code)
						inner join dbo.asset ass on (ass.code = grs.fa_code)
 				where	mtp.process_code = 'REAGPS'
 				and		grs.invoice_no = @invoice_code
				and		grs.branch_code = @branch_code_asset
 			
				open curr_journal
				
				fetch next from curr_journal 
				into @sp_name
 					,@debet_or_credit
 					,@transaction_code
 					,@transaction_name
 					,@gl_link_code 
 					,@fa_code
 					,@total_amount
 					,@vendor_code
 					,@vendor_name
 					,@adress
 					,@faktur_no
 					,@faktur_date
 					,@branch_code_asset
 					,@branch_name_asset
 					,@agreement_external_no
 					,@vendor_npwp
					,@ext_vendor_nitku		
					,@ext_vendor_npwp_pusat
			
				while @@fetch_status = 0
				begin
					-- nilainya exec dari MASTER_TRANSACTION.sp_name
 					exec @return_value = @sp_name @p_code,@invoice_code,@fa_code ; -- sp ini mereturn value angka , kebutuhan sppa ini mengirimkan kode invoice
 					
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

					set @journal_remark = @transaction_name + ' for realization no. ' + @p_code + ' - ' + @fa_code
 					SET @remarks_tax = @remarks_journal
 
 					IF(@transaction_code = 'GPSPPN')
 					BEGIN
 						IF(@return_value > 0)
 						BEGIN
 							SET @pph_type				= 'PPN KELUARAN'
 							SET @income_type			= 'PPN KELUARAN ' + CONVERT(NVARCHAR(10), CAST(ISNULL(11,0) AS INT)) + '%'
 							SET @income_bruto_amount	= @total_amount
 							SET @tax_rate				= ISNULL(11,0)
 							SET @ppn_pph_amount			= @return_value
 						END
 					END
 					ELSE
 					BEGIN
 						SET @income_type			= ''
 						SET @pph_type				= ''
 						SET @vendor_code			= ''
 						SET @vendor_name			= ''
 						SET @vendor_npwp			= ''
 						SET @adress					= ''
 						SET @income_bruto_amount	= 0
 						SET @tax_rate				= 0
 						SET @ppn_pph_amount			= 0
 						SET @remarks_tax			= ''
 						SET @faktur_no				= ''
 						SET @faktur_date			= NULL
 					END

					IF(@transaction_code = 'APSG')
					BEGIN
						SET @journal_remark = @transaction_name + ' for realization no. ' + @p_code + ' .To ' + @insured_name

						IF NOT EXISTS(SELECT 1 FROM dbo.efam_interface_journal_gl_link_transaction_detail WHERE gl_link_transaction_code = @journal_code and gl_link_code = @gl_link_code)
						begin
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
																									  ,@p_exch_rate						= 1
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
																									  --(+) Raffy 2025/02/01 CR NITKU
																									  ,@p_ext_vendor_nitku				= @ext_vendor_nitku
																									  ,@p_ext_vendor_npwp_pusat			= @ext_vendor_npwp_pusat
																									  ,@p_cre_date						= @p_mod_date
																									  ,@p_cre_by						= @p_mod_by
																									  ,@p_cre_ip_address				= @p_mod_ip_address
																									  ,@p_mod_date						= @p_mod_date
																									  ,@p_mod_by						= @p_mod_by
																									  ,@p_mod_ip_address				= @p_mod_ip_address ;
						end
						else
						begin
							update	dbo.efam_interface_journal_gl_link_transaction_detail
							set		orig_amount_db = orig_amount_db + @orig_amount_db
									,orig_amount_cr = orig_amount_cr + @orig_amount_cr
									,base_amount_db = base_amount_db + @orig_amount_db
									,base_amount_cr = base_amount_cr + @orig_amount_cr
							where	gl_link_code				 = @gl_link_code
									and gl_link_transaction_code = @journal_code ;
						end
					end
					else
					begin
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
																									  ,@p_exch_rate						= 1
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
																									  --(+) Raffy 2025/02/01 CR NITKU
																									  ,@p_ext_vendor_nitku				= @ext_vendor_nitku
																									  ,@p_ext_vendor_npwp_pusat			= @ext_vendor_npwp_pusat
																									  ,@p_cre_date						= @p_mod_date
																									  ,@p_cre_by						= @p_mod_by
																									  ,@p_cre_ip_address				= @p_mod_ip_address
																									  ,@p_mod_date						= @p_mod_date
																									  ,@p_mod_by						= @p_mod_by
																									  ,@p_mod_ip_address				= @p_mod_ip_address ;
					end
					
				    fetch next from curr_journal 
					into @sp_name
 						,@debet_or_credit
 						,@transaction_code
 						,@transaction_name
 						,@gl_link_code 
 						,@fa_code
 						,@total_amount
 						,@vendor_code
 						,@vendor_name
 						,@adress
 						,@faktur_no
 						,@faktur_date
 						,@branch_code_asset
 						,@branch_name_asset
 						,@agreement_external_no
 						,@vendor_npwp
						,@ext_vendor_nitku		
						,@ext_vendor_npwp_pusat
				end
				
				close curr_journal
				deallocate curr_journal
			
			    fetch next from curr_branch 
				into @branch_code_asset
					,@branch_name_asset
			end
			
			close curr_branch
			deallocate curr_branch

			-- balancing
			begin
				if (
					(
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

 			--insert ke payment request
 			exec dbo.xsp_payment_request_insert @p_code							= @code_payment_request output
 												,@p_branch_code					= @branch_code
 												,@p_branch_name					= @branch_name
 												,@p_payment_branch_code			= @branch_code
 												,@p_payment_branch_name			= @branch_name
 												,@p_payment_source				= 'RALIZATION GPS'
 												,@p_payment_request_date		= @system_date
 												,@p_payment_source_no			= @p_code
 												,@p_payment_status				= 'HOLD'
 												,@p_payment_currency_code		= 'IDR'
 												,@p_payment_amount				= @invoice_amount
 												,@p_payment_to					= @vendor_name
 												,@p_payment_remarks				= @payment_remarks
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
 			
 			declare curr_branch_payment cursor fast_forward read_only for
            select	distinct
					grs.branch_code
					,grs.branch_name
			from	dbo.gps_realization_subcribe grs
			where	grs.realization_no = @p_code ;
 			
 			open curr_branch_payment
 			
 			fetch next from curr_branch_payment 
			into @branch_code_asset
				,@branch_name_asset
 			
 			while @@fetch_status = 0
 			begin
 			    declare curr_payment cursor fast_forward read_only for 
 				select  mt.sp_name
 						,mtp.debet_or_credit
 						,mtp.transaction_code
 						,mt.transaction_name
 						,mtp.gl_link_code
 						,ipa.fa_code
 						,ipm.total_premi_buy_amount - ipm.total_discount_amount
 						,ipm.insurance_code
 						,ipm.insured_name
 						,mid.address
 						,ipm.faktur_no
 						,ipm.faktur_date
 						--,ISNULL(ass.branch_code,'2001')
 						--,ISNULL(ass.branch_name,'Jakarta Central')
 						,ass.agreement_external_no
 						,mi.tax_file_no
 				from	dbo.master_transaction_parameter mtp 
 						inner join dbo.sys_general_subcode sgs on (sgs.code = mtp.process_code)
 						inner join dbo.master_transaction mt on (mt.code = mtp.transaction_code)
 						inner join dbo.insurance_policy_asset ipa on (ipa.policy_code = @p_code)
 						inner join dbo.insurance_policy_main ipm on (ipm.code = @p_code)
 						left join dbo.master_insurance mi on (mi.code = ipm.insurance_code)
 						left join dbo.master_insurance_address mid on (mid.insurance_code = ipm.insurance_code and mid.is_latest = '1')
 						left join dbo.asset ass on (ass.code = ipa.fa_code)
 				where	mtp.process_code = 'REAGPS'
 				and		ipa.invoice_code = @invoice_code
				and ass.branch_code = @branch_code_asset
 
 				open curr_payment
 				
 				fetch next from curr_payment 
 				into @sp_name
 					,@debet_or_credit
 					,@transaction_code
 					,@transaction_name
 					,@gl_link_code 
 					,@fa_code
 					,@total_amount
 					,@vendor_code
 					,@vendor_name
 					,@adress
 					,@faktur_no
 					,@faktur_date
 					--,@branch_code_asset
 					--,@branch_name_asset
 					,@agreement_external_no
 					,@vendor_npwp
 			
 				while @@fetch_status = 0
 				begin
 			   		-- nilainya exec dari MASTER_TRANSACTION.sp_name
 					exec @return_value = @sp_name @p_code,@invoice_code,@fa_code ; -- sp ini mereturn value angka , kebutuhan sppa ini mengirimkan kode invoice
 					 
 					if @debet_or_credit = 'CREDIT'
 					begin
 						set @orig_amount = @return_value * -1
 					end
 					else
 					begin
 						set @orig_amount = @return_value
 					end
 
 					set @remarks_journal = @transaction_name + ' for realization no. ' + @policy_no + ': ' + format (@orig_amount, '#,###.00', 'DE-de') + ' To ' + @insured_name
 					set @remarks_tax = @remarks_journal
 
 					IF(@transaction_code = 'GPSPPN')
 					begin
 						if(@return_value > 0)
 						begin
 							set @pph_type				= 'PPN KELUARAN'
 							set @income_type			= 'PPN KELUARAN ' + convert(nvarchar(10), cast(isnull(11,0) as int)) + '%'
 							set @income_bruto_amount	= @total_amount
 							set @tax_rate				= isnull(11,0)
 							set @ppn_pph_amount			= @return_value
 						end
 					end
 					--else if(@transaction_code = 'PREMIPPH') -- (+) Ari 2023-12-28 ket : comment untuk tidak dikirim ke sl tax, req pak hari sukabumi
 					--begin
 					--	if(@return_value > 0)
 					--	begin
 					--		set @pph_type				= 'PPH PASAL 23'
 					--		set @income_type			= 'JASA PERANTARA/AGEN'
 					--		set @income_bruto_amount	= @total_amount
 					--		set @tax_rate				= isnull(2,0)
 					--		set @ppn_pph_amount			= @return_value
 					--	end
 					--end
 					else
 					begin
 						set @income_type			= ''
 						set @pph_type				= ''
 						set @vendor_code			= ''
 						set @vendor_name			= ''
 						set @vendor_npwp			= ''
 						set @adress					= ''
 						set @income_bruto_amount	= 0
 						set @tax_rate				= 0
 						set @ppn_pph_amount			= 0
 						set @remarks_tax			= ''
 						set @faktur_no				= ''
 						set @faktur_date			= null
 					end
					
 					if(@orig_amount <> 0)
 					begin
 						SET @agreement_fa_code = ISNULL(@agreement_external_no, @fa_code)

						if not exists (select 1 from dbo.payment_request_detail where payment_request_code = @code_payment_request and gl_link_code = @gl_link_code and branch_code = @branch_code_asset)
						begin
 						exec dbo.xsp_payment_request_detail_insert @p_id							= 0
 																   ,@p_payment_request_code			= @code_payment_request
 																   ,@p_branch_code					= @branch_code_asset
 																   ,@p_branch_name					= @branch_name_asset
 																   ,@p_gl_link_code					= @gl_link_code
 																   ,@p_agreement_no					= @agreement_fa_code
 																   ,@p_facility_code				= ''
 																   ,@p_facility_name				= ''
 																   ,@p_purpose_loan_code			= ''
 																   ,@p_purpose_loan_name			= ''
 																   ,@p_purpose_loan_detail_code		= ''
 																   ,@p_purpose_loan_detail_name		= ''
 																   ,@p_orig_currency_code			= 'IDR'
 																   ,@p_exch_rate					= 0
 																   ,@p_orig_amount					= @orig_amount
 																   ,@p_division_code				= ''
 																   ,@p_division_name				= ''
 																   ,@p_department_code				= ''
 																   ,@p_department_name				= ''
 																   ,@p_remarks						= @remarks_journal
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
						else
						begin
							update	dbo.payment_request_detail
							set		orig_amount = orig_amount + @orig_amount
							where	payment_request_code = @code_payment_request
									and gl_link_code	 = @gl_link_code
									and branch_code = @branch_code_asset
						end
 					end
 			
 					fetch next from curr_payment 
 					into @sp_name
 						,@debet_or_credit
 						,@transaction_code
 						,@transaction_name
 						,@gl_link_code 
 						,@fa_code
 						,@total_amount
 						,@vendor_code
 						,@vendor_name
 						,@adress
 						,@faktur_no
 						,@faktur_date
 						--,@branch_name_asset
 						--,@branch_name_asset
 						,@agreement_external_no
 						,@vendor_npwp
 				end
 				
 				close curr_payment
 				deallocate curr_payment
 			
 			    fetch next from curr_branch_payment 
				into @branch_code_asset
					,@branch_name_asset
 			end
 			
 			close curr_branch_payment
 			deallocate curr_branch_payment

			select @payment_amount  = isnull(sum(payment_amount),0)
 			from dbo.payment_request 
 			where code = @code_payment_request
 
 			select @orig_amount	= isnull(sum(orig_amount),0) 
 			from dbo.payment_request_detail
 			where payment_request_code = @code_payment_request
 			
 			--+ validasi : total detail =  payment_amount yang di header
 			if (@payment_amount <> @orig_amount)
 			begin
 				set @msg = 'Amount does not balance';
     			raiserror(@msg, 16, -1) ;
 			end
			
			--Update & Insert to asset gps schedule
			SELECT TOP 1	
							@id_asset_schedule				= id
							,@invoice_code					= grs.INVOICE_NO
							,@installment_no				= ags.installment_no
							,@fa_code						= ags.fa_code
							,@subcribe_amount_month			= ags.subcribe_amount_month
							,@payment_date_asset_schedule	= ags.periode
							,@paid_date						= ags.due_date
							,@next_billing					= ags.next_billing_date
							,@status_asset_schedule			= ags.status
			from	dbo.ASSET_GPS_SCHEDULE ags
					inner JOIN dbo.GPS_REALIZATION_SUBCRIBE grs ON grs.FA_CODE = ags.FA_CODE
			where	ags.FA_CODE = @fa_code ORDER BY ags.NEXT_BILLING_DATE desc
			
			UPDATE dbo.ASSET_GPS_SCHEDULE
			SET		STATUS = 'PAID'
					--
 					,mod_date		= @p_mod_date		
 					,mod_by			= @p_mod_by			
 					,mod_ip_address	= @p_mod_ip_address
 			where	id	= @id_asset_schedule

			-- Update Status realization 
 			update	dbo.gps_realization_subcribe  
 			set		STATUS	= 'ON PROCESS'
 					--
 					,mod_date		= @p_mod_date		
 					,mod_by			= @p_mod_by			
 					,mod_ip_address	= @p_mod_ip_address
 			where	REALIZATION_NO	= @p_code
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
