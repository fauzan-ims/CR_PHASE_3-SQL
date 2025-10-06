-- Louis Senin, 13 Februari 2023 20.07.50 -- 
 CREATE PROCEDURE dbo.xsp_insurance_policy_main_post_payment
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
 			,@total_premi_buy_amount		DECIMAL(18, 2)
 			,@bank_name						NVARCHAR(250)
 			,@bank_account_no				NVARCHAR(50)
 			,@bank_account_name				NVARCHAR(250)
 			,@payment_remarks				NVARCHAR(4000)
 			,@system_date					DATETIME	   = dbo.xfn_get_system_date()
 			,@payment_request_code			NVARCHAR(50)
 			,@fa_code						NVARCHAR(50)
 			,@fa_name						NVARCHAR(250)
 			,@sp_name						NVARCHAR(250)
 			,@debet_or_credit				NVARCHAR(10)
 			,@orig_amount					DECIMAL(18, 2)
 			,@payment_amount				DECIMAL(18, 2)
 			,@gl_link_code					NVARCHAR(50)
 			,@currency						NVARCHAR(3)
 			,@return_value					DECIMAL(18, 2)
 			,@tax_file_type					NVARCHAR(10)
 			,@tax_file_no					NVARCHAR(50)
 			,@max_year						INT
 			,@tax_file_name					NVARCHAR(250)
 			,@policy_eff_date				DATETIME
 			,@policy_exp_date				DATETIME
 			,@year_periode					INT
 			,@period_eff_date				DATETIME
 			,@period_exp_date				DATETIME
 			,@sell_amount					DECIMAL(18, 2)
 			,@initial_discount_amount		DECIMAL(18, 2)
 			,@buy_amount					DECIMAL(18, 2)
 			,@adjustment_discount_amount	DECIMAL(18, 2)
 			,@adjustment_buy_amount			DECIMAL(18, 2)
 			,@total_amount					DECIMAL(18, 2)
 			,@ppn_amount					DECIMAL(18, 2)
 			,@pph_amount					DECIMAL(18, 2)
 			,@total_payment_amount			DECIMAL(18, 2)
 			,@code_payment_request			NVARCHAR(50)
 			,@total_buy_amount				DECIMAL(18,2)
 			,@payment_name					NVARCHAR(50)
 			,@prepaid_no					NVARCHAR(50)
 			,@total_net_premi_amount		DECIMAL(18,2)
 			,@usefull						INT
 			,@monthly_amount				DECIMAL(18,2)
 			,@counter						INT
 			,@sisa							DECIMAL(18,2)
 			,@amount						DECIMAL(18,2)
 			,@date_prepaid					DATETIME
 			,@invoice_code					NVARCHAR(50)
 			,@reff_remark					NVARCHAR(4000)
 			,@date							DATETIME
 			,@agreement_no					NVARCHAR(50)
 			,@client_name					NVARCHAR(250)
 			,@remarks_journal				NVARCHAR(4000)
 			,@transaction_name				NVARCHAR(250)
 			,@policy_no						NVARCHAR(50)
 			,@insured_name					NVARCHAR(250)
 			,@faktur_no						NVARCHAR(50)
 			,@vendor_npwp					NVARCHAR(20)
 			,@income_type					NVARCHAR(250)
 			,@income_bruto_amount			DECIMAL(18,2)
 			,@tax_rate						DECIMAL(5,2)
 			,@ppn_pph_amount				DECIMAL(18,2)
 			,@transaction_code				NVARCHAR(50)
 			,@ppn_pct						DECIMAL(9,6)
 			,@pph_pct						DECIMAL(9,6)
 			,@pph_type						NVARCHAR(20)
 			,@vendor_code					NVARCHAR(50)
 			,@vendor_name					NVARCHAR(250)
 			,@adress						NVARCHAR(4000)
 			,@remarks_tax					NVARCHAR(4000)
 			,@branch_code_asset				NVARCHAR(50)
 			,@branch_name_asset				NVARCHAR(250)
 			,@agreement_external_no			NVARCHAR(50)
 			,@agreement_fa_code				NVARCHAR(50)
 			,@faktur_date					DATETIME
			,@journal_code					NVARCHAR(50)
			,@journal_date					DATETIME
			,@source_name					NVARCHAR(250)
			,@journal_remark				NVARCHAR(4000)
			,@orig_amount_db				DECIMAL(18,2)
			,@orig_amount_cr				DECIMAL(18,2)
			,@value1						int
			,@value2						int
			,@invoice_date					datetime
			,@cre_by						nvarchar(50)
			,@ext_vendor_nitku				nvarchar(50)
			,@ext_vendor_npwp_pusat			nvarchar(50)
 
 		begin try
 		set @date = dbo.xfn_get_system_date()
         
 		select @branch_code					= ipm.branch_code
 			   ,@branch_name				= ipm.branch_name	
 			   ,@insurance_code				= ipm.insurance_code
 			   ,@payment_remarks			= 'Payment Policy insurance ' + isnull(ipm.policy_no, '') + ' To ' + mi.insurance_name  
 			   ,@currency					= ipm.currency_code 											
 			   ,@policy_payment_type		= ipm.policy_payment_type
 			   ,@policy_eff_date			= ipm.policy_eff_date
 			   ,@policy_exp_date			= ipm.policy_exp_date
 			   ,@policy_no					= ipm.policy_no
 			   ,@invoice_code				= ipm.invoice_no
 			   ,@insured_name				= ipm.insured_name
			   ,@faktur_date				= ipm.faktur_date
			   ,@invoice_date				= ipm.invoice_date
			   ,@cre_by						= ipm.cre_by
 		from	dbo.insurance_policy_main ipm
 				inner join dbo.master_insurance mi on (mi.code = ipm.insurance_code)
 		where   ipm.code = @p_code

		select	@value1 = value
		from	dbo.sys_global_param
		where	CODE = 'INSINV' ;

		select	@value2 = value
		from	dbo.sys_global_param
		where	CODE = 'INSINV' ;
        
		if(@cre_by not like '%MIG%')
		begin
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
		end
 
 		-- Hari - 19.Jul.2023 05:08 PM --	perubahan cara ambil amount by invoice no
 		select	@total_premi_buy_amount = isnull(sum(ipac.buy_amount),0)
 		from	dbo.insurance_policy_asset					   ipa
 				inner join dbo.insurance_policy_asset_coverage ipac on ipac.register_asset_code = ipa.code
 		where	policy_code		 = @p_code
 				and invoice_code = @invoice_code 
 				--and	ipac.coverage_type = 'NEW' -- (+) Ari 2024-01-03 ket : hanya yg New yg dibayar
 
 		IF(@total_premi_buy_amount = 0)
 		BEGIN
 			set @msg = 'Premi amount must be greater than 0';
 			raiserror(@msg, 16, -1) ;
         end
 
 	
 		select top 1  @payment_name		  = mis.insurance_name
 					 ,@bank_name           = mib.bank_name
 			         ,@bank_account_no     = mib.bank_account_no
 			         ,@bank_account_name   = mib.bank_account_name
 		from dbo.master_insurance_bank mib
 		inner join dbo.master_insurance mis on mis.code = mib.insurance_code
 		where mib.insurance_code = @insurance_code and mib.is_default = '1' 
 	
 		if (@bank_name is null)
 		begin
 			set @msg = 'Please setting default insurance bank' ;
 			raiserror(@msg, 16, -1) ;
 		end
          
 		select @faktur_no = faktur_no
 		from dbo.insurance_policy_main
 		where code = @p_code

		if exists
		(
			select	1
			from	dbo.insurance_policy_main					   a
					inner join dbo.insurance_policy_asset		   b on b.policy_code		  = a.code
					inner join dbo.insurance_policy_asset_coverage c on c.register_asset_code = b.code
			where	a.code							  = @p_code
					and isnull(c.master_tax_code, '') = ''
		)
		begin
			set @msg = N'Please input tax in coverage first.' ;

			raiserror(@msg, 16, -1) ;
		end ;
 		
 		--validasi untuk faktur number agar tidak bisa kosong jika pph amount ada nilainya 
 		if (ISNULL(@faktur_no,'') = '') AND (@pph_amount > 0)
 		begin
 			set @msg = 'Faktur Number cant be empty.';
 			raiserror(@msg ,16,-1);
 		end
 
 		-- (+) Ari 2024-01-03 ket : validasi invoice tidak boleh kosong
 		if(isnull(@invoice_code,'') = '')
 		begin
 			set @msg = 'Invoice Number cant be empty.';
 			raiserror(@msg ,16,-1);
 		end	
        
 		--if exists (select 1 from dbo.insurance_policy_main 
 		--			where code = @p_code 
 		--			and (isnull(policy_no,'') = '' 
 		--			or  isnull(invoice_no,'') = '' 
 		--			or  invoice_date = NULL)
 		--		)
 		--begin
 		--	set @msg = 'Please input Policy No, Invoice No and Invoice Date' ;
 		--	raiserror(@msg, 16, -1) ;
 		--end
 		 
 		select @tax_file_type = tax_file_type
 			   ,@tax_file_no   = tax_file_no
 			   ,@tax_file_name = tax_file_name
 		from dbo.master_insurance
 		where code = @insurance_code 
 
 		if exists (select 1 from dbo.insurance_policy_main where code = @p_code AND policy_payment_status = 'ON PROCESS')
 		begin
 			--exec dbo.xsp_insurance_policy_main_journal @p_reff_name			= N'POLICY REGISTER'
 			--										   ,@p_reff_code		= @p_code
 			--										   ,@p_value_date		= @p_mod_date
 			--										   --
 			--										   ,@p_trx_date			= @p_mod_date
 			--										   ,@p_mod_date			= @p_mod_date		
 			--										   ,@p_mod_by			= @p_mod_by			
 			--										   ,@p_mod_ip_address	= @p_mod_ip_address
 			
 			--journal cash basis
			--(+) Raffy 2025-03-11 Update dipindahkan agar tidak ada double proses 
			update	dbo.insurance_policy_main  
 			set		policy_payment_status	= 'APPROVE'
 					--
 					,mod_date		= @p_mod_date		
 					,mod_by			= @p_mod_by			
 					,mod_ip_address	= @p_mod_ip_address
 			where	code			= @p_code
			--(+) Raffy 2025-03-11 Update dipindahkan agar tidak ada double proses 

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
			set @source_name = N'Insurance Policy for ' + @policy_no ;

			
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
			BEGIN
			    exec dbo.xsp_efam_interface_journal_gl_link_transaction_insert @p_code						= @journal_code output
																			  ,@p_company_code				= 'DSF'
																			  ,@p_branch_code				= @branch_code_asset
																			  ,@p_branch_name				= @branch_name_asset
																			  ,@p_transaction_status		= 'HOLD'
																			  ,@p_transaction_date			= @system_date--@journal_date
																			  ,@p_transaction_value_date	= @invoice_date--@journal_date
																			  ,@p_transaction_code			= @p_code
																			  ,@p_transaction_name			= 'INSURANCE'
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
 						,ipa.fa_code
 						,ipm.total_premi_buy_amount - ipm.total_discount_amount
 						,ipm.insurance_code
 						,ipm.insured_name
 						,mid.address
 						,ipm.faktur_no
 						,ipm.faktur_date
 						,ISNULL(ass.branch_code,'2001')
 						,ISNULL(ass.branch_name,'Jakarta Central')
 						,ass.agreement_external_no
 						,mi.tax_file_no
						--(+) Raffy 2025/02/01 CR NITKU
						,mi.nitku
						,mi.npwp_ho
 				from	dbo.master_transaction_parameter mtp 
 						inner join dbo.sys_general_subcode sgs on (sgs.code = mtp.process_code)
 						inner join dbo.master_transaction mt on (mt.code = mtp.transaction_code)
 						inner join dbo.insurance_policy_asset ipa on (ipa.policy_code = @p_code)
 						inner join dbo.insurance_policy_main ipm on (ipm.code = @p_code)
 						left join dbo.master_insurance mi on (mi.code = ipm.insurance_code)
 						left join dbo.master_insurance_address mid on (mid.insurance_code = ipm.insurance_code and mid.is_latest = '1')
 						left join dbo.asset ass on (ass.code = ipa.fa_code)
 				where	mtp.process_code = 'INFA'
 				and		ipa.invoice_code = @invoice_code
				and		ass.branch_code = @branch_code_asset
 			
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
						BEGIN
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
					BEGIN
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
 
 		--	select	@branch_code  = value
			--		,@branch_name = description
			--from	dbo.sys_global_param
			--where	code = 'HO' ;
		
 
 			--insert ke payment request
 			exec dbo.xsp_payment_request_insert @p_code							= @code_payment_request output
 												,@p_branch_code					= @branch_code
 												,@p_branch_name					= @branch_name
 												,@p_payment_branch_code			= @branch_code
 												,@p_payment_branch_name			= @branch_name
 												,@p_payment_source				= 'POLICY'
 												,@p_payment_request_date		= @system_date
 												,@p_payment_source_no			= @p_code
 												,@p_payment_status				= 'HOLD'
 												,@p_payment_currency_code		= 'IDR'
 												,@p_payment_amount				= @total_premi_buy_amount
 												,@p_payment_to					= @payment_name
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
					ass.branch_code
					,ass.branch_name
			from	dbo.insurance_policy_asset ipa
					inner join dbo.asset	   ass on ass.code = ipa.fa_code
			where	ipa.policy_code = @p_code ;
 			
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
 				where	mtp.process_code = 'PMINS'--'INSPRO1'
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
 
 					set @remarks_journal = @transaction_name + ' for policy no. ' + @policy_no + ': ' + format (@orig_amount, '#,###.00', 'DE-de') + ' To ' + @insured_name
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
					
 					if(@orig_amount <> 0)
 					begin
 						SET @agreement_fa_code = ISNULL(@agreement_external_no, @fa_code)

						if not exists (select 1 from dbo.payment_request_detail where payment_request_code = @code_payment_request and gl_link_code = @gl_link_code and branch_code = @branch_code_asset)
						BEGIN
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


 			--declare curr_payment cursor fast_forward read_only for 
 			--select  mt.sp_name
 			--		,mtp.debet_or_credit
 			--		,mtp.transaction_code
 			--		,mt.transaction_name
 			--		,mtp.gl_link_code
 			--		,ipa.fa_code
 			--		,ipm.total_premi_buy_amount - ipm.total_discount_amount
 			--		,ipm.insurance_code
 			--		,ipm.insured_name
 			--		,mid.address
 			--		,ipm.faktur_no
 			--		,ipm.faktur_date
 			--		,ISNULL(ass.branch_code,'2001')
 			--		,ISNULL(ass.branch_name,'Jakarta Central')
 			--		,ass.agreement_external_no
 			--		,mi.tax_file_no
 			--from	dbo.master_transaction_parameter mtp 
 			--		inner join dbo.sys_general_subcode sgs on (sgs.code = mtp.process_code)
 			--		inner join dbo.master_transaction mt on (mt.code = mtp.transaction_code)
 			--		inner join dbo.insurance_policy_asset ipa on (ipa.policy_code = @p_code)
 			--		inner join dbo.insurance_policy_main ipm on (ipm.code = @p_code)
 			--		left join dbo.master_insurance mi on (mi.code = ipm.insurance_code)
 			--		left join dbo.master_insurance_address mid on (mid.insurance_code = ipm.insurance_code and mid.is_latest = '1')
 			--		left join dbo.asset ass on (ass.code = ipa.fa_code)
 			--where	mtp.process_code = 'PMINS'--'INSPRO1'
 			--and		ipa.invoice_code = @invoice_code
 
 			--open curr_payment
 			
 			--fetch next from curr_payment 
 			--into @sp_name
 			--	,@debet_or_credit
 			--	,@transaction_code
 			--	,@transaction_name
 			--	,@gl_link_code 
 			--	,@fa_code
 			--	,@total_amount
 			--	,@vendor_code
 			--	,@vendor_name
 			--	,@adress
 			--	,@faktur_no
 			--	,@faktur_date
 			--	,@branch_code_asset
 			--	,@branch_name_asset
 			--	,@agreement_external_no
 			--	,@vendor_npwp
 			
 			--while @@fetch_status = 0
 			--begin
 			--   	-- nilainya exec dari MASTER_TRANSACTION.sp_name
 			--	exec @return_value = @sp_name @p_code,@invoice_code,@fa_code ; -- sp ini mereturn value angka , kebutuhan sppa ini mengirimkan kode invoice
 				 
 			--	if @debet_or_credit = 'CREDIT'
 			--	begin
 			--		set @orig_amount = @return_value * -1
 			--	end
 			--	else
 			--	begin
 			--		set @orig_amount = @return_value
 			--	end
 
 			--	set @remarks_journal = @transaction_name + ' for policy no. ' + @policy_no + ': ' + format (@orig_amount, '#,###.00', 'DE-de') + ' To ' + @insured_name
 			--	set @remarks_tax = @remarks_journal
 
 			--		IF(@transaction_code = 'PREMIPPN')
 			--		begin
 			--			if(@return_value > 0)
 			--			begin
 			--				set @pph_type				= 'PPN KELUARAN'
 			--				set @income_type			= 'PPN KELUARAN ' + convert(nvarchar(10), cast(isnull(11,0) as int)) + '%'
 			--				set @income_bruto_amount	= @total_amount
 			--				set @tax_rate				= isnull(11,0)
 			--				set @ppn_pph_amount			= @return_value
 			--			end
 			--		end
 			--		--else if(@transaction_code = 'PREMIPPH') -- (+) Ari 2023-12-28 ket : comment untuk tidak dikirim ke sl tax, req pak hari sukabumi
 			--		--begin
 			--		--	if(@return_value > 0)
 			--		--	begin
 			--		--		set @pph_type				= 'PPH PASAL 23'
 			--		--		set @income_type			= 'JASA PERANTARA/AGEN'
 			--		--		set @income_bruto_amount	= @total_amount
 			--		--		set @tax_rate				= isnull(2,0)
 			--		--		set @ppn_pph_amount			= @return_value
 			--		--	end
 			--		--end
 			--		else
 			--		begin
 			--			set @income_type			= ''
 			--			set @pph_type				= ''
 			--			set @vendor_code			= ''
 			--			set @vendor_name			= ''
 			--			set @vendor_npwp			= ''
 			--			set @adress					= ''
 			--			set @income_bruto_amount	= 0
 			--			set @tax_rate				= 0
 			--			set @ppn_pph_amount			= 0
 			--			set @remarks_tax			= ''
 			--			set @faktur_no				= ''
 			--			set @faktur_date			= null
 			--		end
 
 			--	if(@orig_amount <> 0)
 			--	begin
 			--		SET @agreement_fa_code = ISNULL(@agreement_external_no, @fa_code)

				--	if not exists (select 1 from dbo.payment_request_detail where payment_request_code = @code_payment_request and gl_link_code = @gl_link_code)
				--	begin
 			--			exec dbo.xsp_payment_request_detail_insert @p_id							= 0
 			--													   ,@p_payment_request_code			= @code_payment_request
 			--													   ,@p_branch_code					= @branch_code_asset
 			--													   ,@p_branch_name					= @branch_name_asset
 			--													   ,@p_gl_link_code					= @gl_link_code
 			--													   ,@p_agreement_no					= @agreement_fa_code
 			--													   ,@p_facility_code				= ''
 			--													   ,@p_facility_name				= ''
 			--													   ,@p_purpose_loan_code			= ''
 			--													   ,@p_purpose_loan_name			= ''
 			--													   ,@p_purpose_loan_detail_code		= ''
 			--													   ,@p_purpose_loan_detail_name		= ''
 			--													   ,@p_orig_currency_code			= 'IDR'
 			--													   ,@p_exch_rate					= 0
 			--													   ,@p_orig_amount					= @orig_amount
 			--													   ,@p_division_code				= ''
 			--													   ,@p_division_name				= ''
 			--													   ,@p_department_code				= ''
 			--													   ,@p_department_name				= ''
 			--													   ,@p_remarks						= @remarks_journal
 			--													   ,@p_is_taxable					= '0'
 			--													   ,@p_tax_amount					= 0
 			--													   ,@p_tax_pct						= 0
 			--													   ,@p_ext_pph_type					= @pph_type
 			--													   ,@p_ext_vendor_code				= @vendor_code
 			--													   ,@p_ext_vendor_name				= @vendor_name
 			--													   ,@p_ext_vendor_npwp				= @vendor_npwp
 			--													   ,@p_ext_vendor_address			= @adress
 			--													   ,@p_ext_income_type				= @income_type
 			--													   ,@p_ext_income_bruto_amount		= @income_bruto_amount
 			--													   ,@p_ext_tax_rate_pct				= @tax_rate
 			--													   ,@p_ext_pph_amount				= @ppn_pph_amount
 			--													   ,@p_ext_description				= @remarks_tax
 			--													   ,@p_ext_tax_number				= @faktur_no
 			--													   ,@p_ext_tax_date					= @faktur_date
 			--													   ,@p_ext_sale_type				= ''
 			--													   ,@p_cre_date						= @p_mod_date	  
 			--													   ,@p_cre_by						= @p_mod_by		
 			--													   ,@p_cre_ip_address				= @p_mod_ip_address
 			--													   ,@p_mod_date						= @p_mod_date	  
 			--													   ,@p_mod_by						= @p_mod_by		
 			--													   ,@p_mod_ip_address				= @p_mod_ip_address
				--	end
				--	else
				--	begin
				--		update	dbo.payment_request_detail
				--		set		orig_amount = orig_amount + @orig_amount
				--		where	payment_request_code = @code_payment_request
				--				and gl_link_code	 = @gl_link_code ;
				--	end
 			--	end
 			
 			--    fetch next from curr_payment 
 			--	into @sp_name
 			--		,@debet_or_credit
 			--		,@transaction_code
 			--		,@transaction_name
 			--		,@gl_link_code 
 			--		,@fa_code
 			--		,@total_amount
 			--		,@vendor_code
 			--		,@vendor_name
 			--		,@adress
 			--		,@faktur_no
 			--		,@faktur_date
 			--		,@branch_name_asset
 			--		,@branch_name_asset
 			--		,@agreement_external_no
 			--		,@vendor_npwp
 			--end
 			
 			--close curr_payment
 			--deallocate curr_payment
 
 			--select @payment_amount  = isnull(sum(payment_amount),0)
 			--from dbo.payment_request 
 			--where code = @code_payment_request
 
 			--select @orig_amount	= isnull(sum(orig_amount),0) 
 			--from dbo.payment_request_detail
 			--where payment_request_code = @code_payment_request
 			
 			----+ validasi : total detail =  payment_amount yang di header
 			--if (@payment_amount <> @orig_amount)
 			--begin
 			--	set @msg = 'Amount does not balance';
    -- 			raiserror(@msg, 16, -1) ;
 			--end
			
			 		
 			-- loop tabel dbo.master_transaction_parameter mtp  mtp.process_code ='INSPRO1'
 			--				join ke MASTER_TRANSACTION
 				--declare cur_parameter cursor local fast_forward read_only for
 				--select  mt.sp_name
 				--		,mtp.debet_or_credit
 				--		,mtp.gl_link_code
 				--from	dbo.master_transaction_parameter mtp 
 				--		left join dbo.sys_general_subcode sgs on (sgs.code = mtp.process_code)
 				--		left join dbo.master_transaction mt on (mt.code = mtp.transaction_code)
 				--where	mtp.process_code = 'INSPRO1'	
 			
 				--open cur_parameter
 				--fetch cur_parameter 
 				--into @sp_name
 				--	 ,@debet_or_credit
 				--	 ,@gl_link_code
 
 				--while @@fetch_status = 0
 				--begin
 				--	-- nilainya exec dari MASTER_TRANSACTION.sp_name
 				--	exec @return_value = @sp_name @p_code ; -- sp ini mereturn value angka 
 					 
 				--	if @debet_or_credit = 'CREDIT'
 				--	begin
 				--		set @orig_amount = @return_value * -1
 				--	end
 				--	else
 				--	begin
 				--		set @orig_amount = @return_value
 				--	end
 					
 				--		-- setial loop insert ke efam_interface_payment_request_detail
 				--		exec dbo.xsp_efam_interface_payment_request_detail_insert @p_payment_request_code	   = @payment_request_code		 
 				--																  ,@p_company_code			   = 'DSF'	 
 				--		                                                          ,@p_branch_code		       = @branch_code				 			 
 				--		                                                          ,@p_branch_name		       = @branch_name				 				 
 				--		                                                          ,@p_gl_link_code		       = @gl_link_code				 				 
 				--		                                                          ,@p_fa_code			       = @fa_code						 			 
 				--		                                                          ,@p_facility_code		       = null		     			 					 
 				--		                                                          ,@p_facility_name		       = null		     			 			 
 				--		                                                          ,@p_purpose_loan_code        = null						 			 
 				--		                                                          ,@p_purpose_loan_name        = null						 		 
 				--		                                                          ,@p_purpose_loan_detail_code = null						 		 
 				--		                                                          ,@p_purpose_loan_detail_name = null						  
 				--		                                                          ,@p_orig_currency_code	   = @currency					  
 				--		                                                          ,@p_orig_amount	           = @orig_amount				 		 
 				--		                                                          ,@p_division_code            = ''							 				 
 				--		                                                          ,@p_division_name            = ''							 			 
 				--		                                                          ,@p_department_code          = ''							 			 
 				--		                                                          ,@p_department_name          = ''							 			 
 				--		                                                          ,@p_remarks				   = @payment_remarks			 			 
 				--																  --			 
 				--		                                                          ,@p_cre_date				   = @p_cre_date		 
 				--		                                                          ,@p_cre_by				   = @p_cre_by	
 				--		                                                          ,@p_cre_ip_address		   = @p_cre_ip_address
 				--		                                                          ,@p_mod_date				   = @p_mod_date		 
 				--		                                                          ,@p_mod_by				   = @p_mod_by	 
 				--		                                                          ,@p_mod_ip_address		   = @p_mod_ip_address	 
 						
 					
 				--	fetch cur_parameter 
 				--	into @sp_name
 				--		 ,@debet_or_credit
 				--		 ,@gl_link_code
 
 				--end
 				--close cur_parameter
 				--deallocate cur_parameter
 
 				--select @payment_amount  = sum(payment_amount)
 				--from dbo.efam_interface_payment_request 
 				--where code = @p_code
 
 				--select @orig_amount	= sum(orig_amount) 
 				--from dbo.efam_interface_payment_request_detail
 				--where payment_request_code = @p_code
 				
 				----+ validasi : total detail =  payment_amount yang di header
 				--if (@payment_amount <> @orig_amount)
 				--begin
 				--	set @msg = 'Amount does not balance';
     --				raiserror(@msg, 16, -1) ;
 				--end
 			if (@policy_payment_type = 'FTAP')  -- insert pembayaran untuk tahun ke 2 dan seterusnya
 			begin
 				
 				declare curr_payment cursor fast_forward read_only for 
 					select	ipmp.year_periode
 							,dateadd(year, ipmp.year_periode-1,@policy_eff_date)
 							,dateadd(year, (ipmp.year_periode),@policy_eff_date)
 							,ISNULL(ipml.total_sell_amount,0)
 							,0
 							--,ipmp.sell_amount + ISNULL(ipml.total_sell_amount,0)
 							--,ipmp.initial_discount_amount
 							,ipmp.buy_amount + ISNULL(ipml.total_buy_amount,0)
 							,ipmpa.adjustment_discount_amount
 							,ipmpa.adjustment_buy_amount
 					from dbo.insurance_policy_main_period ipmp
 						 left join dbo.insurance_policy_main_loading ipml on (ipml.policy_code = ipmp.code and ipml.year_period = ipmp.year_periode)
 						 left join dbo.insurance_policy_main_period_adjusment ipmpa on (ipmpa.policy_code = ipmp.policy_code and ipmpa.year_periode = ipmp.year_periode)
 					where ipmp.policy_code = @p_code 
 					--and ipmp.year_periode > 1
  
 				open curr_payment
 				
 				fetch next from curr_payment 
 				into @year_periode
 					,@period_eff_date
 					,@period_exp_date
 					,@sell_amount
 					,@initial_discount_amount	
 					,@buy_amount				
 					,@adjustment_discount_amount
 					,@adjustment_buy_amount		
 
 				while @@fetch_status = 0
 				begin
 					
 					 if @max_year = @year_periode
 					 begin
 						set @period_exp_date = @policy_exp_date
 					 end
 					set @total_amount = @buy_amount - @initial_discount_amount + @adjustment_discount_amount +@adjustment_buy_amount
 					set @ppn_amount = dbo.xfn_get_ppn(@initial_discount_amount+ @adjustment_discount_amount) --ROUND(((@initial_discount_amount+ @adjustment_discount_amount)*dbo.xfn_get_ppn(@initial_discount_amount)),0)
 					set @pph_amount = dbo.xfn_get_pph(@initial_discount_amount+ @adjustment_discount_amount) --ROUND(((@initial_discount_amount+ @adjustment_discount_amount)*dbo.xfn_get_pph(@initial_discount_amount)),0)
 					set @total_payment_amount = @total_amount - @ppn_amount + @pph_amount
 					exec dbo.xsp_insurance_payment_schedule_renewal_insert  @p_code							= '',                   
 																			@p_payment_renual_status		= N'HOLD',    
 																			@p_policy_code					= @p_code,               
 																			@p_year_period					= @year_periode,        
 																			@p_policy_eff_date				= @period_eff_date, 
 																			@p_policy_exp_date				= @period_exp_date, 
 																			@p_sell_amount					= @sell_amount,                 
 																			@p_discount_amount				= @initial_discount_amount,             
 																			@p_buy_amount					= @buy_amount,                  
 																			@p_adjustment_sell_amount		= 0,         
 																			@p_adjustment_discount_amount	= @adjustment_discount_amount,  
 																			@p_adjustment_buy_amount		= @adjustment_buy_amount,       
 																			@p_total_amount					= @total_amount,                
 																			@p_ppn_amount					= @ppn_amount,                  
 																			@p_pph_amount					= @pph_amount,                  
 																			@p_total_payment_amount			= @total_payment_amount,        
 																			@p_cre_date						= @p_cre_date,        
 																			@p_cre_by						= @p_cre_by,                     
 																			@p_cre_ip_address				= @p_cre_ip_address,    
 																			@p_mod_date						= @p_mod_date,       
 																			@p_mod_by						= @p_mod_by,                     
 																			@p_mod_ip_address				= @p_mod_ip_address    
 						 
 				    fetch next from curr_payment 
 					into @year_periode
 						,@period_eff_date
 						,@period_exp_date
 						,@sell_amount
 						,@initial_discount_amount	
 						,@buy_amount				
 						,@adjustment_discount_amount
 						,@adjustment_buy_amount		
 
 				end
 				
 				close curr_payment
 				deallocate curr_payment
 				
 			end
 			exec dbo.xsp_insurance_policy_main_history_insert @p_id					= 0
 			                                                  ,@p_policy_code		= @p_code
 			                                                  ,@p_history_date		= @p_cre_date
 			                                                  ,@p_history_type		= 'ON PROCESS'
 			                                                  ,@p_policy_status		= 'POLICY'
 			                                                  ,@p_history_remarks	= 'POLICY ON PROCESS'
 			                                                  ,@p_cre_date			= @p_cre_date      
 															  ,@p_cre_by			= @p_cre_by                  
 															  ,@p_cre_ip_address	= @p_cre_ip_address  
 															  ,@p_mod_date			= @p_mod_date       
 															  ,@p_mod_by			= @p_mod_by                     
 															  ,@p_mod_ip_address	= @p_mod_ip_address  
 			
 		 --   update	dbo.insurance_policy_main  
 			--set		policy_payment_status	= 'ON PROCESS'
 			--		--
 			--		,mod_date		= @p_mod_date		
 			--		,mod_by			= @p_mod_by			
 			--		,mod_ip_address	= @p_mod_ip_address
 			--where	code			= @p_code

			--prepaid insurance
			exec dbo.xsp_prepaid_insurance @p_code				= @p_code
										   ,@p_mod_date			= @p_mod_date
										   ,@p_mod_by			= @p_mod_by
										   ,@p_mod_ip_address	= @p_mod_ip_address
 		end
        else
 		BEGIN
 			set @msg = 'Data already proceed.';
     		raiserror(@msg, 16, -1) ;
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
 
 
 
 
 
 
 
