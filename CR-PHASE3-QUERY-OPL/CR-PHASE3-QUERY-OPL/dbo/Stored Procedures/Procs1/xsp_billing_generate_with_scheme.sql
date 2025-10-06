

/*
exec dbo.xsp_billing_generate_with_scheme @p_code = N'' -- nvarchar(50)
										  ,@p_mod_date = '2023-03-17 03:28:53' -- datetime
										  ,@p_mod_by = N'' -- nvarchar(15)
										  ,@p_mod_ip_address = N'' -- nvarchar(15)
*/

-- Louis Handry 17/03/2023 -- 
CREATE PROCEDURE dbo.xsp_billing_generate_with_scheme
(
	@p_code		nvarchar(50)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg						 nvarchar(max)
			,@agreement_no				 nvarchar(50)
			,@agreement_external_no		 nvarchar(50)
			,@asset_no					 nvarchar(50)
			,@invoice_no				 nvarchar(50)
			,@branch_code				 nvarchar(50)
			,@branch_name				 nvarchar(250)
			,@date						 datetime
			,@client_no					 nvarchar(50)
			,@client_name				 nvarchar(250)
			,@as_of_date				 datetime
			,@due_date					 datetime
			,@invoice_name				 nvarchar(250)
			,@total_billing_amount		 decimal(18, 2)
			,@total_discount_amount		 decimal(18, 2)
			,@total_ppn_amount			 int
			,@total_pph_amount			 int
			,@total_amount				 decimal(18, 2)
			,@billing_no				 int
			,@asset_no_detail			 nvarchar(50)
			,@description_detail		 nvarchar(4000)
			,@rental_amount				 decimal(18, 2)
			,@ppn_pct					 decimal(9, 6)
			,@pph_pct					 decimal(9, 6)
			,@ppn_amount				 int
			,@pph_amount				 int
			,@total_amount_detail		 decimal(18, 2)
			,@code						 nvarchar(50)
			,@ar_amount					 decimal(18, 2)
			,@code_invoice_pph			 nvarchar(50)
			,@system_date				 datetime	   = dbo.xfn_get_system_date()
			,@settlement_type			 nvarchar(10)
			,@credit_term				 int
			,@fix_due_date				 datetime
			,@client_address			 nvarchar(4000)
			,@client_area_phone_no		 nvarchar(4)
			,@client_phone_no			 nvarchar(15)
			,@client_npwp				 nvarchar(50)
			,@currency_code				 nvarchar(3)
			,@billing_to_faktur_type	 nvarchar(3)
			,@is_invoice_deduct_pph		 nvarchar(1) 
			,@is_receipt_deduct_pph		 nvarchar(1)
			,@payment_reff_no			 nvarchar(50) 
			,@payment_reff_date			 datetime  
			,@settlement_status			 nvarchar(10) 
			,@multiplier				 int
			,@no						 int = 1 ;

	begin try 
		begin
			select @ppn_pct = value 
			from dbo.sys_global_param
			where code = ('RTAXPPN')

			select @pph_pct = value 
			from dbo.sys_global_param
			where code = ('RTAXPPH')

			declare curr_billing cursor fast_forward read_only for --cursor ini digunakan untuk mendapatkan distinc grouping invoice
			select	distinct bgd.agreement_no
					,am.agreement_external_no
					,am.branch_code
					,am.branch_name
					,am.client_no
					,aa.npwp_name -- Hari - 19.Sep.2023 06:08 PM --	nama client di invoice ambil dari NPWP
					--,aa.billing_to_name
					--,am.client_name -- (+) Ari 2023-09-13 ket : change billing to name to client name
					,am.credit_term
					,case
						 when aa.is_invoice_deduct_pph = '0' then 'NON PKP'
						 else 'PKP'
					 end
					,aa.npwp_address-- Hari - 19.Sep.2023 06:08 PM -- alamat invoice pakai yang di NPWP
					--,aa.billing_to_address
					,aa.billing_to_area_no
					,aa.billing_to_phone_no
					,aa.billing_to_npwp
					,am.currency_code
					,mbt.multiplier
					,aa.asset_no
			from	billing_generate_detail bgd
					inner join dbo.agreement_main am on (am.agreement_no = bgd.agreement_no)
					inner join dbo.agreement_asset aa on (aa.agreement_no = bgd.agreement_no and aa.asset_no = bgd.asset_no)
					inner join dbo.master_billing_type mbt on (mbt.code = am.billing_type)
			where	bgd.generate_code		  = @p_code
					and exists (
								select	bsd.agreement_no
								from	dbo.billing_scheme_detail bsd
										inner join dbo.billing_scheme bs on (
																				bs.code			 = bsd.scheme_code
																				and bs.is_active = '1'
																			)
								where	bsd.agreement_no = bgd.agreement_no
										and bsd.asset_no = bgd.asset_no
										--and bs.client_no = am.client_no
							) 
												
												
			open curr_billing
		
			fetch next from curr_billing 
			into @agreement_no
				,@agreement_external_no
				,@branch_code									
				,@branch_name									
				,@client_no										
				,@client_name									
				,@credit_term									
				,@settlement_type								
				,@client_address								
				,@client_area_phone_no							
				,@client_phone_no								
				,@client_npwp									
				,@currency_code
				,@multiplier
				,@asset_no
																   
			while @@fetch_status = 0							   
			begin 
				select	@due_date = max(due_date)
				from	dbo.billing_generate_detail bg
						inner join dbo.agreement_main am on (am.agreement_no = bg.agreement_no)
						inner join dbo.agreement_asset aa on (
																 aa.agreement_no   = bg.agreement_no
																 and   aa.asset_no = bg.asset_no
															 )
				where	generate_code		   = @p_code
						and am.client_no     = @client_no

				if (@system_date <= @due_date)
				begin
					set @date = @due_date
				end
				else
				begin
					set @date = @system_date
				end

				set @invoice_name = 'Invoice Rental Contract No ' + @agreement_external_no + ' a.n ' + @client_name
																 
				if not exists									 
				(
					select	1
					from	dbo.invoice inv
							inner join dbo.invoice_detail invd on (invd.invoice_no = inv.invoice_no)
					where	inv.generate_code	  = @p_code
							and inv.branch_code	  = @branch_code 
							and inv.client_no     = @client_no
							and inv.client_npwp   = @client_npwp
				)
				begin 
				
					if (@system_date <= @due_date)
					begin
						set @fix_due_date = dateadd(day, isnull(@credit_term, 0), @due_date) ;
					end
					else
					begin
						set @fix_due_date = dateadd(day, isnull(@credit_term, 0), @system_date) ;
					end
					
					select	@billing_to_faktur_type = billing_to_faktur_type
							,@is_invoice_deduct_pph = is_invoice_deduct_pph
							,@is_receipt_deduct_pph = is_receipt_deduct_pph
					from	dbo.agreement_asset
					where	asset_no = @asset_no ;


					exec dbo.xsp_invoice_insert @p_invoice_no						 = @invoice_no output
		    									,@p_branch_code						 = @branch_code
		    									,@p_branch_name						 = @branch_name
		    									,@p_invoice_type					 = 'RENTAL'
		    									,@p_invoice_date					 = @date
		    									,@p_invoice_due_date				 = @fix_due_date
		    									,@p_invoice_name					 = @invoice_name
		    									,@p_invoice_status					 = 'NEW'
		    									,@p_client_no						 = @client_no
		    									,@p_client_name						 = @client_name
		    									,@p_client_address					 = @client_address		
		    									,@p_client_area_phone_no			 = @client_area_phone_no	
		    									,@p_client_phone_no					 = @client_phone_no		
		    									,@p_client_npwp						 = @client_npwp			
		    									,@p_currency_code					 = @currency_code			
		    									,@p_total_billing_amount			 = 0
		    									,@p_total_discount_amount			 = 0
		    									,@p_total_ppn_amount				 = 0
		    									,@p_total_pph_amount				 = 0
		    									,@p_total_amount					 = 0
		    									,@p_faktur_no						 = ''
		    									,@p_generate_code					 = @p_code
		    									,@p_scheme_code						 = ''
		    									,@p_received_reff_no				 = ''
		    									,@p_received_reff_date				 = null
												,@p_billing_to_faktur_type			 = @billing_to_faktur_type
												,@p_is_invoice_deduct_pph			 = @is_invoice_deduct_pph
												,@p_is_receipt_deduct_pph			 = @is_receipt_deduct_pph
												--
		    									,@p_cre_date						 = @p_mod_date		
		    									,@p_cre_by							 = @p_mod_by			
		    									,@p_cre_ip_address					 = @p_mod_ip_address
		    									,@p_mod_date						 = @p_mod_date		
		    									,@p_mod_by							 = @p_mod_by			
		    									,@p_mod_ip_address					 = @p_mod_ip_address

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
													,@p_mod_ip_address		= @p_mod_ip_address
					
				end
				 
				declare curr_bill_generate cursor fast_forward read_only for
				select distinct
						bg.billing_no
						,bg.asset_no
						,bg.description
						,bg.rental_amount
						,aa.billing_to_faktur_type
						,aa.is_invoice_deduct_pph
				from	dbo.billing_generate_detail bg
						inner join dbo.agreement_asset aa on (aa.agreement_no = bg.agreement_no and aa.asset_no = bg.asset_no)
				where	generate_code		   = @p_code 
						and bg.asset_no		   = @asset_no
						and bg.agreement_no	   = @agreement_no
						and aa.billing_to_name = @client_no
						and bg.invoice_no		is null

				open curr_bill_generate
			
				fetch next from curr_bill_generate 
				into @billing_no
					,@asset_no_detail
					,@description_detail
					,@rental_amount
					,@billing_to_faktur_type
					,@is_invoice_deduct_pph

				while @@fetch_status = 0
				begin
					set @ppn_amount = (@rental_amount - 0) * 1 * @ppn_pct / 100
					set @pph_amount = (@rental_amount - 0) * 1 * @pph_pct / 100

					-- WAPU
					if (@billing_to_faktur_type = '01')
					begin
						set @total_amount_detail = @rental_amount + @ppn_amount;
					end ;
					-- NON WAPU
					else
					begin
						set @total_amount_detail = @rental_amount;
					end ; 

					--jika potong pph 
					if (@is_invoice_deduct_pph = '1')
					begin
						set @total_amount_detail = @total_amount_detail - @pph_amount

						set @payment_reff_no	 = null
						set @payment_reff_date	 = null
						set @settlement_status	 = 'HOLD';
					end 
					else
					begin
						set @payment_reff_no	 = 'NOT DEDUCT PPH'
						set @payment_reff_date	 = dbo.xfn_get_system_date();
						set @settlement_status	 = 'POST';
					end
							
					exec dbo.xsp_invoice_detail_insert @p_id							= 0
													   ,@p_invoice_no					= @invoice_no
													   ,@p_agreement_no					= @agreement_no
													   ,@p_asset_no						= @asset_no_detail
													   ,@p_billing_no					= @billing_no
													   ,@p_description					= @description_detail
													   ,@p_quantity						= 1
													   ,@p_billing_amount				= @rental_amount
													   ,@p_discount_amount				= 0
													   ,@p_ppn_pct						= @ppn_pct
													   ,@p_ppn_amount					= @ppn_amount
													   ,@p_pph_pct						= @pph_pct
													   ,@p_pph_amount					= @pph_amount
													   ,@p_total_amount					= @total_amount_detail
													   ,@p_tax_scheme_code				= ''
													   ,@p_tax_scheme_name				= ''
													   ,@p_cre_date						= @p_mod_date		
													   ,@p_cre_by						= @p_mod_by		
													   ,@p_cre_ip_address				= @p_mod_ip_address
													   ,@p_mod_date						= @p_mod_date		
													   ,@p_mod_by						= @p_mod_by		
													   ,@p_mod_ip_address				= @p_mod_ip_address
				

					update	dbo.agreement_asset_amortization
					set		invoice_no			= @invoice_no
							,generate_code		= @p_code
							--
							,mod_date			= @p_mod_date		
							,mod_by				= @p_mod_by		
							,mod_ip_address		= @p_mod_ip_address
					where	asset_no			= @asset_no_detail
							and billing_no		= @billing_no ;
				
					select @total_billing_amount	= sum(billing_amount)
							,@total_discount_amount	= sum(discount_amount)
							,@total_ppn_amount		= sum(ppn_amount)
							,@total_pph_amount		= sum(pph_amount)
							,@total_amount			= sum(total_amount)
					from dbo.invoice_detail
					where invoice_no				= @invoice_no

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
					where	invoice_no				= @invoice_no ;

					update	dbo.invoice_pph
					set		total_pph_amount	= @total_pph_amount
							,payment_reff_no	= @payment_reff_no	
							,payment_reff_date	= @payment_reff_date	
							,settlement_status	= @settlement_status	
							--
							,mod_date			= @p_mod_date
							,mod_by				= @p_mod_by
							,mod_ip_address		= @p_mod_ip_address
					where	invoice_no			= @invoice_no ;

					update	dbo.billing_generate_detail
					set		invoice_no			= @invoice_no 
							--
							,mod_date			= @p_mod_date
							,mod_by				= @p_mod_by
							,mod_ip_address		= @p_mod_ip_address
					where	generate_code	    = @p_code 
							and billing_no	    = @billing_no
							and asset_no	    = @asset_no
							and agreement_no    = @agreement_no
							
					update	dbo.agreement_asset_amortization
					set		generate_code		= @p_code
							--
							,mod_date			= @p_mod_date		
							,mod_by				= @p_mod_by		
							,mod_ip_address		= @p_mod_ip_address
					where	asset_no			= @asset_no
							and billing_no		= @billing_no ;
							 
			    	
					set @total_billing_amount	= 0
					set @total_discount_amount	= 0
					set @total_ppn_amount		= 0
					set @total_pph_amount		= 0
					set @total_amount			= 0

					fetch next from curr_bill_generate 
					into @billing_no
						,@asset_no_detail
						,@description_detail
						,@rental_amount
						,@billing_to_faktur_type
						,@is_invoice_deduct_pph
				end
			
				close curr_bill_generate
				deallocate curr_bill_generate
		
				fetch next from curr_billing 
				into @agreement_no
					,@agreement_external_no
					,@branch_code									
					,@branch_name									
					,@client_no										
					,@client_name									
					,@credit_term									
					,@settlement_type								
					,@client_address								
					,@client_area_phone_no							
					,@client_phone_no								
					,@client_npwp									
					,@currency_code
					,@multiplier
					,@asset_no
				end
		
			close curr_billing
			deallocate curr_billing	
		end
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
