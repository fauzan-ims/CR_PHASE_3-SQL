/*
exec dbo.xsp_credit_note_to_agreement_invoice_payment @p_credit_note_code = N'' -- nvarchar(50)
													  ,@p_cre_date = '2023-06-21 15.01.04' -- datetime
													  ,@p_cre_by = N'' -- nvarchar(15)
													  ,@p_cre_ip_address = N'' -- nvarchar(15)
													  ,@p_mod_date = '2023-06-21 15.01.04' -- datetime
													  ,@p_mod_by = N'' -- nvarchar(15)
													  ,@p_mod_ip_address = N'' -- nvarchar(15)
*/

-- Louis Rabu, 21 Juni 2023 22.00.55 --
CREATE PROCEDURE dbo.xsp_credit_note_to_agreement_invoice_payment
(
	@p_credit_note_code			nvarchar(50) 
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)

as
begin
	declare @msg					  nvarchar(max)
			,@code_aggreement_invoice nvarchar(50)
			,@billing_to_faktur_type  nvarchar(3)
			,@invoice_no			  nvarchar(50)
			,@agreement_no			  nvarchar(50)
			,@asset_no				  nvarchar(50)
			,@billing_no			  int
			,@due_date				  datetime
			,@invoice_date			  datetime
			,@ar_amount				  decimal(18, 2)
			,@adjustment_amount		  decimal(18, 2)
			,@ppn_amount			  bigint
			,@ppn_pct				  decimal(9, 6)
			,@description			  nvarchar(4000)
			,@date					  datetime ;
	
	begin try
		begin 
			select	@ppn_pct = ppn_pct
			from	dbo.credit_note
			where	code = @p_credit_note_code ;

			declare curr_aggr_inv_payment cursor fast_forward read_only for
			select	ai.code
					,cnd.invoice_no
					,ai.agreement_no
					,ai.asset_no
					,ai.billing_no
					,ai.due_date
					,ai.invoice_date
					,cnd.adjustment_amount
					,ai.description
			from	dbo.credit_note_detail cnd
					inner join dbo.invoice_detail ivd on (
															 ivd.id				  = cnd.invoice_detail_id
															 and   ivd.invoice_no = cnd.invoice_no
														 )
					inner join agreement_invoice ai on (
														   ai.invoice_no		  = ivd.invoice_no
														   and ai.asset_no		  = ivd.asset_no
														   and ai.billing_no	  = ivd.billing_no
													   )
			where	cnd.credit_note_code	  = @p_credit_note_code
					and cnd.adjustment_amount > 0 ;

			open curr_aggr_inv_payment
			
			fetch next from curr_aggr_inv_payment 
			into @code_aggreement_invoice
				,@invoice_no
				,@agreement_no
				,@asset_no
				,@billing_no
				,@due_date
				,@invoice_date
				,@adjustment_amount
				,@description
			
			while @@fetch_status = 0
			begin
				set @date = dbo.xfn_get_system_date()
		
				select 	@billing_to_faktur_type = billing_to_faktur_type
				from	dbo.invoice
				where	invoice_no = @invoice_no ;

				-- WAPU
				if (@billing_to_faktur_type = '01')
				begin
					set @ppn_amount = (@adjustment_amount - 0) * 1 * (@ppn_pct / 100) ;

					--set @ar_amount = @adjustment_amount + @ppn_amount ;
					
					set @ar_amount = round((@adjustment_amount + @ppn_amount),0) -- (+) Ari 2024-03-21 ket : round nornal
				end ;
				-- NON WAPU
				else
				begin
					set @ar_amount = @adjustment_amount ;
				END ;

			    EXEC dbo.xsp_agreement_invoice_payment_insert @p_id								= 0
			    											  ,@p_agreement_invoice_code		= @code_aggreement_invoice
			    											  ,@p_invoice_no					= @invoice_no
			    											  ,@p_agreement_no					= @agreement_no
			    											  ,@p_asset_no						= @asset_no
															  ,@p_transaction_no				= @p_credit_note_code
			    											  ,@p_transaction_type				= 'CREDIT NOTE'
			    											  ,@p_payment_date					= @date
			    											  ,@p_payment_amount				= @ar_amount
															  ,@p_voucher_no					= @p_credit_note_code
			    											  ,@p_description					= 'CREDIT NOTE'
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
			    
				set @ppn_amount = 0;
				set @ar_amount = 0;
			    fetch next from curr_aggr_inv_payment 
				into @code_aggreement_invoice
					,@invoice_no
					,@agreement_no
					,@asset_no
					,@billing_no
					,@due_date
					,@invoice_date
					,@adjustment_amount
					,@description
			
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
