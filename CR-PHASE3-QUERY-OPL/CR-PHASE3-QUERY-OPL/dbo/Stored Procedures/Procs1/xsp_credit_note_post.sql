CREATE PROCEDURE dbo.xsp_credit_note_post
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
			,@invoice_no			 nvarchar(50)
			,@billing_amount		 decimal(18, 2)
			,@new_ppn_amount		 int
			,@new_pph_amount		 int
			,@total_pph_amount		 decimal(18, 2) 
			,@agreement_no			 nvarchar(50)
			,@new_total_total_amount decimal(18, 2) --raffi

	begin try
		select @invoice_no				= cn.invoice_no
			  ,@billing_amount			= cnd.adjustment_amount
			  ,@new_ppn_amount			= cn.new_ppn_amount
			  ,@new_pph_amount			= cn.new_pph_amount
			  ,@new_total_total_amount	= cn.new_total_amount --raffi
		from  dbo.credit_note cn
			  outer apply (select sum(cnd.adjustment_amount) adjustment_amount from dbo.credit_note_detail cnd where cnd.credit_note_code = cn.code) cnd
		where cn.code = @p_code
		
		if exists
		(
			select	inv.invoice_no
			from	dbo.credit_note cn
					left join dbo.invoice inv on inv.invoice_no = cn.invoice_no
			where	invoice_status = 'CANCEL' and cn.code = @p_code AND cn.STATUS = 'ON PROCESS'
		)	
		begin
			set @msg = 'Invoice already cancel' ;

			raiserror(@msg, 16, 1) ;
		end 
		
		if exists (select 1 from dbo.credit_note where code = @p_code and status = 'ON PROCESS')
		begin 
			update	dbo.invoice
			set		credit_ppn_amount		= @new_ppn_amount
					,credit_billing_amount	= @billing_amount
					,credit_pph_amount		= @new_pph_amount
					--,faktur_no				= case
					--								 when isnull(faktur_no, '') <> '' then stuff(faktur_no, 3, 1, '1') -- koreksi nomor faktur 
					--								 else ''
					--							 end
					--
					,mod_date				= @p_mod_date
					,mod_ip_address			= @p_mod_ip_address
					,mod_by					= @p_mod_by
			where	invoice_no				= @invoice_no ;

			select	@total_pph_amount = @new_pph_amount
			from dbo.invoice 
			where invoice_no = @invoice_no

			update	dbo.invoice_pph
			set		total_pph_amount = @total_pph_amount
					--
					,mod_date		 = @p_mod_date
					,mod_ip_address	 = @p_mod_ip_address
					,mod_by			 = @p_mod_by
			where	invoice_no		 = @invoice_no
			
			if not exists
				(
					select	1
					from	dbo.invoice
					where	invoice_no				= @invoice_no
					and		invoice_type			= 'PENALTY'
				)
			begin
				exec dbo.xsp_credit_note_journal @p_reff_name		= N'CREDIT NOTE'
												 ,@p_reff_code		= @p_code
												 ,@p_value_date		= @p_mod_date
												 ,@p_trx_date		= @p_mod_date
												 ,@p_mod_date		= @p_mod_date
												 ,@p_mod_by			= @p_mod_by
												 ,@p_mod_ip_address = @p_mod_ip_address
			end
			
			exec dbo.credit_note_to_interface_cashier_receive_insert @p_code			= @p_code
																	 ,@p_mod_date		= @p_mod_date
																	 ,@p_mod_by			= @p_mod_by
																	 ,@p_mod_ip_address = @p_mod_ip_address
			

			exec dbo.xsp_credit_note_to_agreement_invoice_payment @p_credit_note_code	= @p_code
																  ,@p_cre_date			= @p_mod_date
																  ,@p_cre_by			= @p_mod_by
																  ,@p_cre_ip_address	= @p_mod_ip_address
																  ,@p_mod_date			= @p_mod_date
																  ,@p_mod_by			= @p_mod_by
																  ,@p_mod_ip_address	= @p_mod_ip_address
				
			--raffi 2024-07-12 : penambahan kondisi cancel jika amount 0 tipe credit note 2322228
			IF @new_total_total_amount = 0
			BEGIN
				UPDATE invoice
				SET invoice_status = 'PAID'
					--
					,mod_date		= @p_mod_date
					,mod_ip_address	= @p_mod_ip_address
					,mod_by			= @p_mod_by
				WHERE invoice_no = @invoice_no

			END

			update	dbo.credit_note
			set		status			= 'POST'
					--
					,mod_date		= @p_mod_date
					,mod_ip_address	= @p_mod_ip_address
					,mod_by			= @p_mod_by
			where	code			= @p_code
			
			-- Louis Senin, 05 Februari 2024 11.21.04 -- penambahan fungsing untuk hitung ulang agreement information
			begin
				declare currInvoiceDetail cursor fast_forward read_only for
				select	distinct agreement_no
				from	dbo.invoice_detail
				where	invoice_no = @invoice_no ;

				open currInvoiceDetail ;

				fetch next from currInvoiceDetail
				into @agreement_no ;

				while @@fetch_status = 0
				begin  
				 
						exec dbo.xsp_agreement_information_update @p_agreement_no		= @agreement_no
																  ,@p_mod_date			= @p_mod_date
																  ,@p_mod_by			= @p_mod_by
																  ,@p_mod_ip_address	= @p_mod_ip_address ;

					fetch next from currInvoiceDetail
					into @agreement_no ;
				end ;

				close currInvoiceDetail ;
				deallocate currInvoiceDetail ;
			end
		end
		else
		begin
			set @msg = 'Data already proceed';
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



