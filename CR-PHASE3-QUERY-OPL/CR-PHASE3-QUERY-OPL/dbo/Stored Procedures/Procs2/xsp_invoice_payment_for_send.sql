CREATE PROCEDURE [dbo].[xsp_invoice_payment_for_send]
(
	@p_invoice_no			   nvarchar(50)
	--
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) 
			,@sum_ppn_amount_detail		decimal(18,2)
			,@total_ppn_amount			decimal(18,2)

	begin try		
	
		if exists
		(
			select	1
			from	dbo.invoice
			where	invoice_no				= @p_invoice_no
			and		isnull(faktur_no, '')	= ''
			and		total_ppn_amount > 0
		)
		begin
			set	@msg = 'Please Allocate Faktur for Invoice ' + @p_invoice_no
			raiserror (@msg, 16, -1)
		end
        
		--(+) sepria 06032025: cr dpp ppn 12% coretax, cek jika nilai total ppn di detail beda dengan nilai ppn di header
		select	@sum_ppn_amount_detail	= sum(ppn_amount)
		from	dbo.invoice_detail
		where	invoice_no = @p_invoice_no

		select	@total_ppn_amount	= total_ppn_amount
		from	dbo.invoice
		where	invoice_no = @p_invoice_no ;

		if(isnull(@sum_ppn_amount_detail,0) <> isnull(@total_ppn_amount,0))
		begin
		    set	@msg = 'Total PPN Amount Header and Detail Not Match For Invoice No ' + @p_invoice_no
			raiserror (@msg, 16, -1)
		end

		
		if exists
		(
			select	1
			from	dbo.invoice
			where	invoice_no		= @p_invoice_no
			and		invoice_status	= 'NEW'
		)
		begin
			update	dbo.invoice
			set		invoice_status			= 'POST'
					,POSTING_DATE			= @p_mod_date
					,POSTING_BY				= @p_mod_by
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	invoice_no				= @p_invoice_no ;
		
			-- bentuk ar ledger
			begin
				exec dbo.invoice_to_agreement_invoice_insert @p_invoice_no		= @p_invoice_no
															 ,@p_mod_date		= @p_mod_date
															 ,@p_mod_by			= @p_mod_by
															 ,@p_mod_ip_address = @p_mod_ip_address
				
			end

			-- bentuk cashier received
			begin
				exec dbo.invoice_to_interface_cashier_receive_insert @p_invoice_no		= @p_invoice_no
																	 ,@p_mod_date		= @p_mod_date
																	 ,@p_mod_by			= @p_mod_by
																	 ,@p_mod_ip_address = @p_mod_ip_address
			
			end
			
			--bentuk journal
			if not exists
				(
					select	1
					from	dbo.invoice
					where	invoice_no				= @p_invoice_no
					and		invoice_type			IN ('PENALTY','LATERETURN') -- RAFFY 2025/08/06 CR FASE 3
				)
			begin
		 
				exec dbo.xsp_invoice_journal @p_reff_name		= 'INVOICE GENERATE'
											 ,@p_reff_code		= @p_invoice_no
											 ,@p_value_date		= @p_mod_date
											 ,@p_trx_date		= @p_mod_date
											 ,@p_mod_date		= @p_mod_date
											 ,@p_mod_by			= @p_mod_by
											 ,@p_mod_ip_address = @p_mod_ip_address
			end

			-- update agreement status
			begin
				exec dbo.xsp_agreement_update_sub_status @p_invoice_no		= @p_invoice_no
														 ,@p_mod_date		= @p_mod_date		
														 ,@p_mod_by			= @p_mod_by			
														 ,@p_mod_ip_address = @p_mod_ip_address
				
			end
			

		end ;
		else
		begin
			set @msg = 'Data already proceed.';
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

