/*
exec dbo.invoice_to_agreement_invoice_insert @p_invoice_no = N'' -- nvarchar(50)
											 ,@p_mod_date = '2023-07-05 04.47.23' -- datetime
											 ,@p_mod_by = N'' -- nvarchar(15)
											 ,@p_mod_ip_address = N'' -- nvarchar(15)
*/

-- Louis Rabu, 05 Juli 2023 11.47.03 -- 
CREATE PROCEDURE [dbo].[invoice_to_agreement_invoice_insert]
(
	@p_invoice_no	   nvarchar(50)
	-- 
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					 nvarchar(max)
			,@code					 nvarchar(50)
			,@code_invoice_pph		 nvarchar(50)
			,@branch_code			 nvarchar(50)
			,@branch_name			 nvarchar(250)
			,@agreement_no			 nvarchar(50)  = ''
			,@asset_no				 nvarchar(50)  = ''
			,@billing_no			 int
			,@invoice_name			 nvarchar(250)
			,@ar_amount				 decimal(18, 2)
			,@ppn_amount			 int
			,@pph_amount			 int
			,@billing_amount		 decimal(18, 2)
			,@discount_amount		 decimal(18, 2)
			,@invoice_date			 datetime
			,@invoice_due_date		 datetime
			,@billing_to_faktur_type nvarchar(3)
			,@first_payment_type	 nvarchar(3)
			,@generate_code			 nvarchar(50)
			,@multiplier			 int 
			,@invoice_type			 nvarchar(10)
			,@trx_periode			 nvarchar(6)
			,@acc_periode			 nvarchar(6)

	begin try
		-- digunakan untuk mengambil acc periode
		select	@acc_periode = value
		from	dbo.sys_global_param
		where	code = 'ACCPERIODE' ;

		select	@branch_code = inv.branch_code
				,@branch_name = inv.branch_name
				,@invoice_date = inv.invoice_date
				,@invoice_due_date = inv.invoice_due_date
				,@invoice_name = inv.invoice_name
				,@generate_code = inv.generate_code
				,@billing_to_faktur_type = billing_to_faktur_type
				,@invoice_type = inv.invoice_type
				,@trx_periode = convert(varchar(6), inv.invoice_date, 112)
		from	dbo.invoice inv
		where	inv.invoice_no = @p_invoice_no ;
		
		if (@trx_periode < @acc_periode)
		begin
			set @invoice_date = dbo.xfn_get_system_date();
		end

		declare currInvoiceDetail cursor fast_forward read_only for
		select	invd.agreement_no
				,invd.asset_no
				,invd.billing_no
				,invd.billing_amount
				,invd.discount_amount
				,invd.ppn_amount
				,invd.pph_amount
				,aa.first_payment_type
				,mbt.multiplier
		from	dbo.invoice_detail invd
				inner join dbo.agreement_asset aa on (aa.asset_no	= invd.asset_no)
				inner join dbo.master_billing_type mbt on (mbt.code = aa.billing_type)
		where	invd.invoice_no = @p_invoice_no ;

		open currInvoiceDetail ;

		fetch next from currInvoiceDetail
		into @agreement_no
			 ,@asset_no
			 ,@billing_no
			 ,@billing_amount
			 ,@discount_amount
			 ,@ppn_amount
			 ,@pph_amount
			 ,@first_payment_type
			 ,@multiplier ;

		while @@fetch_status = 0
		begin
			-- WAPU
			if (@billing_to_faktur_type = '01')
			begin
				set @ar_amount = @billing_amount - @discount_amount + @ppn_amount ;
			end ;
			-- NON WAPU
			else
			begin
				set @ar_amount = @billing_amount - @discount_amount ;
			end ;
			
			    
			exec dbo.xsp_agreement_invoice_insert @p_code				= @code
												  ,@p_invoice_no		= @p_invoice_no
												  ,@p_agreement_no		= @agreement_no
												  ,@p_asset_no			= @asset_no
												  ,@p_billing_no		= @billing_no
												  ,@p_due_date			= @invoice_due_date
												  ,@p_invoice_date		= @invoice_date
												  ,@p_ar_amount			= @ar_amount
												  ,@p_description		= 'GENERATE INVOICE'
												  --
												  ,@p_cre_date			= @p_mod_date		
												  ,@p_cre_by			= @p_mod_by		
												  ,@p_cre_ip_address	= @p_mod_ip_address
												  ,@p_mod_date			= @p_mod_date		
												  ,@p_mod_by			= @p_mod_by		
												  ,@p_mod_ip_address	= @p_mod_ip_address
			
			exec dbo.xsp_agreement_invoice_pph_insert @p_code				= @code_invoice_pph
														,@p_invoice_no		= @p_invoice_no
														,@p_agreement_no	= @agreement_no
														,@p_asset_no		= @asset_no
														,@p_billing_no		= @billing_no
														,@p_due_date		= @invoice_due_date
														,@p_invoice_date	= @invoice_date
														,@p_pph_amount		= @pph_amount
														,@p_description		= 'GENERATE INVOICE'
														--
														,@p_cre_date		= @p_mod_date		
														,@p_cre_by			= @p_mod_by		
														,@p_cre_ip_address	= @p_mod_ip_address
														,@p_mod_date		= @p_mod_date		
														,@p_mod_by			= @p_mod_by		
														,@p_mod_ip_address	= @p_mod_ip_address
			
			-- generate agreement asset interest income if FIRST_PAYMENT_TYPE = 'ADVANCE'
			if (@first_payment_type = 'ADV' and @invoice_type <> 'PENALTY')
			begin
				exec dbo.xsp_agreement_asset_interest_income_generate @p_agreement_no		= @agreement_no
																		,@p_asset_no		= @asset_no
																		,@p_invoice_no		= @p_invoice_no
																		,@p_branch_code		= @branch_code
																		,@p_branch_name		= @branch_name
																		,@p_transaction_date= @invoice_date
																		,@p_income_amount	= @billing_amount
																		,@p_reff_no			= @p_invoice_no
																		,@p_reff_name		= @invoice_name
																		,@p_schedule_month	= @multiplier
																		,@p_billing_no		= @billing_no
																		--
																		,@p_cre_date		= @p_mod_date		
																		,@p_cre_by			= @p_mod_by		
																		,@p_cre_ip_address	= @p_mod_ip_address
																		,@p_mod_date		= @p_mod_date		
																		,@p_mod_by			= @p_mod_by		
																		,@p_mod_ip_address	= @p_mod_ip_address
			end
			
			if (@invoice_type = 'RENTAL')
			begin
				update	dbo.agreement_asset_amortization
				set		invoice_no			= @p_invoice_no
						,generate_code		= @generate_code
						--
						,mod_date			= @p_mod_date		
						,mod_by				= @p_mod_by		
						,mod_ip_address		= @p_mod_ip_address
				where	asset_no			= @asset_no
						and billing_no		= @billing_no ;

				update	dbo.agreement_information
				set		current_installment_no = @billing_no
						--
						,mod_date				= @p_mod_date
						,mod_by					= @p_mod_by
						,mod_ip_address			= @p_mod_ip_address
				where	agreement_no			= @agreement_no ;
			end
			
			

			fetch next from currInvoiceDetail
			into @agreement_no
				 ,@asset_no
				 ,@billing_no
				 ,@billing_amount
				 ,@discount_amount
				 ,@ppn_amount
				 ,@pph_amount
				 ,@first_payment_type
				 ,@multiplier ;
		end ;

		close currInvoiceDetail ;
		deallocate currInvoiceDetail ;
		
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

