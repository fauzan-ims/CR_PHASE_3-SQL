CREATE PROCEDURE dbo.xsp_register_main_realization_cancel
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg								nvarchar(max)
			,@regis_status						nvarchar(20)
			,@customer_settlement_amount		decimal(18, 2)
			,@public_service_settlement_amount	decimal(18, 2)
			,@interface_status					nvarchar(20)
			,@fa_code							nvarchar(50)
			,@payment_status					nvarchar(50)
			,@invoice_status					nvarchar(50)
			,@source_name						nvarchar(250)
			,@plat_no							nvarchar(50)
			,@journal_code						nvarchar(50)
			,@journal_date						datetime		= dbo.xfn_get_system_date()
			,@journal_remark					nvarchar(4000)
			,@branch_code_asset					nvarchar(50)
			,@branch_name_asset					nvarchar(250)
			,@sp_name							nvarchar(250)
			,@debet_or_credit					nvarchar(10)
			,@gl_link_code						nvarchar(50)
			,@transaction_name					nvarchar(250)
			,@orig_amount_cr					decimal(18, 2)
			,@orig_amount_db					decimal(18, 2)
			,@amount							decimal(18, 2)
			,@return_value						decimal(18, 2)
			,@vendor_code						nvarchar(50)
			,@vendor_name						nvarchar(250)
			,@vendor_npwp						nvarchar(15)
			,@adress							nvarchar(4000)
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
			,@transaction_code					nvarchar(50)
			,@public_service_name 				nvarchar(250)
			,@is_taxable						nvarchar(1)
			,@faktur_date						datetime
			,@faktur_no							nvarchar(50)
			,@tax_file_type                     nvarchar(10)
			,@service_fee						decimal(18,2)
			,@agreement_external_no				nvarchar(50)
			,@agreement_no						nvarchar(50)
			,@is_reimburse						nvarchar(1)
			,@prepaid_no						nvarchar(50)
			,@invoice_date						datetime

	begin try
		select	 @regis_status					   = register_status
				,@public_service_settlement_amount = public_service_settlement_amount
				,@fa_code						   = fa_code
				,@branch_code_asset				   = ass.branch_code
				,@branch_name_asset				   = ass.branch_name
				,@plat_no						   = avh.plat_no
				,@faktur_no						   = rm.faktur_no
				,@faktur_date					   = rm.faktur_date
				,@agreement_no					   = ass.agreement_external_no
				,@is_reimburse					   = rm.is_reimburse_to_customer
				,@public_service_name			   = mps.public_service_name
				,@invoice_date					   = rm.realization_invoic_date
		from	dbo.register_main					rm
				inner join dbo.asset				ass on ass.code		  = rm.fa_code
				inner join dbo.asset_vehicle		avh on avh.asset_code = ass.code
				inner join dbo.order_main			om on om.code collate Latin1_General_CI_AS		  = rm.order_code
				left join dbo.master_public_service mps on mps.code		  = om.public_service_code
		where	rm.code = @p_code ;

		if exists
		(
			select	1
			from	dbo.asset_prepaid_main				  apm
					inner join dbo.asset_prepaid_schedule aps on aps.prepaid_no = apm.prepaid_no
			where	apm.fa_code							 = @fa_code
					and apm.reff_no = @p_code
					and isnull(aps.accrue_reff_code, '') <> ''
		)
		begin
			set @msg = N'Cannot cancel this transaction because already accrued.' ;

			raiserror(@msg, 16, -1) ;
		end
		else
		begin
			select	@prepaid_no = prepaid_no
			from	dbo.asset_prepaid_main
			where	fa_code = @fa_code ;

			delete	dbo.asset_prepaid_schedule
			where	prepaid_no = @prepaid_no ;

			delete	dbo.asset_prepaid_main
			where	prepaid_no = @prepaid_no
					and fa_code = @fa_code ;
		end


		set @agreement_external_no = isnull(@agreement_no, @fa_code);

		select		top 1
					@payment_status = payment_status
		from		dbo.payment_request
		where		payment_source_no = @p_code
		order by	cre_date desc ;

		select		top 1
					@invoice_status = status
		from		ifinopl.dbo.additional_invoice_request
		where		reff_code = @p_code
		order by	cre_date desc ;

		if(@is_reimburse = '1')
		begin
			if exists(select 1 from dbo.efam_interface_journal_gl_link_transaction where reff_source_name = 'PUBLIC SERVICE REALIZATION' and reff_source_no = @p_code)
			begin
				if(@payment_status = 'HOLD' and @invoice_status = 'CANCEL')
				begin
				set @source_name = 'Reverse realization public service for ' + @plat_no
				exec dbo.xsp_efam_interface_journal_gl_link_transaction_insert @p_code						= @journal_code output
																			  ,@p_company_code				= 'DSF'
																			  ,@p_branch_code				= @branch_code_asset
																			  ,@p_branch_name				= @branch_name_asset
																			  ,@p_transaction_status		= 'HOLD'
																			  ,@p_transaction_date			= @journal_date
																			  ,@p_transaction_value_date	= @invoice_date --@journal_date
																			  ,@p_transaction_code			= @p_code
																			  ,@p_transaction_name			= 'REVERSE REALIZATION ASSET'
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
						,isnull(rm.faktur_no, rm.realization_invoice_no)
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
							--set @orig_amount_cr = 0 ;
							--set @orig_amount_db = @return_value ;
							set @orig_amount_cr = @return_value ;
							set @orig_amount_db = 0 ;
						end ;
						else
						begin
							--set @orig_amount_cr = abs(@return_value) ;
							--set @orig_amount_db = 0 ;
							set @orig_amount_cr = 0 ;
							set @orig_amount_db = abs(@return_value) ;
						end ;
					end ;

					set @journal_remark = @transaction_name + ', ' + format (@orig_amount_db, '#,###.00', 'DE-de') +  ' for ' + @public_service_name
					set @remarks_tax =  @journal_remark

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

				update	dbo.payment_request
				set		payment_status		= 'CANCEL'
				where	payment_source_no	= @p_code ;

				update	dbo.register_main
				set		payment_status		= 'HOLD'
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	code = @p_code ;

				delete	from dbo.asset_expense_ledger
				where	asset_code	  = @fa_code
						and reff_code = @p_code ;
			end
				else
				begin
					set @msg = 'Data already proceed.';
					raiserror(@msg ,16,-1);
				end
			end
		end
		else
		begin
			if exists(select 1 from dbo.efam_interface_journal_gl_link_transaction where transaction_name = 'REALIZATION ASSET' and reff_source_no = @p_code)
			begin
				if(@payment_status = 'HOLD')
				begin
					set @source_name = 'Reverse realization public service for ' + @plat_no
					exec dbo.xsp_efam_interface_journal_gl_link_transaction_insert @p_code						= @journal_code output
																				  ,@p_company_code				= 'DSF'
																				  ,@p_branch_code				= @branch_code_asset
																				  ,@p_branch_name				= @branch_name_asset
																				  ,@p_transaction_status		= 'HOLD'
																				  ,@p_transaction_date			= @journal_date
																				  ,@p_transaction_value_date	= @invoice_date
																				  ,@p_transaction_code			= @p_code
																				  ,@p_transaction_name			= 'REVERSE REALIZATION ASSET'
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
							,isnull(rm.faktur_no, rm.realization_invoice_no)
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
							--set @orig_amount_cr = 0 ;
							--set @orig_amount_db = @return_value ;
							set @orig_amount_cr = @return_value ;
							set @orig_amount_db = 0 ;
						end ;
						else
						begin
							--set @orig_amount_cr = abs(@return_value) ;
							--set @orig_amount_db = 0 ;
							set @orig_amount_cr = 0 ;
							set @orig_amount_db = abs(@return_value) ;
						end ;
					end ;

					set @journal_remark = @transaction_name + ', ' + format (@orig_amount_db, '#,###.00', 'DE-de') +  ' for ' + @public_service_name
					set @remarks_tax =  @journal_remark

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

				update	dbo.payment_request
				set		payment_status		= 'CANCEL'
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	payment_source_no	= @p_code ;

				update	dbo.register_main
				set		payment_status		= 'HOLD'
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	code = @p_code ;

				delete	from dbo.asset_expense_ledger
				where	asset_code	  = @fa_code
						and reff_code = @p_code ;
			end
				else
				begin
					set @msg = 'Data already proceed.';
					raiserror(@msg ,16,-1);
				end
			end
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
			set @msg = N'V' + N';' + @msg ;
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
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
