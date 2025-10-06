/*
exec xsp_job_eom_interest_income_recognition_journal
*/
-- Louis Senin, 06 Maret 2023 13.53.59 -- 
CREATE PROCEDURE [dbo].[xsp_job_eom_interest_income_recognition_journal]
as
begin
	declare @msg					   nvarchar(max)
			,@agreement_no			   nvarchar(50)
			,@income_name			   nvarchar(250)
			,@branch_code			   nvarchar(50)
			,@branch_name			   nvarchar(250)
			,@income_amount			   decimal(18, 2)
			,@gllink_trx_code		   nvarchar(50)
			,@gl_link_code			   nvarchar(50)
			,@currency				   nvarchar(3)
			,@orig_amount_db		   decimal(18, 2)
			,@orig_amount_cr		   decimal(18, 2)
			,@facility_code			   nvarchar(50)
			,@facility_name			   nvarchar(250)
			,@debet_or_credit		   nvarchar(50)
			,@periode				   nvarchar(10) --= cast(right('0' + rtrim(month(dbo.xfn_get_system_date())), 2) as nvarchar(2)) + cast(year(dbo.xfn_get_system_date()) as nvarchar(4))
			,@transaction_name		   nvarchar(250)
			,@invoice_no			   nvarchar(50)
			,@invoice_external_no	   nvarchar(50)
			,@agreement_branch_code	   nvarchar(50)
			,@agreement_branch_name	   nvarchar(250)
			,@eod_date				   datetime		 = dbo.xfn_get_system_date()
			,@mod_date				   datetime		 = getdate()
			,@mod_by				   nvarchar(15)	 = 'EOD'
			,@mod_ip_address		   nvarchar(15)  = '127.0.0.1'
			,@accrue_type			   nvarchar(3)
			,@reverse_gllink_trx_code  nvarchar(50)
			,@reverse_value_date	   datetime
			,@asset_no				   nvarchar(50)
			,@installment_no		   int
			,@transaction_code		nvarchar(50) = ''
			--,@header_accrue_type	   nvarchar(2)

	begin try
		if (day(dateadd(day, 1, @eod_date)) = 1)
		begin   
			declare c_jurnal cursor local fast_forward read_only for
			select distinct
					'INVOICE ACCRUE INTEREST INCOME'
					,aaii.branch_code
					,aaii.branch_name  
					,aaii.accrue_type
					,convert(nvarchar(6), aaii.transaction_date, 112)
			from	dbo.agreement_asset_interest_income aaii
					inner join dbo.invoice inv on inv.invoice_no = aaii.invoice_no
			where	convert(nvarchar(6), aaii.transaction_date, 112) <= convert(nvarchar(6), @eod_date, 112)
			and		isnull(accrue_type, '')  <> ''
			and		inv.invoice_status	  <> 'CANCEL' 
			and		invoice_type		  <> 'PENALTY'
			and		isnull(aaii.status_accrue,'') = ''
			AND		isnull(aaii.income_amount_1, 0) > 0

			open c_jurnal ;

			fetch c_jurnal
			into @income_name
				 ,@branch_code
				 ,@branch_name 
				 ,@accrue_type
				 ,@periode

			while @@fetch_status = 0
			begin  
					set @transaction_name = upper(@income_name) + ' BRANCH ' + @branch_name + ' PERIODE ' + @periode ;

					-- sepria 12mar2024: penomoran transaction code dijadikan unik, di dalam sp insertnya di tambahkan kode transaksi
					set @transaction_code = 'AIR.' + @accrue_type + '.' + @branch_code + '.' + @periode

					begin
						exec dbo.xsp_opl_interface_journal_gl_link_transaction_insert	@p_code						= @gllink_trx_code output
																						,@p_branch_code				= @branch_code
																						,@p_branch_name				= @branch_name
																						,@p_transaction_status		= 'HOLD'
																						,@p_transaction_date		= @eod_date
																						,@p_transaction_value_date	= @eod_date
																						,@p_transaction_code		= @transaction_code--'EOM'
																						,@p_transaction_name		= 'ACCRUE INCOME RECOGNITION'
																						,@p_reff_module_code		= 'IFINOPL'
																						,@p_reff_source_no			= @transaction_code--'EOM'
																						,@p_reff_source_name		= @transaction_name
																						--
																						,@p_cre_date				= @mod_date
																						,@p_cre_by					= @mod_by
																						,@p_cre_ip_address			= @mod_ip_address
																						,@p_mod_date				= @mod_date
																						,@p_mod_by					= @mod_by
																						,@p_mod_ip_address			= @mod_ip_address
					end

					declare c_jurnal_detail cursor local fast_forward read_only for
					select	aaii.agreement_no
							,isnull(aaii.income_amount_1, 0) --ISNULL(aaii.income_amount, 0) --(sepria 09-07-2024: penambahan kolom ini untuk mengcover perubahan konsep income yg dari post reverse jadi post saja untuk report dwh)
							,mtp.gl_link_code
							,mtp.debet_or_credit
							,am.currency_code
							,am.facility_code
							,am.facility_name
							,mt.transaction_name
							,replace(aaii.invoice_no,'.','/')
							,aaii.asset_no
							,aaii.installment_no
							,aaii.invoice_no
					from	dbo.agreement_asset_interest_income aaii
							inner join dbo.master_transaction_parameter mtp on (mtp.process_code = 'INTEREST')
							inner join dbo.master_transaction mt on (mt.code					 = mtp.transaction_code)
							inner join dbo.agreement_main am on (am.agreement_no				 = aaii.agreement_no)
							inner join dbo.invoice inv on inv.invoice_no = aaii.invoice_no
					where	aaii.branch_code		= @branch_code
					and		aaii.accrue_type		= @accrue_type
					and		convert(nvarchar(6), aaii.transaction_date, 112) = @periode
					and		inv.invoice_status	  <> 'CANCEL' 
					and		invoice_type		  <> 'PENALTY'
					and		isnull(aaii.status_accrue,'') = ''
					AND		isnull(aaii.income_amount_1, 0) > 0

					open c_jurnal_detail ;

					fetch c_jurnal_detail
					into @agreement_no
						 ,@income_amount
						 ,@gl_link_code
						 ,@debet_or_credit
						 ,@currency
						 ,@facility_code
						 ,@facility_name
						 ,@transaction_name
						 ,@invoice_external_no 
						 ,@asset_no
						 ,@installment_no
						 ,@invoice_no

					while @@fetch_status = 0
					begin
					
						if (right(isnull(abs(@income_amount), '00'), 2) <> '00')
						begin
							set @msg = 'Data Kriting';
							raiserror(@msg, 16, -1);
						end

						if (@debet_or_credit = 'DEBIT')
						begin
							set @orig_amount_db = abs(@income_amount) ;
							set @orig_amount_cr = 0 ;
						end ;
						else
						begin
							set @orig_amount_db = 0 ;
							set @orig_amount_cr = abs(@income_amount) ;
						end ;

						select	@agreement_branch_code = branch_code
								,@agreement_branch_name = branch_name
						from	dbo.agreement_main
						where	agreement_no = @agreement_no ;
					
						set @transaction_name = upper(@income_name) + ' Periode : ' + @periode + ' For Invoice No : ' + @invoice_external_no  + ', Asset No : ' + @asset_no + ', and Billing No : ' + cast(@installment_no as nvarchar(10)) ;
						
						if (abs(@income_amount) > 0)
						begin
							exec dbo.xsp_opl_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code	 = @gllink_trx_code
																									,@p_branch_code				 = @agreement_branch_code
																									,@p_branch_name				 = @agreement_branch_name
																									,@p_gl_link_code			 = @gl_link_code
																									,@p_agreement_no			 = @agreement_no
																									,@p_facility_code			 = @facility_code			
																									,@p_facility_name			 = @facility_name			
																									,@p_purpose_loan_code		 = null
																									,@p_purpose_loan_name		 = null
																									,@p_purpose_loan_detail_code = null
																									,@p_purpose_loan_detail_name = null
																									,@p_orig_currency_code		 = @currency
																									,@p_orig_amount_db			 = @orig_amount_db
																									,@p_orig_amount_cr			 = @orig_amount_cr
																									,@p_exch_rate				 = 1
																									,@p_base_amount_db			 = @orig_amount_db
																									,@p_base_amount_cr			 = @orig_amount_cr
																									,@p_division_code			 = ''
																									,@p_division_name			 = ''
																									,@p_department_code			 = ''
																									,@p_department_name			 = ''
																									,@p_remarks					 = @transaction_name
																									,@p_add_reff_01				 = @invoice_no
																									,@p_add_reff_02				 = ''
																									,@p_add_reff_03				 = ''
																									--
																									,@p_cre_date				 = @mod_date
																									,@p_cre_by					 = @mod_by
																									,@p_cre_ip_address			 = @mod_ip_address
																									,@p_mod_date				 = @mod_date
																									,@p_mod_by					 = @mod_by
																									,@p_mod_ip_address			 = @mod_ip_address
						end ;
					
						update dbo.agreement_asset_interest_income
						set		reff_no			= @gllink_trx_code
								,reff_name		= @transaction_name
						from	dbo.agreement_asset_interest_income aaii
								inner join dbo.invoice inv on inv.invoice_no = aaii.invoice_no
						where	aaii.branch_code		= @branch_code
						and		aaii.accrue_type		= @accrue_type
						and		convert(nvarchar(6), aaii.transaction_date, 112) = @periode
						and		isnull(accrue_type, '')  <> ''
						and		inv.invoice_status	  <> 'CANCEL' 
						and		invoice_type		  <> 'PENALTY'
						and		isnull(aaii.status_accrue,'') = ''
						and		inv.invoice_no = @invoice_no
						and		agreement_no	= @agreement_no
						and		asset_no		= @asset_no
						and		installment_no	= @installment_no
						and		income_amount_1 < 0

						set @transaction_name = ''

						fetch c_jurnal_detail
						into @agreement_no
							 ,@income_amount
							 ,@gl_link_code
							 ,@debet_or_credit
							 ,@currency
							 ,@facility_code
							 ,@facility_name
							 ,@transaction_name
							 ,@invoice_external_no
							 ,@asset_no
							 ,@installment_no
							 ,@invoice_no

					end ;

					close c_jurnal_detail ;
					deallocate c_jurnal_detail ;

						update dbo.agreement_asset_interest_income
						set		status_accrue	= 'ACCRUED'
								,mod_date		= @mod_date
								,mod_by			= @mod_by
								,mod_ip_address	= @mod_ip_address
						from	dbo.agreement_asset_interest_income aaii
								inner join dbo.invoice inv on inv.invoice_no = aaii.invoice_no
						where	aaii.branch_code		= @branch_code
						and		aaii.accrue_type		= @accrue_type
						and		convert(nvarchar(6), aaii.transaction_date, 112) = @periode
						and		isnull(accrue_type, '')  <> ''
						and		inv.invoice_status	  <> 'CANCEL' 
						and		invoice_type		  <> 'PENALTY'
						and		isnull(aaii.status_accrue,'') = ''
						
					fetch c_jurnal
					into @income_name
						,@branch_code
						,@branch_name
						,@accrue_type
						,@periode
				end 
				close c_jurnal ;
				deallocate c_jurnal ;

				-- balancing
				begin
					if ((
							select	sum(orig_amount_db) - sum(orig_amount_cr)
							from	dbo.opl_interface_journal_gl_link_transaction_detail
							where	gl_link_transaction_code = @gllink_trx_code
						) <> 0
					   )
					begin
						set @msg = 'Journal is not balance' ;

						raiserror(@msg, 16, -1) ;
					end ;
				end ;
			--end ;
		end ;
	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;There is an error.' + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

