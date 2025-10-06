/*
exec xsp_job_eod_invoice_journal_not_due_to_due
*/
-- Louis Selasa, 13 Juni 2023 13.44.52 -- 
CREATE PROCEDURE dbo.xsp_job_eod_invoice_journal_not_due_to_due
as
begin
	declare @msg				  nvarchar(max)
			,@gllink_trx_code	  nvarchar(50)
			,@journal_branch_code nvarchar(50)
			,@journal_branch_name nvarchar(250)
			,@branch_code		  nvarchar(50)
			,@branch_name		  nvarchar(250)
			,@detail_branch_code  nvarchar(50)
			,@detail_branch_name  nvarchar(250)
			,@gl_link_code		  nvarchar(50)
			,@debet_or_credit	  nvarchar(10)
			,@currency			  nvarchar(3)
			,@agreement_no		  nvarchar(50)
			,@orig_amount_db	  decimal(18, 2)
			,@orig_amount_cr	  decimal(18, 2)
			,@transaction_name	  nvarchar(250)
			,@sp_name			  nvarchar(250)
			,@return_value		  decimal(18, 2)
			,@invoice_detail_id	  bigint
			,@invoice_external_no nvarchar(50)
			,@client_name		  nvarchar(250)
			,@periode			  nvarchar(6)
			,@asset_no			  nvarchar(50)
			,@description		  nvarchar(4000)
			,@invoice_no		  nvarchar(50)
			,@reff_name			  nvarchar(50)	= N'AR DUE INVOICE'
			,@reff_code			  nvarchar(50)
			,@invoice_date		  datetime
			,@eod_date			  datetime		= dbo.xfn_get_system_date()
			,@mod_date			  datetime		= getdate()
			,@mod_by			  nvarchar(15)	= N'EOD'
			,@mod_ip_address	  nvarchar(15)	= '127.0.0.1' 
			,@transaction_code	nvarchar(50);

	begin try
		begin 
		 
			declare curr_branch cursor fast_forward read_only for
			select		branch_code
						,branch_name
			from		dbo.invoice
			where		invoice_status		 = 'POST'
						and invoice_due_date <= dbo.xfn_get_system_date() 
						and isnull(is_journal, '0') = '0'
						and invoice_type <> 'PENALTY'
						and CRE_BY <> 'MIGRASI'
			group by	branch_code
						,branch_name ;

			open curr_branch ;

			fetch next from curr_branch
			into @journal_branch_code
				 ,@journal_branch_name ;

			while @@fetch_status = 0
			begin
			
				set @transaction_name = @reff_name + N' For : ' + @journal_branch_name + N' - ' + N'. Periode : ' + cast(year(@eod_date) as nvarchar(4)) + cast(month(@eod_date) as nvarchar(4)) ;
				-- sepria 12mar2024: penomoran transaction code dijadikan unik, di dalam sp insertnya di tambahkan kode transaksi
				set @transaction_code = 'ARDUE.' + @journal_branch_code + '.' + cast(year(@eod_date) as nvarchar(4)) + cast(month(@eod_date) as nvarchar(4)) ;
				
				exec dbo.xsp_opl_interface_journal_gl_link_transaction_insert @p_code = @gllink_trx_code output
																				,@p_branch_code = @journal_branch_code
																				,@p_branch_name = @journal_branch_name
																				,@p_transaction_status = 'HOLD'
																				,@p_transaction_date = @eod_date
																				,@p_transaction_value_date = @eod_date
																				,@p_transaction_code = @transaction_code--'EOD'
																				,@p_transaction_name = @reff_name
																				,@p_reff_module_code = 'IFINOPL'
																				,@p_reff_source_no = @transaction_code--'EOD'
																				,@p_reff_source_name = @transaction_name
																				,@p_cre_date = @mod_date
																				,@p_cre_by = @mod_by
																				,@p_cre_ip_address = @mod_ip_address
																				,@p_mod_date = @mod_date
																				,@p_mod_by = @mod_by
																				,@p_mod_ip_address = @mod_ip_address ;

				declare c_jurnal cursor local fast_forward read_only for
				select	distinct branch_code
						,branch_name
						,currency_code
						,invoice_external_no
						,client_name
						,cast(year(invoice_due_date) as nvarchar(4)) + cast(month(invoice_due_date) as nvarchar(4))
						,invoice_date
						,invoice_no
				from	dbo.invoice
				where	invoice_status		 = 'POST'
						and invoice_due_date <= dbo.xfn_get_system_date() 
						and isnull(is_journal, '0') = '0'
						and CRE_BY <> 'MIGRASI'
						and invoice_type <> 'PENALTY'
						and branch_code			   = @journal_branch_code ;

				open c_jurnal ;

				fetch c_jurnal
				into @branch_code
					 ,@branch_name
					 ,@currency
					 ,@invoice_external_no
					 ,@client_name
					 ,@periode
					 ,@invoice_date
					 ,@invoice_no ;

				while @@fetch_status = 0
				begin
					begin 
						declare c_detail_jurnal cursor local fast_forward read_only for
						select	mt.sp_name
								,mtp.debet_or_credit
								,mtp.gl_link_code
								,mt.transaction_name
								,ind.id
								,ind.agreement_no
								,ind.asset_no
								,ind.description
						from	dbo.master_transaction_parameter mtp
								left join dbo.sys_general_subcode sgs on (sgs.code	 = mtp.process_code)
								left join dbo.master_transaction mt on (mt.code		 = mtp.transaction_code)
								inner join dbo.invoice_detail ind on (ind.invoice_no = @invoice_no)
						where	mtp.process_code = 'INVOICEDUE' ;

						open c_detail_jurnal ;

						fetch c_detail_jurnal
						into @sp_name
							 ,@debet_or_credit
							 ,@gl_link_code
							 ,@transaction_name
							 ,@invoice_detail_id
							 ,@agreement_no
							 ,@asset_no
							 ,@description ;

						while @@fetch_status = 0
						begin

							-- nilainya exec dari MASTER_TRANSACTION.sp_name
							exec @return_value = @sp_name @invoice_detail_id ; -- sp ini mereturn value angka 

							if (isnull(@gl_link_code, '') = '')
							begin
								set @msg = N'Please Setting GL Link For ' + @transaction_name ;

								raiserror(@msg, 16, -1) ;
							end ;

							if (@debet_or_credit = 'DEBIT')
							begin
								set @orig_amount_db = @return_value ;
								set @orig_amount_cr = 0 ;
							end ;
							else
							begin
								set @orig_amount_db = 0 ;
								set @orig_amount_cr = @return_value ;
							end ;

							set @transaction_name = @reff_name + N' For Asset : ' + @asset_no + N', Invoice No : ' + @invoice_external_no + ' ' + @description ;

							select	@detail_branch_code = branch_code
									,@detail_branch_name = branch_name
							from	dbo.agreement_main
							where	agreement_no = @agreement_no ;

							exec dbo.xsp_opl_interface_journal_gl_link_transaction_detail_insert @p_gl_link_transaction_code = @gllink_trx_code
																								 ,@p_branch_code = @detail_branch_code
																								 ,@p_branch_name = @detail_branch_name
																								 ,@p_gl_link_code = @gl_link_code
																								 ,@p_agreement_no = @agreement_no
																								 ,@p_facility_code = null
																								 ,@p_facility_name = null
																								 ,@p_purpose_loan_code = null
																								 ,@p_purpose_loan_name = null
																								 ,@p_purpose_loan_detail_code = null
																								 ,@p_purpose_loan_detail_name = null
																								 ,@p_orig_currency_code = @currency
																								 ,@p_orig_amount_db = @orig_amount_db
																								 ,@p_orig_amount_cr = @orig_amount_cr
																								 ,@p_exch_rate = 1
																								 ,@p_base_amount_db = @orig_amount_db
																								 ,@p_base_amount_cr = @orig_amount_cr
																								 ,@p_division_code = ''
																								 ,@p_division_name = ''
																								 ,@p_department_code = ''
																								 ,@p_department_name = ''
																								 ,@p_remarks = @transaction_name
																								 ,@p_add_reff_01 = @invoice_no
																								 ,@p_add_reff_02 = ''
																								 ,@p_add_reff_03 = ''
																								 ,@p_cre_date = @mod_date
																								 ,@p_cre_by = @mod_by
																								 ,@p_cre_ip_address = @mod_ip_address
																								 ,@p_mod_date = @mod_date
																								 ,@p_mod_by = @mod_by
																								 ,@p_mod_ip_address = @mod_ip_address ;

							fetch c_detail_jurnal
							into @sp_name
								 ,@debet_or_credit
								 ,@gl_link_code
								 ,@transaction_name
								 ,@invoice_detail_id
								 ,@agreement_no
								 ,@asset_no
								 ,@description ;
						end ;

						close c_detail_jurnal ;
						deallocate c_detail_jurnal ;
					end ;

					update	dbo.invoice
					set		is_journal = '1'
							,is_journal_date = dbo.xfn_get_system_date()
							--
							,mod_date = @mod_date
							,mod_by = @mod_by
							,mod_ip_address = @mod_ip_address
					where	invoice_no = @invoice_no ;

					fetch c_jurnal
					into @branch_code
						 ,@branch_name
						 ,@currency
						 ,@invoice_external_no
						 ,@client_name
						 ,@periode
						 ,@invoice_date
						 ,@invoice_no ;
				end ;

				close c_jurnal ;
				deallocate c_jurnal ;

				fetch next from curr_branch
				into @journal_branch_code
					 ,@journal_branch_name ;
			end ;

			close curr_branch ;
			deallocate curr_branch ;

			-- balancing
			begin
				if ((
						select	sum(orig_amount_db) - sum(orig_amount_cr)
						from	dbo.opl_interface_journal_gl_link_transaction_detail
						where	gl_link_transaction_code = @gllink_trx_code
					) <> 0
				   )
				begin
					set @msg = N'Journal is not balance' ;

					raiserror(@msg, 16, -1) ;
				end ;
			end ;
		end ;
	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			set @msg = N'E;There is an error.' + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
