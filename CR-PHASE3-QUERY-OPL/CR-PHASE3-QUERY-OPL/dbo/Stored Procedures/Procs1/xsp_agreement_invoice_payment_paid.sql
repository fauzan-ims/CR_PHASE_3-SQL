CREATE PROCEDURE dbo.xsp_agreement_invoice_payment_paid
(
	@p_invoice_no				nvarchar(50)
	,@p_payment_date			datetime
	,@p_transaction_no			nvarchar(50)
	,@p_voucher_no				nvarchar(50)
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)

as
begin
	declare @msg					  nvarchar(max)
			,@code_aggreement_invoice nvarchar(50)
			,@invoice_no			  nvarchar(50)
			,@agreement_no			  nvarchar(50)
			,@asset_no				  nvarchar(50)
			,@ar_amount				  decimal(18, 2)
			,@payment_amount		  decimal(18, 2) 
			,@total_payment_amount	  decimal(18, 2) ;

	begin try
		begin 
			 
			declare curr_aggr_inv_payment cursor fast_forward read_only for
			--pembayaran invoice tidak bisa partial
			select	code
					,invoice_no
					,agreement_no
					,asset_no 
					,ar_amount
					,payment_amount
			from	dbo.agreement_invoice ai
					outer apply --case pembayaran partial karena terjadi credit note, sehhinga nilai ar harus dikurangi pembayaran dari credit note
			(
				select	isnull(sum(isnull(aip.payment_amount, 0)), 0) 'payment_amount'
				from	dbo.agreement_invoice_payment aip
				where	(aip.agreement_invoice_code = ai.code)
			) aip
			where	invoice_no = @p_invoice_no ;

			open curr_aggr_inv_payment
			
			fetch next from curr_aggr_inv_payment 
			into @code_aggreement_invoice
				,@invoice_no
				,@agreement_no
				,@asset_no 
				,@ar_amount 
				,@payment_amount
			
			while @@fetch_status = 0
			begin 
				set @total_payment_amount = @ar_amount - @payment_amount

			    exec dbo.xsp_agreement_invoice_payment_insert @p_id								= 0
			    											  ,@p_agreement_invoice_code		= @code_aggreement_invoice
			    											  ,@p_invoice_no					= @invoice_no
			    											  ,@p_agreement_no					= @agreement_no
			    											  ,@p_asset_no						= @asset_no
															  ,@p_transaction_no				= @p_transaction_no
			    											  ,@p_transaction_type				= 'CASHIER'
			    											  ,@p_payment_date					= @p_payment_date
			    											  ,@p_payment_amount				= @total_payment_amount
															  ,@p_voucher_no					= @p_voucher_no
			    											  ,@p_description					= 'CASHIER RECEIVED'
															  --
			    											  ,@p_cre_date						= @p_mod_date		
			    											  ,@p_cre_by						= @p_mod_by			
			    											  ,@p_cre_ip_address				= @p_mod_ip_address
			    											  ,@p_mod_date						= @p_mod_date		
			    											  ,@p_mod_by						= @p_mod_by			
			    											  ,@p_mod_ip_address				= @p_mod_ip_address

				exec dbo.xsp_opl_interface_agreement_update_out_insert @p_agreement_no		= @agreement_no
																	   ,@p_mod_date			= @p_mod_date
																	   ,@p_mod_by			= @p_mod_by
																	   ,@p_mod_ip_address	= @p_mod_ip_address 
			    
			
				
				set @total_payment_amount = 0
			    fetch next from curr_aggr_inv_payment 
				into @code_aggreement_invoice
					,@invoice_no
					,@agreement_no
					,@asset_no 
					,@ar_amount 
					,@payment_amount
			
			end
			
			close curr_aggr_inv_payment
			deallocate curr_aggr_inv_payment
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







