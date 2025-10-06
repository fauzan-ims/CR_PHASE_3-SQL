CREATE PROCEDURE dbo.xsp_billing_generate_invoice_by_non_scheme
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					 nvarchar(max)
			,@agreement_no			 nvarchar(50)
			,@agreement_external_no	 nvarchar(50)
			,@asset_no				 nvarchar(50)
			,@invoice_no			 nvarchar(50)
			,@branch_code			 nvarchar(50)
			,@branch_name			 nvarchar(250)
			,@date					 datetime
			,@client_no				 nvarchar(50)
			,@client_name			 nvarchar(250)
			,@client_npwp_name		 nvarchar(250)
			,@as_of_date			 datetime
			,@due_date				 datetime
			,@invoice_name			 nvarchar(250)
			,@total_billing_amount	 decimal(18, 2)
			,@total_discount_amount	 decimal(18, 2)
			,@total_ppn_amount		 int
			,@total_pph_amount		 int
			,@total_amount			 decimal(18, 2)
			,@billing_no			 int
			,@asset_no_detail		 nvarchar(50)
			,@description_detail	 nvarchar(4000)
			,@rental_amount			 decimal(18, 2)
			,@ppn_pct				 decimal(9, 6)
			,@pph_pct				 decimal(9, 6)
			,@ppn_amount			 int
			,@pph_amount			 int
			,@total_amount_detail	 decimal(18, 2)
			,@code					 nvarchar(50)
			,@ar_amount				 decimal(18, 2)
			,@code_invoice_pph		 nvarchar(50)
			,@system_date			 datetime	   = dbo.xfn_get_system_date()
			,@settlement_type		 nvarchar(10)
			,@credit_term			 int
			,@fix_due_date			 datetime
			,@client_npwp_address	 nvarchar(4000)
			,@client_area_phone_no	 nvarchar(4)
			,@client_phone_no		 nvarchar(15)
			,@client_npwp			 nvarchar(50)
			,@currency_code			 nvarchar(3)
			,@multiplier			 int
			,@no					 int		   = 1
			,@billing_to_faktur_type nvarchar(3)
			,@is_invoice_deduct_pph	 nvarchar(1) 
			,@is_receipt_deduct_pph	 nvarchar(1)
			,@payment_reff_no		 nvarchar(50)
			,@payment_reff_date		 datetime
			,@settlement_status		 nvarchar(10)
			,@billing_date			datetime
			--(+) Raffy 2025/02/01 CR NITKU
            ,@client_nitku			NVARCHAR(50)
			

	begin try
		begin
			select	@ppn_pct = value
			from	dbo.sys_global_param
			where	code = ('RTAXPPN') ;

			select	@pph_pct = value
			from	dbo.sys_global_param
			where	code = ('RTAXPPH') ;

			--loop untuk adv/arr
			while (@no <= 2)
			begin
				declare curr_billing cursor fast_forward read_only for --cursor ini digunakan untuk mendapatkan distinc grouping invoice ( harusnya tidak)
				select	bg.agreement_no
						,am.agreement_external_no
						,am.branch_code
						,am.branch_name
						,am.client_no
						,am.client_name -- (+) ari 2023-09-13 ket : change billing name to client name
						,am.credit_term
						,case
							 when aa.is_invoice_deduct_pph = '0' then 'NON PKP'
							 else 'PKP'
						 end
						,ISNULL(aa.npwp_address,'-')
						,aa.billing_to_area_no
						,aa.billing_to_phone_no
						,aa.billing_to_npwp
						,am.currency_code
						,mbt.multiplier
						,aa.asset_no
						,bg.due_date 
						,bg.billing_no
						,bg.asset_no
						,bg.description
						,bg.rental_amount
						,aa.billing_to_faktur_type
						,aa.npwp_name
						,aa.is_invoice_deduct_pph
						,aa.is_receipt_deduct_pph
						,bg.billing_date
						--(+) Raffy 2025/02/01 CR NITKU
						,isnull(aa.client_nitku,'')
				from	dbo.billing_generate_detail bg
						inner join dbo.agreement_main am on (am.agreement_no	   = bg.agreement_no)
						inner join dbo.agreement_asset aa on (
																 aa.agreement_no   = bg.agreement_no
																 and   aa.asset_no = bg.asset_no
															 )
						inner join dbo.master_billing_type mbt on (mbt.code		   = am.billing_type)						
				where	bg.generate_code			  = @p_code
						and isnull(bg.invoice_no, '') = '' -- untuk meng exclude yang sudah di generate di scheme
						and am.first_payment_type	  = CASE
															WHEN @no = 1 THEN 'ADV'
															ELSE 'ARR'
														END 
						and aa.asset_no not in 
							(
								select	ed.asset_no 
								from	dbo.et_main em
								inner join dbo.et_detail ed on ed.et_code = em.code
								where	ed.is_terminate = '1'
										and	em.et_status NOT IN  ('CANCEL','EXPIRED')
										and	em.agreement_no = am.agreement_no
							);

				open curr_billing ;

				fetch next from curr_billing
				into @agreement_no
					 ,@agreement_external_no
					 ,@branch_code
					 ,@branch_name
					 ,@client_no
					 ,@client_name
					 ,@credit_term
					 ,@settlement_type
					 ,@client_npwp_address
					 ,@client_area_phone_no
					 ,@client_phone_no
					 ,@client_npwp
					 ,@currency_code
					 ,@multiplier
					 ,@asset_no
					 ,@due_date
					 ,@billing_no
					 ,@asset_no_detail
					 ,@description_detail
					 ,@rental_amount
					 ,@billing_to_faktur_type
					 ,@client_npwp_name
					 ,@is_invoice_deduct_pph
					 ,@is_receipt_deduct_pph 
					 ,@billing_date
					 ,@client_nitku

				while @@fetch_status = 0
				begin
					--SELECT @due_date = MAX(bg.DUE_DATE)
					--FROM dbo.BILLING_GENERATE_DETAIL bg
					--    INNER JOIN dbo.AGREEMENT_ASSET aa
					--        ON (
					--               aa.AGREEMENT_NO = bg.AGREEMENT_NO
					--               AND aa.ASSET_NO = bg.ASSET_NO
					--           )
					--WHERE bg.GENERATE_CODE = @p_code
					--      AND aa.BILLING_TO_NAME = @client_name
					--      AND aa.BILLING_TO_NPWP = @client_npwp;

					--IF (@system_date <= @due_date)
					--BEGIN
					set @date = @due_date ;
					--END;
					--ELSE
					--BEGIN
					--    SET @date = @system_date;
					--END;
					set @invoice_name = N'Invoice Rental Contract No ' + @agreement_external_no + N' a.n ' + @client_name ;

					if not exists
					(
						select	1
						from	dbo.INVOICE inv
								inner join dbo.INVOICE_DETAIL invd on (invd.INVOICE_NO = inv.INVOICE_NO)
						where	inv.GENERATE_CODE				  = @p_code
								--AND inv.BRANCH_CODE = @branch_code
								and isnull(inv.SCHEME_CODE, '')	  = '' -- compare to non scheme only
								and invd.AGREEMENT_NO			  = @agreement_no
								and inv.CLIENT_NAME				  = @client_npwp_name
								and inv.CLIENT_NPWP				  = @client_npwp
								and inv.INVOICE_DATE			  = @due_date
					--and invd.asset_no not in
					--					(
					--						select	bsd.asset_no
					--						from	dbo.billing_scheme bs
					--								inner join dbo.billing_scheme_detail bsd on bsd.scheme_code = bs.code
					--						where	bs.is_active = '1'
					--					)
					)
					begin
						-- Hari - 12.Jul.2023 11:49 AM --	tanggal due date selalu dihitung dari billing date
						--if (@system_date <= @due_date)
						--begin
						set @fix_due_date = dateadd(day, isnull(@credit_term, 0), @billing_date ) -- @due_date) ; sepria 02022024, invoice_due_date = Billing_date + TOP

						--end
						--else
						--begin
						--	set @fix_due_date = dateadd(day, isnull(@credit_term, 0), @system_date) ;
						--end
						exec dbo.xsp_invoice_insert @p_invoice_no				= @invoice_no output
													,@p_branch_code				= @branch_code
													,@p_branch_name				= @branch_name
													,@p_invoice_type			= 'RENTAL'
													,@p_invoice_date			= @due_date
													,@p_invoice_due_date		= @fix_due_date
													,@p_invoice_name			= @invoice_name
													,@p_invoice_status			= 'NEW'
													,@p_client_no				= @client_no
													,@p_client_name				= @client_npwp_name
													,@p_client_address			= @client_npwp_address
													,@p_client_area_phone_no	= @client_area_phone_no
													,@p_client_phone_no			= @client_phone_no
													,@p_client_npwp				= @client_npwp
													,@p_currency_code			= @currency_code
													,@p_total_billing_amount	= 0
													,@p_total_discount_amount	= 0
													,@p_total_ppn_amount		= 0
													,@p_total_pph_amount		= 0
													,@p_total_amount			= 0
													,@p_faktur_no				= ''
													,@p_generate_code			= @p_code
													,@p_scheme_code				= ''
													,@p_received_reff_no		= ''
													,@p_received_reff_date		= null
													,@p_billing_to_faktur_type  = @billing_to_faktur_type
													,@p_is_invoice_deduct_pph   = @is_invoice_deduct_pph
													,@p_is_receipt_deduct_pph   = @is_receipt_deduct_pph
													,@p_billing_date			= @billing_date
													--(+) Raffy 2025/02/01 CR NITKU
													,@p_client_nitku			= @client_nitku
													--
													,@p_cre_date				= @p_mod_date
													,@p_cre_by					= @p_mod_by
													,@p_cre_ip_address			= @p_mod_ip_address
													,@p_mod_date				= @p_mod_date
													,@p_mod_by					= @p_mod_by
													,@p_mod_ip_address			= @p_mod_ip_address 
													

						exec dbo.xsp_invoice_pph_insert @p_id					= 0
														,@p_invoice_no			= @invoice_no
														,@p_settlement_type		= @settlement_type
														,@p_settlement_status	= N'HOLD'
														,@p_file_path			= null
														,@p_file_name			= null
														,@p_payment_reff_no		= null
														,@p_payment_reff_date	= null
														,@p_total_pph_amount	= 0
														--
														,@p_cre_date			= @p_mod_date
														,@p_cre_by				= @p_mod_by
														,@p_cre_ip_address		= @p_mod_ip_address
														,@p_mod_date			= @p_mod_date
														,@p_mod_by				= @p_mod_by
														,@p_mod_ip_address		= @p_mod_ip_address ;
					end ;
					else
					begin
						select	@invoice_no = inv.INVOICE_NO
						from	dbo.INVOICE inv
								inner join dbo.INVOICE_DETAIL invd on (invd.INVOICE_NO = inv.INVOICE_NO)
						where	inv.GENERATE_CODE				  = @p_code
								--AND inv.BRANCH_CODE = @branch_code
								and isnull(inv.SCHEME_CODE, '')	  = '' -- compare to non scheme only
								and invd.AGREEMENT_NO			  = @agreement_no
								and inv.CLIENT_NAME				  = @client_npwp_name
								and inv.CLIENT_NPWP				  = @client_npwp
								and inv.INVOICE_DATE			  = @due_date
					end ;

					--SELECT DISTINCT
					--		   bg.BILLING_NO,
					--		   bg.ASSET_NO,
					--		   bg.DESCRIPTION,
					--		   bg.RENTAL_AMOUNT,
					--		   aa.BILLING_TO_FAKTUR_TYPE,
					--		   aa.IS_INVOICE_DEDUCT_PPH
					--	FROM dbo.BILLING_GENERATE_DETAIL bg
					--		INNER JOIN dbo.AGREEMENT_ASSET aa
					--			ON (
					--				   aa.AGREEMENT_NO = bg.AGREEMENT_NO
					--				   AND aa.ASSET_NO = bg.ASSET_NO
					--			   )
					--	WHERE bg.GENERATE_CODE = @p_code
					--		  AND bg.ASSET_NO = @asset_no
					--		  AND bg.AGREEMENT_NO = @agreement_no
					--		  AND aa.BILLING_TO_NAME = @client_name
					--		  AND aa.BILLING_TO_NPWP = @client_npwp;
					--               DECLARE curr_bill_generate CURSOR FAST_FORWARD READ_ONLY FOR
					--	SELECT DISTINCT
					--		   bg.BILLING_NO,
					--		   bg.ASSET_NO,
					--		   bg.DESCRIPTION,
					--		   bg.RENTAL_AMOUNT,
					--		   aa.BILLING_TO_FAKTUR_TYPE,
					--		   aa.IS_INVOICE_DEDUCT_PPH
					--	FROM dbo.BILLING_GENERATE_DETAIL bg
					--		INNER JOIN dbo.AGREEMENT_ASSET aa
					--			ON (
					--				   aa.AGREEMENT_NO = bg.AGREEMENT_NO
					--				   AND aa.ASSET_NO = bg.ASSET_NO
					--			   )
					--	WHERE bg.GENERATE_CODE = @p_code
					--		  AND bg.ASSET_NO = @asset_no
					--		  AND bg.AGREEMENT_NO = @agreement_no
					--		  AND aa.BILLING_TO_NAME = @client_name
					--		  AND aa.BILLING_TO_NPWP = @client_npwp;

					--               OPEN curr_bill_generate;

					--               FETCH NEXT FROM curr_bill_generate
					--               INTO @billing_no,
					--                    @asset_no_detail,
					--                    @description_detail,
					--                    @rental_amount,
					--                    @billing_to_faktur_type,
					--                    @is_invoice_deduct_pph;

					--               WHILE @@fetch_status = 0
					begin
						set @ppn_amount = round(((@rental_amount - 0) * 1 * @ppn_pct / 100),0) ;
						--if (year(@billing_date) = '2024') --or (year(@invoice_generate_date) = '2024')
						--begin
						--	set @ppn_amount = (@rental_amount - 0) * 1 * 11 / 100 ;
						--end						
						--else
						--begin
						--	set @ppn_amount = (@rental_amount - 0) * 1 * 12 / 100 ;
						--end

						set @pph_amount = round(((@rental_amount - 0) * 1 * @pph_pct / 100),0) ;

						-- WAPU
						if (@billing_to_faktur_type = '01')
						begin
							set @total_amount_detail = @rental_amount + @ppn_amount ;
						end ;
						-- NON WAPU
						else
						begin
							set @total_amount_detail = @rental_amount ;
						end ;

						if (@client_no = '1000CUST20220600148')
						begin
							set @pph_amount = round((@total_amount_detail * (10.00 / 100)),0)
						end

						--jika potong pph 
						if (@is_invoice_deduct_pph = '1')
						begin
							set @total_amount_detail = @total_amount_detail - @pph_amount ;
							set @payment_reff_no = null ;
							set @payment_reff_date = null ;
							set @settlement_status = N'HOLD' ;
						end ;
						else
						begin
							set @total_amount_detail = @total_amount_detail ;
							set @payment_reff_no = N'NOT DEDUCT PPH' ;
							set @payment_reff_date = dbo.xfn_get_system_date() ;
							set @settlement_status = N'POST' ;
						end ;

						exec dbo.xsp_invoice_detail_insert @p_id				= 0
														   ,@p_invoice_no		= @invoice_no
														   ,@p_agreement_no		= @agreement_no
														   ,@p_asset_no			= @asset_no_detail
														   ,@p_billing_no		= @billing_no
														   ,@p_description		= @description_detail
														   ,@p_quantity			= 1
														   ,@p_billing_amount	= @rental_amount
														   ,@p_discount_amount	= 0
														   ,@p_ppn_pct			= @ppn_pct
														   ,@p_ppn_amount		= @ppn_amount
														   ,@p_pph_pct			= @pph_pct
														   ,@p_pph_amount		= @pph_amount
														   ,@p_total_amount		= @total_amount_detail
														   ,@p_tax_scheme_code	= ''
														   ,@p_tax_scheme_name	= ''
														   ,@p_cre_date			= @p_mod_date
														   ,@p_cre_by			= @p_mod_by
														   ,@p_cre_ip_address	= @p_mod_ip_address
														   ,@p_mod_date			= @p_mod_date
														   ,@p_mod_by			= @p_mod_by
														   ,@p_mod_ip_address	= @p_mod_ip_address ;

						select	@total_billing_amount	= sum(billing_amount)
								,@total_discount_amount = sum(discount_amount)
								,@total_ppn_amount		= sum(ppn_amount)
								,@total_pph_amount		= sum(pph_amount)
								,@total_amount			= sum(total_amount)
						from	dbo.invoice_detail
						where	invoice_no = @invoice_no ;

						update	dbo.invoice
						set		total_billing_amount	= @total_billing_amount
								,total_discount_amount	= @total_discount_amount
								,total_ppn_amount		= @total_ppn_amount
								,total_pph_amount		= @total_pph_amount
								,total_amount			= @total_amount
								--
								,mod_date				= @p_mod_date
								,mod_by					= @p_mod_by
								,mod_ip_address			= @p_mod_ip_address
						where	invoice_no = @invoice_no ;

						update	dbo.invoice_pph
						set		total_pph_amount	= @total_pph_amount
								,payment_reff_no	= @payment_reff_no
								,payment_reff_date	= @payment_reff_date
								,settlement_status	= @settlement_status
								--
								,mod_date			= @p_mod_date
								,mod_by				= @p_mod_by
								,mod_ip_address		= @p_mod_ip_address
						where	invoice_no = @invoice_no ;

						update	dbo.billing_generate_detail
						set		invoice_no		= @invoice_no
								--
								,mod_date		= @p_mod_date
								,mod_by			= @p_mod_by
								,mod_ip_address = @p_mod_ip_address
						where	generate_code	 = @p_code
								and billing_no	 = @billing_no
								and asset_no	 = @asset_no
								and agreement_no = @agreement_no ;

						update	dbo.agreement_asset_amortization
						set		generate_code	= @p_code
								,invoice_no		= @invoice_no
								--
								,mod_date		= @p_mod_date
								,mod_by			= @p_mod_by
								,mod_ip_address = @p_mod_ip_address
						where	asset_no	   = @asset_no
								and billing_no = @billing_no ;

						set @total_billing_amount = 0 ;
						set @total_discount_amount = 0 ;
						set @total_ppn_amount = 0 ;
						set @total_pph_amount = 0 ;
						set @total_amount = 0 ;

					--FETCH NEXT FROM curr_bill_generate
					--INTO @billing_no,
					--     @asset_no_detail,
					--     @description_detail,
					--     @rental_amount,
					--     @billing_to_faktur_type,
					--     @is_invoice_deduct_pph;
					end ;

				
					--CLOSE curr_bill_generate;
					--DEALLOCATE curr_bill_generate;
					fetch next from curr_billing
					into @agreement_no
						 ,@agreement_external_no
						 ,@branch_code
						 ,@branch_name
						 ,@client_no
						 ,@client_name
						 ,@credit_term
						 ,@settlement_type
						 ,@client_npwp_address
						 ,@client_area_phone_no
						 ,@client_phone_no
						 ,@client_npwp
						 ,@currency_code
						 ,@multiplier
						 ,@asset_no
						 ,@due_date
						 ,@billing_no
						 ,@asset_no_detail
						 ,@description_detail
						 ,@rental_amount
						 ,@billing_to_faktur_type
						 ,@client_npwp_name
						 ,@is_invoice_deduct_pph
						 ,@is_receipt_deduct_pph
						 ,@billing_date
						 ,@client_nitku
				end ;

				close curr_billing ;
				deallocate curr_billing ;

				set @no += 1 ;

			end ;

			begin -- insert untuk selisih ppn hitungan ifin dengan coretax
				--(+) sepria 06032025: cr dpp ppn 12% coretax
				declare curr_invoice cursor fast_forward read_only for
				select	invoice_no
				from	dbo.invoice
				where	generate_code = @p_code

				open curr_invoice
			
				fetch next from curr_invoice 
				into @invoice_no

				while @@fetch_status = 0
				begin
					exec dbo.xsp_invoice_update_dpp_nilai_lain @p_invoice_no = @invoice_no,          
															   @p_mod_date = @p_mod_date,
															   @p_mod_by = @p_mod_by,
															   @p_mod_ip_address = @p_mod_ip_address
													
					fetch next from curr_invoice 
					into @invoice_no
				end
				close curr_invoice
				deallocate curr_invoice 
			end
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
