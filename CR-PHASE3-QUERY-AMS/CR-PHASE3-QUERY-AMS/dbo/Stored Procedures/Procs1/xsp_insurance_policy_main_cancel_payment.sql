/*
	alterd : Nia, 27 Mei 2020
*/
CREATE PROCEDURE dbo.xsp_insurance_policy_main_cancel_payment
(
	@p_code			   nvarchar(50)
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
	declare @msg							nvarchar(max)
			,@payment_request_code			nvarchar(50)
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
			,@journal_date					datetime	 = dbo.xfn_get_system_date()
			,@source_name					nvarchar(250)
			,@journal_remark				nvarchar(4000)
			,@orig_amount_db				decimal(18,2)
			,@orig_amount_cr				decimal(18,2)
			,@sp_name						nvarchar(250)
 			,@debet_or_credit				nvarchar(10)
 			,@orig_amount					decimal(18, 2)
 			,@payment_amount				decimal(18, 2)
 			,@gl_link_code					nvarchar(50)
 			,@currency						nvarchar(3)
 			,@return_value					decimal(18, 2)
			,@invoice_code					nvarchar(50)
			,@fa_code						nvarchar(50)
			,@total_amount					decimal(18, 2)
			,@prepaid_no					nvarchar(50)
			,@invoice_date					datetime
			,@insurance_asset_code			nvarchar(50)

	begin try
		select	@fa_code			= ipa.fa_code
				,@branch_code_asset = ass.branch_code
				,@branch_name_asset = ass.branch_name
				,@policy_no			= ipm.policy_no
				,@invoice_code		= ipm.invoice_no
				,@faktur_no			= ipm.faktur_no
				,@faktur_date		= ipm.faktur_date
				,@insured_name		= ipm.insured_name
				,@invoice_date		= ipm.invoice_date
		from	dbo.insurance_policy_main			  ipm
				inner join dbo.insurance_policy_asset ipa on ipa.policy_code = ipm.code
				inner join dbo.asset				  ass on ass.code		 = ipa.fa_code
				inner join dbo.asset_vehicle		  avh on avh.asset_code	 = ass.code
		where	ipm.code = @p_code ;


		
		declare cursor_name cursor fast_forward read_only for
		select	code
				,fa_code 
		from dbo.insurance_policy_asset
		where policy_code = @p_code

		open cursor_name
		
		fetch next from cursor_name 
		into @insurance_asset_code
			,@fa_code
		
		while @@fetch_status = 0
		begin
		    if exists
			(
				select	1
				from	dbo.asset_prepaid_main				  apm
						inner join dbo.asset_prepaid_schedule aps on aps.prepaid_no = apm.prepaid_no
				where	apm.fa_code							 = @fa_code
						and apm.reff_no						 = @insurance_asset_code
						and isnull(aps.accrue_reff_code, '') <> ''
			)
			begin
				set @msg = N'Cannot cancel this data because prepaid already accrued.' ;

				raiserror(@msg, 16, -1) ;
			end
			else
			begin
				select	@prepaid_no = prepaid_no
				from	dbo.asset_prepaid_main
				where	fa_code = @fa_code
				and reff_no = @insurance_asset_code

				delete	dbo.asset_prepaid_schedule
				where	prepaid_no = @prepaid_no ;

				delete	dbo.asset_prepaid_main
				where	prepaid_no = @prepaid_no ;
			end
		
		    fetch next from cursor_name 
			into @insurance_asset_code
				,@fa_code
		end
		
		close cursor_name
		deallocate cursor_name


		if exists
		(
			select	1
			from	dbo.insurance_policy_main
			where	code					  = @p_code
					and policy_payment_status = 'ON PROCESS'
		)
		begin
			if exists (select 1 from dbo.efam_interface_journal_gl_link_transaction where transaction_name = 'INSURANCE' and reff_source_no = @p_code)
			begin
				if exists
				(
					select	1
					from	dbo.payment_request
					where	payment_source_no  = @p_code
							and payment_status = 'HOLD'
				)
				begin
				set @source_name = N'Reverse insurance Policy for ' + @policy_no ;

			
				declare curr_branch cursor fast_forward read_only for
				select	distinct
						ass.branch_code
						,ass.branch_name
				from	dbo.insurance_policy_asset ipa
						inner join dbo.asset	   ass on ass.code = ipa.fa_code
				where	ipa.policy_code = @p_code ;
				
				open curr_branch
				
				fetch next from curr_branch 
				into @branch_code_asset
					,@branch_name_asset
			
				while @@fetch_status = 0
				begin
				    exec dbo.xsp_efam_interface_journal_gl_link_transaction_insert @p_code						= @journal_code output
																				  ,@p_company_code				= 'DSF'
																				  ,@p_branch_code				= @branch_code_asset
																				  ,@p_branch_name				= @branch_name_asset
																				  ,@p_transaction_status		= 'HOLD'
																				  ,@p_transaction_date			= @journal_date
																				  ,@p_transaction_value_date	= @invoice_date --@journal_date
																				  ,@p_transaction_code			= @p_code
																				  ,@p_transaction_name			= 'REVERSE INSURANCE'
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
							,isnull(ass.branch_code, '2001')
							,isnull(ass.branch_name, 'Jakarta Central')
							,ass.agreement_external_no
							,mi.tax_file_no
					from	dbo.master_transaction_parameter	   mtp
							inner join dbo.sys_general_subcode	   sgs on (sgs.code				 = mtp.process_code)
							inner join dbo.master_transaction	   mt on (mt.code				 = mtp.transaction_code)
							inner join dbo.insurance_policy_asset  ipa on (ipa.policy_code		 = @p_code)
							inner join dbo.insurance_policy_main   ipm on (ipm.code				 = @p_code)
							left join dbo.master_insurance		   mi on (mi.code				 = ipm.insurance_code)
							left join dbo.master_insurance_address mid on (
																			  mid.insurance_code = ipm.insurance_code
																			  and  mid.is_latest = '1'
																		  )
							left join dbo.asset					   ass on (ass.code				 = ipa.fa_code)
					where	mtp.process_code	 = 'INFA'
							and ipa.invoice_code = @invoice_code
							and ass.branch_code	 = @branch_code_asset ;
 				
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
				
					while @@fetch_status = 0
					begin
						-- nilainya exec dari MASTER_TRANSACTION.sp_name
 						exec @return_value = @sp_name @p_code,@invoice_code,@fa_code ; -- sp ini mereturn value angka , kebutuhan sppa ini mengirimkan kode invoice
 						 
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

						set @journal_remark = @transaction_name + ' for policy no. ' + @policy_no + ' - ' + @fa_code + ' To ' + @insured_name
 						set @remarks_tax = @remarks_journal
 
 						IF(@transaction_code = 'PREMIPPN')
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

						if(@transaction_code = 'APSI')
						begin
							set @journal_remark = @transaction_name + ' for policy no. ' + @policy_no + ' .To ' + @insured_name

							if not exists(select 1 from dbo.efam_interface_journal_gl_link_transaction_detail where gl_link_transaction_code = @journal_code and gl_link_code = @gl_link_code)
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
			end
				else
				begin
					set @msg = N'Data already proceed.' ;

					raiserror(@msg, 16, -1) ;
				end
			end
			
			update	dbo.insurance_policy_main
			set		policy_payment_status	= 'HOLD'
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	code = @p_code ;


			update	dbo.payment_request
			set		payment_status		= 'CANCEL'
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	payment_source_no	= @p_code ;
		end ;
		else
		begin
			set @msg = N'Data already proceed.' ;

			raiserror(@msg, 16, -1) ;
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
