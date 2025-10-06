CREATE PROCEDURE dbo.xsp_pph_payment_paid
(
	@p_code					nvarchar(50)
	,@p_process_reff_no		nvarchar(50)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)

as
begin
	declare @msg					nvarchar(max)
			,@tax_payment_code		nvarchar(50)
			,@invoice_no			nvarchar(50)
			,@pph_amount			decimal(18,2)
			,@agreement_no			nvarchar(50)
			,@asset_no				nvarchar(50)
			,@date					datetime
	
	begin try
		begin 
			set @date = dbo.xfn_get_system_date()

			update	dbo.invoice_pph_payment
			set		status				= 'PAID'
					,process_date		= @p_mod_date
					,process_reff_no	= @p_process_reff_no
					,process_reff_name	= 'PAYMENT CONFIRM'
					--
					,cre_date			= @p_mod_date		
					,cre_by				= @p_mod_by			
					,cre_ip_address		= @p_mod_ip_address
					,mod_date			= @p_mod_date		
					,mod_by				= @p_mod_by			
					,mod_ip_address		= @p_mod_ip_address
			where code = @p_code
			
			declare curr_pph_payment_paid cursor fast_forward read_only for
			select code
				  ,aip.invoice_no
				  ,aip.pph_amount
				  ,aip.agreement_no
				  ,aip.asset_no
			from dbo.agreement_invoice_pph aip
			inner join dbo.invoice_pph_payment_detail ippd on ippd.invoice_no = aip.invoice_no
			where ippd.tax_payment_code = @p_code
			
			open curr_pph_payment_paid
			
			fetch next from curr_pph_payment_paid 
			into @tax_payment_code
				,@invoice_no
				,@pph_amount
				,@agreement_no
				,@asset_no
			
			while @@fetch_status = 0
			begin
			    exec dbo.xsp_agreement_invoice_pph_settlement_insert @p_id								= 0
																	,@p_agreement_invoice_pph_code		= @tax_payment_code
																	,@p_invoice_no						= @invoice_no
																	,@p_agreement_no					= @agreement_no
																	,@p_asset_no						= @asset_no
																	,@p_transaction_no					= @p_process_reff_no
																	,@p_transaction_type				= 'PAYMENT'
																	,@p_payment_date					= @date
																	,@p_payment_amount					= @pph_amount
																	,@p_description						= 'PAYMENT REQUEST'
																	,@p_cre_date						= @p_mod_date		
																	,@p_cre_by							= @p_mod_by			
																	,@p_cre_ip_address					= @p_mod_ip_address
																	,@p_mod_date						= @p_mod_date		
																	,@p_mod_by							= @p_mod_by			
																	,@p_mod_ip_address					= @p_mod_ip_address
			
			    fetch next from curr_pph_payment_paid 
				into @tax_payment_code
					,@invoice_no
					,@pph_amount
					,@agreement_no
					,@asset_no
			end
			
			close curr_pph_payment_paid
			deallocate curr_pph_payment_paid
			
		end
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
	
end



