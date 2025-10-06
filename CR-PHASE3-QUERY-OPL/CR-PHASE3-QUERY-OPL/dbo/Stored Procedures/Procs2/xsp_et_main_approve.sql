-- Louis Senin, 26 Desember 2022 11.42.23 -- 
CREATE PROCEDURE dbo.xsp_et_main_approve
(
	@p_code						nvarchar(50) 
	,@p_approval_reff			nvarchar(250)  = ''
	,@p_approval_remark			nvarchar(4000) = ''
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)

as
begin
	declare @msg						 nvarchar(max)
			,@et_amount					 decimal(18, 2)
			,@branch_code				 nvarchar(50)
			,@branch_name				 nvarchar(250)
			,@currency					 nvarchar(10)
			,@remark					 nvarchar(4000)
			,@agreement_no				 nvarchar(50)
			,@et_date					 datetime
			,@validasi_last_invoice_date nvarchar(max) = null
			,@validasi_pending_invoice	 nvarchar(max) = null
			,@validasi_bast_date		 nvarchar(max) = null
			,@refund_amount				 decimal(18, 2)
			,@credit_amount				 decimal(18, 2)
			,@code_credit_no			 nvarchar(50)
			,@code_interface			 nvarchar(50)
			,@remarks					 nvarchar(4000)
			,@client_name				 nvarchar(250)
			,@gl_link_code				 nvarchar(50)
			,@facility_code				 nvarchar(50)
			,@facility_name				 nvarchar(250)
			,@return_value				 decimal(18, 2)
			,@orig_amount_db			 decimal(18, 2)
			,@sp_name					 nvarchar(250)
			,@debet_or_credit			 nvarchar(10)
			,@transaction_name			 nvarchar(250)
			,@billing_type				 nvarchar(50)
			,@asset_no					 nvarchar(50)
			,@invoice_no				 nvarchar(50)
			,@is_approve_to_sell		 nvarchar(50)
			,@etcode					 nvarchar(50)
	
	begin try
		if exists
		(
			select	1
			from	dbo.et_main
			where	code		  = @p_code
					and et_status <> 'ON PROCESS'
		)
		begin
			set @msg = 'Error data already proceed' ;

			raiserror(@msg, 16, 1) ;
		end ;
        else
		begin
			--if exists
			--(
			--	select	1
			--	from	dbo.et_main
			--	where	code						  = @p_code
			--			and cast(et_exp_date as date) < cast(dbo.xfn_get_system_date() as date)
			--)
			--begin
			--	set @msg = 'Date must be greater or equal to System Date' ;

			--	raiserror(@msg, 16, 1) ;
			--end ;

			select  @et_amount		= isnull(et.et_amount, 0)
					,@agreement_no	= et.agreement_no
					,@remark		= et.et_remarks
					,@et_date		= et.et_date
					,@currency		= am.currency_code
					,@branch_code	= et.branch_code
					,@branch_name	= et.branch_name
					,@refund_amount	= et.refund_amount
					,@credit_amount	= et.credit_note_amount
					,@client_name	= am.client_name
					,@facility_code	= am.facility_code
					,@facility_name	= am.facility_name
			from	dbo.et_main et 
					inner join dbo.agreement_main am on (am.agreement_no = et.agreement_no)
			where	code = @p_code

			begin-- (sepria 21/04/2025:2504000068 - validasi hanya per asset saja untuk cover juga case yg billing scheme)

				select	@validasi_bast_date = string_agg((ags.fa_reff_no_01 + ' - ' + convert(nvarchar(50), ags.handover_bast_date, 103)),', ')
				from	dbo.et_main etm
						inner join dbo.et_detail etd on etd.et_code = etm.code and etd.is_terminate = '1'
						inner join dbo.agreement_asset ags on ags.asset_no = etd.asset_no and ags.agreement_no = etm.agreement_no
				where	etm.code = @p_code
				and		cast(etm.et_date as date) < cast(ags.handover_bast_date as date)

				if (@validasi_bast_date is not null)
				begin
					select '@validasi_bast_date', @validasi_bast_date
					set @msg = 'Date Mush Be Greater Than Bast Date From This Assets: ' + @validasi_bast_date ;
					raiserror(@msg, 16, -1) ;
				end

				select	@validasi_pending_invoice = string_agg((ags.fa_reff_no_01 + ' - ' + inv.invoice_external_no),', ')
				from	dbo.et_main etm
						inner join dbo.et_detail etd on etd.et_code = etm.code and etd.is_terminate = '1'
						inner join dbo.agreement_asset ags on ags.asset_no = etd.asset_no and ags.agreement_no = etm.agreement_no
						inner join dbo.agreement_asset_amortization aaa on aaa.agreement_no = ags.agreement_no and aaa.asset_no = ags.asset_no and aaa.invoice_no is not null
						inner join dbo.invoice_detail invd on invd.agreement_no = aaa.agreement_no and invd.asset_no = aaa.asset_no and invd.billing_no = aaa.billing_no
						inner join dbo.invoice inv on inv.invoice_no = invd.invoice_no and inv.invoice_status = 'new'
				where	etm.code = @p_code

				if (@validasi_pending_invoice is not null)
				begin
					set @msg = N'Assets Have a Pending Invoice, Please Complete Invoice Transaction Before ET For This Assets And Invoice No: ' + @validasi_pending_invoice;
					raiserror(@msg, 16, -1) ;
				end
		
				--select	@validasi_last_invoice_date = string_agg( (ags.fa_reff_no_01 + ' - '+ convert(nvarchar(50), ags.invoice_date, 103)),', ')
				--from	dbo.et_main etm
				--		inner join dbo.et_detail etd on etd.et_code = etm.code and etd.is_terminate = '1'
				--		outer apply (
				--						select	ags.fa_reff_no_01, max(inv.invoice_date) 'invoice_date'
				--						from	dbo.agreement_asset ags
				--								inner join dbo.agreement_asset_amortization aaa on aaa.agreement_no = ags.agreement_no and aaa.asset_no = ags.asset_no and aaa.invoice_no is not null
				--								inner join dbo.invoice_detail invd on invd.agreement_no = aaa.agreement_no and invd.asset_no = aaa.asset_no and invd.billing_no = aaa.billing_no
				--								inner join dbo.invoice inv on inv.invoice_no = invd.invoice_no and inv.invoice_status in ('new', 'post', 'paid')
				--						where	ags.asset_no = etd.asset_no and ags.agreement_no = etm.agreement_no
				--						group by	ags.fa_reff_no_01
				--					) ags
				--where	etm.code = @p_code
				--and		cast(etm.et_date as date) < cast(ags.invoice_date as date)
			
				--if(@validasi_last_invoice_date is not null)
				--BEGIN
				--	set @msg = 'Date Mush Be Greater Or Equal Than Last Invoice Date From This Assets: ' + @validasi_last_invoice_date ;
				--	raiserror(@msg, 16, 1) ;    
				--end
			end
			
			if (@et_amount > 0)
			begin  
				exec dbo.xsp_et_to_additional_invoice @p_code				= @p_code
														,@p_agreement_no	= @agreement_no
														,@p_date			= @et_date
														,@p_invoice_type	= N'RENTAL'
														,@p_branch_code	    = @branch_code
														,@p_branch_name	    = @branch_name
														--
														,@p_cre_date		= @p_mod_date
														,@p_cre_by			= @p_mod_by
														,@p_cre_ip_address	= @p_mod_ip_address
														,@p_mod_date		= @p_mod_date
														,@p_mod_by			= @p_mod_by
														,@p_mod_ip_address	= @p_mod_ip_address

				exec dbo.xsp_et_to_additional_invoice @p_code				= @p_code
														,@p_agreement_no	= @agreement_no
														,@p_date			= @et_date
														,@p_invoice_type	= N'PENALTY'
														,@p_branch_code	    = @branch_code
														,@p_branch_name	    = @branch_name
														--
														,@p_cre_date		= @p_mod_date
														,@p_cre_by			= @p_mod_by
														,@p_cre_ip_address	= @p_mod_ip_address
														,@p_mod_date		= @p_mod_date
														,@p_mod_by			= @p_mod_by
														,@p_mod_ip_address	= @p_mod_ip_address
				
				exec dbo.xsp_et_main_paid	@p_code				= @p_code
											,@p_agreement_no	= @agreement_no
											,@p_value_date		= @et_date
											,@p_payment_date	= @et_date
											,@p_invoice_type    = N'PENALTY'
											,@p_mod_date		= @p_mod_date
											,@p_mod_by			= @p_mod_by
											,@p_mod_ip_address	= @p_mod_ip_address

			
			end
            else 
			begin
				exec dbo.xsp_et_main_paid	@p_code				= @p_code
											,@p_agreement_no	= @agreement_no
											,@p_value_date		= @et_date
											,@p_payment_date	= @et_date
											,@p_invoice_type    = 'RENTAL'
											,@p_mod_date		= @p_mod_date
											,@p_mod_by			= @p_mod_by
											,@p_mod_ip_address	= @p_mod_ip_address
			end

				if(@credit_amount > 0)
				begin
					
					declare @credit_amount_asset	decimal(18,2)
							,@ppn_amount			decimal(18,2)
							,@pph_amount			decimal(18,2)
							,@discount_amount		decimal(18,2)
							,@billing_amount		decimal(18,2)
							,@total_amount			decimal(18,2)
							,@credit_amount_detail	decimal(18,2)
							,@id_credit_note_detail	bigint
                            ,@billing_amount_amort	decimal(18,2)
							,@remark_cn				nvarchar(4000)
									
					while @credit_amount > 0
					begin
					    select	top 1 
								@asset_no				= etd.asset_no
								,@credit_amount_asset	= credit_amount
								,@invoice_no			= amz.invoice_no
								,@ppn_amount			= inv.total_ppn_amount
								,@pph_amount			= inv.total_pph_amount
								,@discount_amount		= inv.total_discount_amount
								,@billing_amount		= inv.total_billing_amount
								,@total_amount			= inv.total_amount
								,@billing_amount_amort	= amz.billing_amount
						from	dbo.et_detail etd	
								inner join dbo.et_main em on em.code = etd.et_code
								inner join dbo.agreement_asset_amortization amz on amz.asset_no = etd.asset_no and amz.agreement_no = em.agreement_no
								inner join dbo.agreement_main am on am.agreement_no = amz.agreement_no
								inner join dbo.invoice inv on amz.invoice_no = inv.invoice_no
								outer apply
								(
									select	case am.first_payment_type
													when 'ARR' then period_date + 1
													else period_date
												end 'period_date'
											,period_due_date
									from	dbo.xfn_due_date_period(amz.asset_no, cast(amz.billing_no as int)) aa
									where	aa.billing_no	 = amz.billing_no
											and aa.asset_no = amz.asset_no
								) period
						where	et_code = @p_code
						and		isnull(is_terminate,'0') = '1'
						and		isnull(credit_amount,0) > 0
						and		invoice_status in ('post')
						and		cast(em.et_date as date) <= cast(period.period_date as date)
						and		inv.invoice_no not in (select invoice_no from dbo.credit_note where is_from_et = '1' and et_no = @p_code)
						order by amz.billing_no desc
						
						set @remark_cn = 'ET For Agreement No. ' + isnull(@agreement_no,'') + ', ' + @remark

						exec dbo.xsp_credit_note_insert @p_code					= @code_credit_no output
														,@p_branch_code			= @branch_code
														,@p_invoice_no			= @invoice_no
														,@p_branch_name			= @branch_name
														,@p_currency_code		= @currency
														,@p_ppn_amount			= @ppn_amount
														,@p_pph_amount			= @pph_amount
														,@p_discount_amount		= @discount_amount
														,@p_date				= @p_mod_date
														,@p_status				= 'HOLD'
														,@p_remark				= @remark_cn
														,@p_ppn_pct				= 0
														,@p_pph_pct				= 0
														,@p_billing_amount		= @billing_amount
														,@p_total_amount		= @credit_amount
														,@p_credit_amount		= @billing_amount
														,@p_new_ppn_amount		= 0
														,@p_new_pph_amount		= 0
														,@p_new_total_amount	= 0
														,@p_cre_date			= @p_mod_date
														,@p_cre_by				= @p_mod_by
														,@p_cre_ip_address		= @p_mod_ip_address
														,@p_mod_date			= @p_mod_date
														,@p_mod_by				= @p_mod_by
														,@p_mod_ip_address		= @p_mod_ip_address	
															
							update	dbo.credit_note
							set		is_from_et	= '1'
									,et_no		= @p_code
							where	code = @code_credit_no


							set @credit_amount_detail = @credit_amount

							while @credit_amount_detail > 0
							begin
							   
								if @credit_amount_detail > @billing_amount_amort
								begin
									set @credit_amount_asset	= @billing_amount_amort
									set @credit_amount_detail	= @credit_amount_detail - @credit_amount_asset
								end
								else
								begin
									set @credit_amount_asset	= @credit_amount_detail
									set @credit_amount_detail	= @credit_amount_detail - @credit_amount_asset
								end
								
							    select	top 1 @id_credit_note_detail =  id 
								from	dbo.credit_note_detail
								where	credit_note_code = @code_credit_no
								and		adjustment_amount = 0

								if @id_credit_note_detail is not null
								begin
									exec dbo.xsp_credit_note_detail_update @p_id = @id_credit_note_detail,                           -- bigint
																		   @p_credit_note_code = @code_credit_no,           -- nvarchar(50)
																		   @p_invoice_no = @invoice_no,                 -- nvarchar(50)
																		   @p_adjustment_amount = @credit_amount_asset,         -- decimal(18, 2)
																		   @p_mod_date = @p_mod_date, -- datetime
																		   @p_mod_by = @p_mod_by,                     -- nvarchar(15)
																		   @p_mod_ip_address = @p_mod_ip_address             -- nvarchar(15)
								end
								else
                                begin
                                    set @credit_amount_detail = 0
                                end
							end
                            
							select	@credit_amount = @credit_amount - cn.credit_amount
							from	dbo.credit_note cn
							where	cn.et_no = @p_code
							and		cn.is_from_et = '1'
					end

					--declare curr_credit_note cursor fast_forward read_only for
					--select	asset_no
					--from	dbo.et_detail
					--where	et_code = @p_code
					--and		isnull(is_terminate,'0') = '1'
					--and		isnull(credit_amount,0) > 0
		
					--open curr_credit_note
					
					--fetch next from curr_credit_note 
					--into @asset_no
		
					--while @@fetch_status = 0
					--begin
					--		select	@billing_type = a.billing_type
					--		from	dbo.agreement_main a
					--		where	a.agreement_no = @agreement_no ;

					--		if (@billing_type = 'MNT')
					--		begin
					--			select	@invoice_no = b.invoice_no
					--			from	dbo.agreement_asset_amortization a
					--					inner join dbo.invoice			 b on a.invoice_no = b.invoice_no
					--			where	@et_date
					--					between datefromparts(year(dateadd(month, -1, a.due_date)), month(dateadd(month, -1, a.due_date)), 6) and a.due_date
					--					and a.asset_no = @asset_no
					--					and b.invoice_status in
					--			(
					--				'POST', 'PAID'
					--			) ;
					--		end
					--		else if (@billing_type = 'QRT')
					--		begin
					--			select	@invoice_no = b.invoice_no
					--			from	dbo.agreement_asset_amortization a
					--					inner join dbo.invoice			 b on a.invoice_no = b.invoice_no
					--			where	@et_date
					--					between datefromparts(year(dateadd(month, -3, a.due_date)), month(dateadd(month, -3, a.due_date)), 6) and a.due_date
					--					and a.asset_no = @asset_no
					--					and b.invoice_status in
					--			(
					--				'POST', 'PAID'
					--			) ;
					--		end
					--		else if (@billing_type = 'ANN')
					--		begin
					--			select	@invoice_no = b.invoice_no
					--			from	dbo.agreement_asset_amortization a
					--					inner join dbo.invoice			 b on a.invoice_no = b.invoice_no
					--			where	@et_date
					--					between datefromparts(year(dateadd(month, -12, a.due_date)), month(dateadd(month, -12, a.due_date)), 6) and a.due_date
					--					and a.asset_no = @asset_no
					--					and b.invoice_status in
					--			(
					--				'POST', 'PAID'
					--			) ;
					--		end
					--		else if (@billing_type = 'SMA')
					--		begin
					--			select	@invoice_no = b.invoice_no
					--			from	dbo.agreement_asset_amortization a
					--					inner join dbo.invoice			 b on a.invoice_no = b.invoice_no
					--			where	@et_date
					--					between datefromparts(year(dateadd(month, -6, a.due_date)), month(dateadd(month, -6, a.due_date)), 6) and a.due_date
					--					and a.asset_no = @asset_no
					--					and b.invoice_status in
					--			(
					--				'POST', 'PAID'
					--			) ;
					--		end

					--		exec dbo.xsp_credit_note_insert @p_code					= @code_credit_no output
					--										,@p_branch_code			= @branch_code
					--										,@p_invoice_no			= @invoice_no
					--										,@p_branch_name			= @branch_name
					--										,@p_currency_code		= ''
					--										,@p_ppn_amount			= 0
					--										,@p_pph_amount			= 0
					--										,@p_discount_amount		= 0
					--										,@p_date				= @p_mod_date
					--										,@p_status				= 'HOLD'
					--										,@p_remark				= @remark
					--										,@p_ppn_pct				= 0
					--										,@p_pph_pct				= 0
					--										,@p_billing_amount		= 0
					--										,@p_total_amount		= 0
					--										,@p_credit_amount		= 0
					--										,@p_new_ppn_amount		= 0
					--										,@p_new_pph_amount		= 0
					--										,@p_new_total_amount	= 0
					--										,@p_cre_date			= @p_mod_date
					--										,@p_cre_by				= @p_mod_by
					--										,@p_cre_ip_address		= @p_mod_ip_address
					--										,@p_mod_date			= @p_mod_date
					--										,@p_mod_by				= @p_mod_by
					--										,@p_mod_ip_address		= @p_mod_ip_address				

							
					--	fetch next from curr_credit_note 
					--	into @asset_no
					--end
					
					--close curr_credit_note
					--deallocate curr_credit_note
				end
				
				if (@refund_amount > 0)
				begin
					set @remark	=  'Payment ET from Operating lease '+ @p_code

					exec dbo.xsp_opl_interface_payment_request_insert @p_code					= @code_interface output
																	  ,@p_branch_code			= @branch_code
																	  ,@p_branch_name			= @branch_name
																	  ,@p_payment_branch_code	= @branch_code
																	  ,@p_payment_branch_name	= @branch_name
																	  ,@p_payment_source		= 'ET FOR OPERATING LEASE'
																	  ,@p_payment_request_date	= @p_mod_date
																	  ,@p_payment_source_no		= @p_code
																	  ,@p_payment_status		= 'HOLD'
																	  ,@p_payment_currency_code = @currency
																	  ,@p_payment_amount		= @refund_amount
																	  ,@p_payment_remarks		= @remark
																	  ,@p_to_bank_account_name	= ''
																	  ,@p_to_bank_name			= ''
																	  ,@p_to_bank_account_no	= ''
																	  ,@p_process_date			= null
																	  ,@p_process_reff_no		= null
																	  ,@p_process_reff_name		= null
																	  ,@p_manual_upload_status	= ''
																	  ,@p_manual_upload_remarks = ''
																	  ,@p_job_status			= 'HOLD'
																	  ,@p_failed_remarks		= ''
																	  ,@p_cre_date				= @p_mod_date		
																	  ,@p_cre_by				= @p_mod_by			
																	  ,@p_cre_ip_address		= @p_mod_ip_address
																	  ,@p_mod_date				= @p_mod_date		
																	  ,@p_mod_by				= @p_mod_by			
																	  ,@p_mod_ip_address		= @p_mod_ip_address

					declare curr_withholding_proceed cursor fast_forward read_only for
					select  mt.sp_name
							,mtp.debet_or_credit
							,mtp.gl_link_code
							,mt.transaction_name
					from	dbo.master_transaction_parameter mtp 
							left join dbo.sys_general_subcode sgs on (sgs.code = mtp.process_code)
							left join dbo.master_transaction mt on (mt.code = mtp.transaction_code)
					where	mtp.process_code = 'ETM'	
			
					open curr_withholding_proceed
					
					fetch next from curr_withholding_proceed 
					into @sp_name
						,@debet_or_credit
						,@gl_link_code
						,@transaction_name
					
					while @@fetch_status = 0
					begin
						exec @return_value = @sp_name @p_code; -- sp ini mereturn value angka 
					
						if (@debet_or_credit ='DEBIT')
						begin
							set @orig_amount_db = @return_value
						end
						else
						begin
							set @orig_amount_db = @return_value * -1
						end
				
						set @remarks = 'ET for agreement  ' + isnull(@agreement_no,'') + ' ' + isnull(@client_name,'');

						exec dbo.xsp_opl_interface_payment_request_detail_insert @p_id							= 0
																				 ,@p_payment_request_code		= @code_interface
																				 ,@p_branch_code				= @branch_code
																				 ,@p_branch_name				= @branch_name
																				 ,@p_gl_link_code				= @gl_link_code
																				 ,@p_agreement_no				= @agreement_no
																				 ,@p_facility_code				= @facility_code
																				 ,@p_facility_name				= @facility_name
																				 ,@p_purpose_loan_code			= ''
																				 ,@p_purpose_loan_name			= ''
																				 ,@p_purpose_loan_detail_code	= ''
																				 ,@p_purpose_loan_detail_name	= ''
																				 ,@p_orig_currency_code			= @currency
																				 ,@p_orig_amount				= @orig_amount_db
																				 ,@p_division_code				= ''
																				 ,@p_division_name				= ''
																				 ,@p_department_code			= ''
																				 ,@p_department_name			= ''
																				 ,@p_remarks					= @remarks
																				 ,@p_cre_date					= @p_mod_date		
																				 ,@p_cre_by						= @p_mod_by			
																				 ,@p_cre_ip_address				= @p_mod_ip_address
																				 ,@p_mod_date					= @p_mod_date		
																				 ,@p_mod_by						= @p_mod_by			
																				 ,@p_mod_ip_address				= @p_mod_ip_address

					fetch next from curr_withholding_proceed 
					into @sp_name
						,@debet_or_credit
						,@gl_link_code
						,@transaction_name
					end
			
					close curr_withholding_proceed
					deallocate curr_withholding_proceed

					--validasi
					set @msg = dbo.xfn_finance_request_check_balance('PAYMENT',@code_interface)
					if @msg <> ''
					begin
						raiserror(@msg,16,1);
					end
				end
                
				if exists (	select	1
							from	dbo.et_detail etd
							where	et_code = @p_code
							and		isnull(etd.is_approve_to_sell,'0') = '1'
							and		isnull(etd.is_terminate,'0') = '1'
						)
				begin
				---------------------------------------------------------------------

					insert into [dbo].[opl_interface_sell_request_from_et]
					(
						[code],
						[status],
						[transaction_date],
						[type],
						[remark],
						[agreement_external_no],
						[agreement_no],
						[client_no],
						[client_name],
						[settle_date],
						[job_status],
						[failed_remarks],
						[cre_date],
						[cre_by],
						[cre_ip_address],
						[mod_date],
						[mod_by],
						[mod_ip_address],
						branch_code,
						branch_name
					)
					select	code
							,em.et_status
							,em.et_date
							,'COP'
							,'ET For Agreement No. ' + am.agreement_external_no + ', ' + em.et_remarks
							,am.agreement_external_no
							,em.agreement_no
							,am.client_no
							,am.client_name
							,NULL
							,'HOLD'
							,NULL
							,@p_mod_date
							,@p_mod_by
							,@p_mod_ip_address
							,@p_mod_date
							,@p_mod_by
							,@p_mod_ip_address
							,em.branch_code
							,em.branch_name
					from	dbo.et_main em 
							inner join dbo.agreement_main am on am.agreement_no = em.agreement_no
					where	code = @p_code
					
				
					insert into [dbo].[opl_interface_sell_request_detail_from_et]
					(
						[code],
						[status],
						[transaction_date],
						[type],
						[remark],
						et_code,
						[agreement_no],
						[fa_code],
						[client_no],
						[client_name],
						[settle_date],
						[job_status],
						[failed_remarks],
						[cre_date],
						[cre_by],
						[cre_ip_address],
						[mod_date],
						[mod_by],
						[mod_ip_address]
					)
					select	etd.et_code
							,em.et_status
							,em.et_date
							,'COP'
							,'ET For Agreement No. ' + am.agreement_external_no + ', ' + em.et_remarks
							,etd.et_code
							,em.agreement_no
							,ags.fa_code
							,am.client_no
							,am.client_name
							,null
							,'HOLD'
							,null
							,@p_mod_date
							,@p_mod_by
							,@p_mod_ip_address
							,@p_mod_date
							,@p_mod_by
							,@p_mod_ip_address
					from	dbo.et_detail etd
							inner join dbo.et_main em on em.code = etd.et_code
							inner join dbo.agreement_main am on am.agreement_no = em.agreement_no
							inner join dbo.agreement_asset ags on ags.asset_no = etd.asset_no
					where	etd.et_code = @p_code 
					and		isnull(etd.is_approve_to_sell,'0') = '1'
					and		isnull(etd.is_terminate,'0') = '1'
			---------------------------------------------------------------------
				end
                
			update dbo.et_main
			set		et_status		= 'APPROVE'
					,mod_by			= @p_mod_by
					,mod_date		= @p_mod_date
					,mod_ip_address	= @p_mod_ip_address
			where   code			= @p_code
			
			exec dbo.xsp_agreement_main_update_terminate_status @p_agreement_no		 = @agreement_no
																,@p_termination_date = @et_date
																--
																,@p_mod_date		 = @p_mod_date
																,@p_mod_by			 = @p_mod_ip_address
																,@p_mod_ip_address	 = @p_mod_by ;
			-- update lms status
			exec dbo.xsp_agreement_main_update_opl_status @p_agreement_no	= @agreement_no
															,@p_status		= N'' 
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
	
end



