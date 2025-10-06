
-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_billing_generate_invoice_by_scheme]
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	-- ambil data dari scheme
	-- check apakah ada di tabel generate detail
	-- jika ada ambil untuk dibuat menjadi invoice
	declare @msg					 nvarchar(max)
			,@agreement_no			 nvarchar(50)
			,@agreement_external_no	 nvarchar(50)
			--,@asset_no					 nvarchar(50)
			,@invoice_no			 nvarchar(50)
			,@branch_code			 nvarchar(50)
			,@branch_name			 nvarchar(250)
			,@date					 datetime
			,@client_no				 nvarchar(50)
			,@client_name			 nvarchar(250)
			,@client_npwp_name		 nvarchar(250)
			,@as_of_date			 datetime
			,@invoice_generate_date	 datetime
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
			,@invoice_due_date_top	 datetime
			,@client_address		 nvarchar(4000)
			,@client_area_phone_no	 nvarchar(4)
			,@client_phone_no		 nvarchar(15)
			,@client_npwp			 nvarchar(50)
			,@currency_code			 nvarchar(3)
			,@billing_to_faktur_type nvarchar(3)
			,@is_invoice_deduct_pph	 nvarchar(1)
			,@payment_reff_no		 nvarchar(50)
			,@payment_reff_date		 datetime
			,@settlement_status		 nvarchar(10)
			,@multiplier			 int
			,@no					 int		   = 1
			,@scheme_code			 nvarchar(50)
			,@scheme_name			 nvarchar(250) 
			,@is_receipt_deduct_pph	 nvarchar(1)
			,@total_asset			 INT
            ,@billing_date			DATETIME
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

		--ambil semua scheme yang ada di billig generate detail
			select	distinct
					bs.code
					,bs.scheme_name
					,bs.client_name
					,bs.client_no
			from	dbo.billing_scheme bs
					inner join dbo.billing_scheme_detail bsd on bsd.scheme_code = bs.code
																and exists
																	(
																		select	1
																		from	dbo.billing_generate_detail bgd
																		where	bgd.generate_code = @p_code
																				and bgd.asset_no  = bsd.asset_no
																	)
			where	bs.is_active = '1' 
			-- sepria 31052025: tambah kondisi ini agar langsung terexclude
			and		bsd.asset_no not in 
							(
								select	ed.asset_no 
								FROM	dbo.et_main em
								inner join dbo.et_detail ed on ed.et_code = em.code
								where	ed.is_terminate = '1'
										and	em.et_status NOT IN  ('CANCEL','EXPIRED')
										and	em.agreement_no = bsd.agreement_no
							);


			declare curr_billing cursor fast_forward read_only for --cursor ini digunakan untuk mendapatkan distinc grouping invoice

			--ambil semua scheme yang ada di billig generate detail
			select	distinct
					bs.code
					,bs.scheme_name
					,bs.client_name
					,bs.client_no
			from	dbo.billing_scheme bs
					inner join dbo.billing_scheme_detail bsd on bsd.scheme_code = bs.code
																and exists
																	(
																		select	1
																		from	dbo.billing_generate_detail bgd
																		where	bgd.generate_code = @p_code
																				and bgd.asset_no  = bsd.asset_no
																	)
			where	bs.is_active = '1' 
			-- sepria 31052025: tambah kondisi ini agar langsung terexclude
			and		bsd.asset_no not in 
							(
								select	ed.asset_no 
								FROM	dbo.et_main em
								inner join dbo.et_detail ed on ed.et_code = em.code
								where	ed.is_terminate = '1'
										and	em.et_status NOT IN  ('CANCEL','EXPIRED')
										and	em.agreement_no = bsd.agreement_no
							);

			open curr_billing ;

			fetch next from curr_billing
			into @scheme_code
				 ,@scheme_name
				 ,@client_name
				 ,@client_no ;

			while @@fetch_status = 0
			begin
				select	top 1
						@client_address = ISNULL(aa.npwp_address ,'-')
						,@client_area_phone_no = aa.billing_to_area_no
						,@client_phone_no = aa.billing_to_phone_no
						,@client_npwp = aa.billing_to_npwp
						,@branch_code = am.branch_code
						,@branch_name = am.branch_name
						,@credit_term = am.credit_term
						,@settlement_type = case aa.is_invoice_deduct_pph
												when '1' then 'PKP'
												else 'NON PKP'
											end
						,@currency_code = am.currency_code
						,@client_npwp_name = aa.npwp_name
						,@billing_to_faktur_type = aa.billing_to_faktur_type
						,@is_invoice_deduct_pph	= aa.is_invoice_deduct_pph
						,@is_receipt_deduct_pph	= aa.is_receipt_deduct_pph
						--(+) Raffy 2025/02/01 CR NITKU
						,@client_nitku	= isnull(aa.client_nitku,'')
				from	dbo.billing_scheme_detail bsd
						inner join dbo.agreement_asset aa on (aa.asset_no	 = bsd.asset_no)
						inner join dbo.agreement_main am on (am.agreement_no = aa.agreement_no)						
				where	bsd.scheme_code = @scheme_code 						

				select	@invoice_generate_date = max(bg.due_date) -- (+) invoice_date menggunakan due_date -- sepria 02022024
						,@billing_date		= max(bg.billing_date) -- (+) invoice_due_date menggunakan billing date -- sepria 02022024
				--@agreemvent_no = max(bsd.agreement_no)
				from	dbo.billing_generate_detail bg
						inner join dbo.billing_scheme_detail bsd on bsd.asset_no = bg.asset_no
				--inner join dbo.agreement_main am
				--	on am.agreement_no = bsd.agreement_no
				where	bg.generate_code	= @p_code
						and bsd.scheme_code = @scheme_code ;

				-- ambil salah 1 agreement sebagai default 
				--SELECT @branch_code = BRANCH_CODE , @branch_name = @branch_name , @credit_term = CREDIT_TERM FROM dbo.AGREEMENT_MAIN
				--WHERE AGREEMENT_NO = @agreement_no
				--set @invoice_name = N'Invoice ' + @scheme_name + N' a.n ' + @client_name ;

				begin
				SELECT 'MASUK'

					--IF (@system_date <= @invoice_generate_date)
					--BEGIN
					set @invoice_due_date_top = dateadd(day, isnull(@credit_term, 0), @billing_date) ;

					--END;
					--ELSE
					--BEGIN
					--    SET @invoice_due_date_top = DATEADD(DAY, ISNULL(@credit_term, 0), @system_date);
					--END;
					exec dbo.xsp_invoice_insert @p_invoice_no				= @invoice_no output
												,@p_branch_code				= @branch_code
												,@p_branch_name				= @branch_name
												,@p_invoice_type			= 'RENTAL'
												,@p_invoice_date			= @invoice_generate_date
												,@p_invoice_due_date		= @invoice_due_date_top
												,@p_invoice_name			= ''
												,@p_invoice_status			= 'NEW'
												,@p_client_no				= @client_no
												,@p_client_name				= @client_npwp_name
												,@p_client_address			= @client_address
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
												,@p_scheme_code				= @scheme_code
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
												,@p_mod_ip_address			= @p_mod_ip_address ;

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

				declare curr_bill_generate cursor fast_forward read_only for
				select	bg.billing_no
						,bg.asset_no
						,bg.description
						,bg.rental_amount
						,aa.billing_to_faktur_type
						,aa.is_invoice_deduct_pph
						,aa.agreement_no
				from	dbo.billing_generate_detail bg
						inner join dbo.agreement_asset aa on (
																 aa.agreement_no		 = bg.agreement_no
																 and   aa.asset_no		 = bg.asset_no
															 )
						inner join dbo.billing_scheme_detail bsd on (
																		bsd.agreement_no = aa.agreement_no
																		and bsd.asset_no = aa.asset_no
																	)
						--left join dbo.et_main em on em.agreement_no = aa.agreement_no   --(+)raffy 2025/05/06 perubahan kondisi agar asset yang memiliki ET, Tidak bisa tergenerate invoice nya
						--left join dbo.et_detail ed on	(
						--									ed.et_code = em.code
						--									and ed.asset_no = aa.asset_no
						--									and ed.is_terminate = '1'
						--									AND em.ET_STATUS NOT IN ('CANCEL','EXPIRED')
						--								)
				where	bg.generate_code	= @p_code
						and bsd.scheme_code = @scheme_code
						and bg.invoice_no is null 
						-- sepria 31052025: untuk kondisi not in harusnya di bagian ini, jangan di left join di atas
						and	bg.asset_no not in (	select	etd.asset_no
													from	dbo.et_main em
															inner join dbo.et_detail etd on etd.et_code = em.code
													where	em.agreement_no = bg.agreement_no
													and		etd.asset_no = aa.asset_no
													and		etd.is_terminate = '1'
													and		em.et_status not in ('CANCEL','EXPIRED')
												) 

				open curr_bill_generate ;

				fetch next from curr_bill_generate
				into @billing_no
					 ,@asset_no_detail
					 ,@description_detail
					 ,@rental_amount
					 ,@billing_to_faktur_type
					 ,@is_invoice_deduct_pph
					 ,@agreement_no

				while @@fetch_status = 0
				begin 
					set @ppn_amount = round(((@rental_amount - 0) * 1 * @ppn_pct / 100),0) ;                    
					set @pph_amount = round(((@rental_amount - 0) * 1 * @pph_pct / 100),0) ;

					-- NON WAPU
					if (@billing_to_faktur_type = '01')
					begin			
						set @total_amount_detail = @rental_amount + @ppn_amount ;
					end ;
					--  WAPU
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

					update	dbo.agreement_asset_amortization
					set		invoice_no		= @invoice_no
							,generate_code	= @p_code
							--
							,mod_date		= @p_mod_date
							,mod_by			= @p_mod_by
							,mod_ip_address = @p_mod_ip_address
					where	asset_no	   = @asset_no_detail
							and billing_no = @billing_no ;

					update	dbo.billing_generate_detail
					set		invoice_no		= @invoice_no
							--
							,mod_date		= @p_mod_date
							,mod_by			= @p_mod_by
							,mod_ip_address = @p_mod_ip_address
					where	generate_code  = @p_code
							and billing_no = @billing_no
							and asset_no   = @asset_no_detail ;

					set @total_billing_amount = 0 ;
					set @total_discount_amount = 0 ;
					set @total_ppn_amount = 0 ;
					set @total_pph_amount = 0 ;
					set @total_amount = 0 ;

					fetch next from curr_bill_generate
					into @billing_no
						 ,@asset_no_detail
						 ,@description_detail
						 ,@rental_amount
						 ,@billing_to_faktur_type
						 ,@is_invoice_deduct_pph 
						 ,@agreement_no
				end ; 

				-- update ke header
				select	@total_billing_amount = sum(billing_amount)
						,@total_discount_amount = sum(discount_amount)
						,@total_ppn_amount = sum(ppn_amount)
						,@total_pph_amount = sum(pph_amount)
						,@total_amount = sum(total_amount)
						,@total_asset = count(asset_no)
				from	dbo.invoice_detail
				where	invoice_no = @invoice_no ;

				set @invoice_name = N'Sewa Kendaraan ' + cast(@total_asset as nvarchar(15)) + N' kendaraan terlampir untuk operasional ' + @client_name + N' sesuai dengan perjanjian Operating Lease No. terlampir tanggal terlampir' ;


				update	dbo.invoice
				set		total_billing_amount	= @total_billing_amount
						,total_discount_amount	= @total_discount_amount
						,total_ppn_amount		= @total_ppn_amount
						,total_pph_amount		= @total_pph_amount
						,total_amount			= @total_amount
						,invoice_name			= @invoice_name
						--
						,mod_date				= @p_mod_date
						,mod_by					= @p_mod_by
						,mod_ip_address			= @p_mod_ip_address
				where	invoice_no				= @invoice_no ;

				update	dbo.invoice_pph
				set		total_pph_amount	= @total_pph_amount
						--
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	invoice_no = @invoice_no ;

				close curr_bill_generate ;
				deallocate curr_bill_generate ;

				fetch next from curr_billing
				into @scheme_code
					 ,@scheme_name
					 ,@client_name
					 ,@client_no ;
			end ;

			close curr_billing ;
			deallocate curr_billing ;

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
