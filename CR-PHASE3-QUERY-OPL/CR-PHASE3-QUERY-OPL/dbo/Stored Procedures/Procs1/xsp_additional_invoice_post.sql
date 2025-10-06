CREATE PROCEDURE dbo.xsp_additional_invoice_post
(
	@p_code					   nvarchar(50)
	--
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
begin
	declare @msg							nvarchar(max)
			,@agreement_no					nvarchar(50)
			,@invoice_no					nvarchar(50)
			,@asset_no						nvarchar(50)
			,@billing_amount				decimal(18, 2)
			,@discount_amount				decimal(18, 2)
			,@ppn_amount					int
			,@pph_amount					int
			,@total_amount					decimal(18, 2)
			,@tax_scheme_code				nvarchar(50)
			,@tax_scheme_name				nvarchar(250)
			,@billing_no					int
			,@quantity						int
			,@ppn_pct						decimal(9, 6)
			,@pph_pct						decimal(9, 6)
			,@client_no						nvarchar(50)
			,@clinet_name					nvarchar(250)
			,@date							datetime
			,@due_date						datetime
			,@invoice_name					nvarchar(250)
			,@description					nvarchar(250)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@invoice_type					nvarchar(10)
			,@agreement_external_no			nvarchar(50)
			,@invoice_type_desc				nvarchar(50)
			,@currency_code					nvarchar(3)
			,@client_address				nvarchar(4000)
			,@client_area_phone_no			nvarchar(5)
			,@client_phone_no				nvarchar(15)
			,@client_npwp					nvarchar(50)
			,@billing_to_faktur_type		nvarchar(3)
			,@is_invoice_deduct_pph			nvarchar(1) 
			,@is_receipt_deduct_pph			nvarchar(1)
			,@payment_reff_no				nvarchar(50)
			,@payment_reff_date				datetime
			,@settlement_type				nvarchar(10)
			,@settlement_status				nvarchar(10)
			,@total_detail_billing_amount   decimal(18, 2)
			,@total_detail_discount_amount  decimal(18, 2)
			,@total_detail_ppn_amount	    decimal(18, 2)
			,@total_detail_pph_amount	    decimal(18, 2)
			,@total_detail_amount		    decimal(18, 2)

	begin try

		if exists
		(
			select	1
			from	dbo.additional_invoice_detail
			where	additional_invoice_code			= @p_code
					and isnull(tax_scheme_code, '') = ''
		)
		begin
			set @msg = N'Please select tax scheme at additional detail' ;

			raiserror(@msg, 16, -1) ;
		end ;
		if exists
		(
			select	1
			from	dbo.additional_invoice
			where	invoice_due_date is null
					and code = @p_code
		)
		begin
			set @msg = N'please fill due date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		select	@client_no = ai.client_no
				,@clinet_name = ai.client_name
				,@date = ai.invoice_date
				,@due_date = ai.invoice_due_date
				,@branch_code = ai.branch_code
				,@branch_name = ai.branch_name
				,@invoice_type = ai.invoice_type
				,@agreement_external_no = am.agreement_external_no
				,@invoice_type_desc = sgs.description
				,@currency_code = am.currency_code
				,@client_address = ai.client_address
				,@client_area_phone_no = ai.client_area_phone_no
				,@client_phone_no = ai.client_phone_no
				,@client_npwp = ai.client_npwp
				,@asset_no = aid.asset_no
		from	dbo.additional_invoice_detail aid
				inner join dbo.additional_invoice ai on (ai.code	 = aid.additional_invoice_code)
				inner join dbo.agreement_main am on (am.agreement_no = aid.agreement_no)
				inner join dbo.sys_general_subcode sgs on (sgs.code	 = ai.invoice_type)
		where	additional_invoice_code = @p_code ;
		
		select	@billing_to_faktur_type = billing_to_faktur_type
				,@is_invoice_deduct_pph = is_invoice_deduct_pph
				,@is_receipt_deduct_pph = is_receipt_deduct_pph
				,@settlement_type		= case
												when is_invoice_deduct_pph = '0' then 'NON PKP'
												else 'PKP'
											END
		from	dbo.agreement_asset
		where	asset_no = @asset_no ;

		set @invoice_name = 'invoice ' + @invoice_type_desc + ' ' + @agreement_external_no + ' client ' + @clinet_name

		exec dbo.xsp_invoice_insert @p_invoice_no				= @invoice_no output						    
									,@p_branch_code				= @branch_code								    
									,@p_branch_name				= @branch_name								    
									,@p_invoice_type			= @invoice_type								    
									,@p_invoice_date			= @date										    
									,@p_invoice_due_date		= @due_date									    
									,@p_invoice_name			= @invoice_name								    
									,@p_invoice_status			= 'NEW'										    
									,@p_client_no				= @client_no								    
									,@p_client_name				= @clinet_name								    
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
									,@p_faktur_no			    = ''
									,@p_generate_code		    = ''
									,@p_scheme_code			    = ''				   
									,@p_received_reff_no	  	= ''				   
									,@p_received_reff_date	    = ''				   
									,@p_additional_invoice_code = @p_code				   
									,@p_billing_to_faktur_type  = @billing_to_faktur_type				   
									,@p_is_invoice_deduct_pph   = @is_invoice_deduct_pph				   
									,@p_is_receipt_deduct_pph   = @is_receipt_deduct_pph
									,@p_billing_date			= @date
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
		
		declare curr_add_invoice cursor fast_forward read_only for

		select aid.agreement_no
			  ,asset_no
			  ,aid.tax_scheme_code
			  ,tax_scheme_name
			  ,billing_no
			  ,aid.description
			  ,quantity
			  ,billing_amount
			  ,discount_amount
			  ,aid.ppn_pct
			  ,ppn_amount
			  ,aid.pph_pct
			  ,pph_amount
			  ,aid.total_amount
			  ,ai.client_no
			  ,ai.client_name
			  ,ai.invoice_date
			  ,ai.invoice_due_date
			  ,ai.branch_code
			  ,ai.branch_name
			  ,ai.invoice_type
			  ,am.agreement_external_no
			  ,sgs.description
			  ,am.currency_code
			  ,ai.client_address
			  ,ai.client_area_phone_no
			  ,ai.client_phone_no
			  ,ai.client_npwp
		from dbo.additional_invoice_detail aid
		inner join dbo.additional_invoice ai on (ai.code = aid.additional_invoice_code)
		inner join dbo.agreement_main am on (am.agreement_no = aid.agreement_no)
		inner join dbo.sys_general_subcode sgs on (sgs.code = ai.invoice_type)
		where additional_invoice_code = @p_code
		
		open curr_add_invoice
		
		fetch next from curr_add_invoice 
		into @agreement_no
			,@asset_no
			,@tax_scheme_code
			,@tax_scheme_name
			,@billing_no
			,@description
			,@quantity
			,@billing_amount
			,@discount_amount
			,@ppn_pct
			,@ppn_amount
			,@pph_pct
			,@pph_amount
			,@total_amount
			,@client_no
			,@clinet_name
			,@date
			,@due_date
			,@branch_code
			,@branch_name
			,@invoice_type				
			,@agreement_external_no	
			,@invoice_type_desc
			,@currency_code
			,@client_address		
			,@client_area_phone_no	
			,@client_phone_no		
			,@client_npwp			
		
		while @@fetch_status = 0
		begin

			-- wapu
			if (@billing_to_faktur_type = '01')
			begin
				set @total_amount = (@billing_amount - @discount_amount) + @ppn_amount ;
			end ;
			-- non wapu
			else
			begin
				set @total_amount = (@billing_amount - @discount_amount) ;
			end ;

			--jika potong pph 
			if (@is_invoice_deduct_pph = '1')
			begin
				set @total_amount = @total_amount - @pph_amount

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

			--exec dbo.xsp_invoice_insert @p_invoice_no				 = @invoice_no output
			--							,@p_branch_code				 = @branch_code
			--							,@p_branch_name				 = @branch_name
			--							,@p_invoice_type			 = @invoice_type
			--							,@p_invoice_date			 = @date
			--							,@p_invoice_due_date		 = @due_date
			--							,@p_invoice_name			 = @invoice_name
			--							,@p_invoice_status			 = 'new'
			--							,@p_client_no				 = @client_no
			--							,@p_client_name				 = @clinet_name
			--							,@p_client_address			 = @client_address
			--							,@p_client_area_phone_no	 = @client_area_phone_no
			--							,@p_client_phone_no			 = @client_phone_no
			--							,@p_client_npwp				 = @client_npwp
			--							,@p_currency_code			 = @currency_code
			--							,@p_total_billing_amount	 = @billing_amount
			--							,@p_total_discount_amount	 = @discount_amount
			--							,@p_total_ppn_amount		 = @ppn_amount
			--							,@p_total_pph_amount		 = @pph_amount
			--							,@p_total_amount			 = @total_amount
			--							,@p_faktur_no				 = ''
			--							,@p_generate_code			 = ''
			--							,@p_scheme_code				 = ''
			--							,@p_received_reff_no		 = ''
			--							,@p_received_reff_date		 = ''
			--							,@p_additional_invoice_code  = @p_code
			--							,@p_billing_to_faktur_type	 = @billing_to_faktur_type
			--							,@p_is_invoice_deduct_pph	 = @is_invoice_deduct_pph
			--							,@p_is_receipt_deduct_pph	 = @is_receipt_deduct_pph
			--							--
			--							,@p_cre_date				 = @p_mod_date		
			--							,@p_cre_by					 = @p_mod_by			
			--							,@p_cre_ip_address			 = @p_mod_ip_address
			--							,@p_mod_date				 = @p_mod_date		
			--							,@p_mod_by					 = @p_mod_by			
			--							,@p_mod_ip_address			 = @p_mod_ip_address
											
			--exec dbo.xsp_invoice_pph_insert @p_id					= 0
			--								,@p_invoice_no			= @invoice_no
			--								,@p_settlement_type		= @settlement_type
			--								,@p_settlement_status	= n'hold'
			--								,@p_file_path			= null
			--								,@p_file_name			= null
			--								,@p_payment_reff_no		= @payment_reff_no	
			--								,@p_payment_reff_date	= @payment_reff_date	
			--								,@p_total_pph_amount	= @pph_amount
			--								--
			--								,@p_cre_date			= @p_mod_date		
			--								,@p_cre_by				= @p_mod_by			
			--								,@p_cre_ip_address		= @p_mod_ip_address
			--								,@p_mod_date			= @p_mod_date		
			--								,@p_mod_by				= @p_mod_by			
			--								,@p_mod_ip_address		= @p_mod_ip_address
			
			exec dbo.xsp_invoice_detail_insert @p_id					= 0
											   ,@p_invoice_no			= @invoice_no
											   ,@p_agreement_no			= @agreement_no
											   ,@p_asset_no				= @asset_no
											   ,@p_billing_no			= @billing_no
											   ,@p_description			= @description
											   ,@p_quantity				= @quantity
											   ,@p_tax_scheme_code		= @tax_scheme_code
											   ,@p_tax_scheme_name		= @tax_scheme_name
											   ,@p_billing_amount		= @billing_amount
											   ,@p_discount_amount		= @discount_amount
											   ,@p_ppn_amount			= @ppn_amount
											   ,@p_pph_amount			= @pph_amount
											   ,@p_total_amount			= @total_amount	
											   ,@p_ppn_pct				= @ppn_pct
											   ,@p_pph_pct				= @pph_pct
											   --
											   ,@p_cre_date				= @p_mod_date		
											   ,@p_cre_by				= @p_mod_by			
											   ,@p_cre_ip_address		= @p_mod_ip_address
											   ,@p_mod_date				= @p_mod_date		
											   ,@p_mod_by				= @p_mod_by			
											   ,@p_mod_ip_address		= @p_mod_ip_address
			
			select	@total_detail_billing_amount = sum(billing_amount)
					,@total_detail_discount_amount = sum(discount_amount)
					,@total_detail_ppn_amount = sum(ppn_amount)
					,@total_detail_pph_amount = sum(pph_amount)
					,@total_detail_amount = sum(total_amount)
			from	dbo.invoice_detail
			where	invoice_no = @invoice_no ;

			update	dbo.invoice
			set		total_billing_amount	= @total_detail_billing_amount
					,total_discount_amount	= @total_detail_discount_amount
					,total_ppn_amount		= @total_detail_ppn_amount
					,total_pph_amount		= @total_detail_pph_amount
					,total_amount			= @total_detail_amount
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	invoice_no				= @invoice_no ;

			update	dbo.invoice_pph
			set		total_pph_amount	= @total_detail_pph_amount
					,payment_reff_no	= @payment_reff_no
					,payment_reff_date	= @payment_reff_date
					,settlement_status	= @settlement_status
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	invoice_no			= @invoice_no ;

			-- update agreement status
			begin
				exec dbo.xsp_agreement_update_sub_status @p_invoice_no		= @invoice_no
														 ,@p_mod_date		= @p_mod_date		
														 ,@p_mod_by			= @p_mod_by			
														 ,@p_mod_ip_address = @p_mod_ip_address
				
			end
			SELECT @invoice_type'@invoice_type'
			if (@invoice_type in ('PENALTY','LATE RETURN','LATERETURN')) -- + alter rian 08/07/2023 penambahan utuk obligation
			begin
				update	dbo.agreement_obligation
				set		invoice_no		= @invoice_no
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address	= @p_mod_ip_address
				where	agreement_no	= @agreement_no
				and		asset_no		= @asset_no
				and		obligation_type	in('CETP','LRAP')

				select	@total_detail_billing_amount = sum(billing_amount)
				from	dbo.invoice_detail
				where	invoice_no		= @invoice_no
						and asset_no	= @asset_no

				--raffy (2025/08/07) cr fase 3
				update	dbo.agreement_asset_late_return
				set		invoice_no		= @invoice_no
						,invoice_amount	= @total_detail_billing_amount
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address	= @p_mod_ip_address
				where	agreement_no	= @agreement_no
				and		asset_no		= @asset_no
			end

			set @billing_amount	 = 0;
			set @discount_amount = 0;
			set @ppn_amount		 = 0;
			set @pph_amount		 = 0;
			set @total_amount	 = 0;
		
			fetch next from curr_add_invoice 
			into @agreement_no
				,@asset_no
				,@tax_scheme_code
				,@tax_scheme_name
				,@billing_no
				,@description
				,@quantity
				,@billing_amount
				,@discount_amount
				,@ppn_pct
				,@ppn_amount
				,@pph_pct
				,@pph_amount
				,@total_amount
				,@client_no
				,@clinet_name
				,@date
				,@due_date
				,@branch_code
				,@branch_name
				,@invoice_type			
				,@agreement_external_no	
				,@invoice_type_desc
				,@currency_code
				,@client_address		
				,@client_area_phone_no	
				,@client_phone_no		
				,@client_npwp			
			end
		
		close curr_add_invoice
		deallocate curr_add_invoice

		begin -- insert untuk selisih ppn hitungan ifin dengan coretax
		--(+) sepria 06032025: cr dpp ppn 12% coretax
			exec dbo.xsp_invoice_update_dpp_nilai_lain @p_invoice_no = @invoice_no,          
														@p_mod_date = @p_mod_date,
														@p_mod_by = @p_mod_by,
														@p_mod_ip_address = @p_mod_ip_address
		end

		if exists
		(
			select	1
			from	dbo.additional_invoice
			where	code			   = @p_code
			and		invoice_status	   = 'HOLD'
		)
		begin

			update	dbo.additional_invoice
			set		invoice_status			= 'POST'
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	code					= @p_code ;
			
			-- untuk mengupdate additional invoice per reff code
			exec dbo.xsp_additional_invoice_request_update @p_code				= @p_code
														   ,@p_status			= 'POST'
														   ,@p_mod_date			= @p_mod_date
														   ,@p_mod_by			= @p_mod_by
														   ,@p_mod_ip_address	= @p_mod_ip_address
		end ;
		else
		begin
			set @msg = 'Data already post';
			raiserror(@msg, 16, 1) ;
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

