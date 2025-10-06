CREATE PROCEDURE dbo.xsp_settlement_pph_post
(
	@p_invoice_no			nvarchar(50)
	,@p_payment_reff_no		nvarchar(50)	= ''
	,@p_payment_reff_date	datetime		= ''
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max);
		
	begin try
		
		if exists (select 1 from dbo.invoice_pph where invoice_no = @p_invoice_no and settlement_status <> 'HOLD')
		begin
			set @msg = N'Settlement Already proceed for Invoice no. ' + @p_invoice_no  ;
			raiserror(@msg, 16, 1) ;
		end ;
	
		if(@p_payment_reff_no = '' or @p_payment_reff_no is null)
		begin
			set @msg = 'Please Insert Payment Reff No.';
			raiserror(@msg, 16, 1) ;
		end

		if(@p_payment_reff_date = '' or @p_payment_reff_date is null)
		begin
			set @msg = 'Please Insert Payment Reff Date.';
			raiserror(@msg, 16, 1) ;
		end
	
		if (@p_payment_reff_date > dbo.xfn_get_system_date())
		begin
			set @msg = N'Payment Reff Date Must Be Less or Equal Than System Date.' ;

			raiserror(@msg, 16, 1) ;
		end ;

		--(-) Louis Senin, 16 Oktober 2023 10.02.25 -- ditutup karena tidak mempengaruhi invoice yang tidak memiliki faktur, Faktur digunakan untuk PPN bukan PPH
		--if exists 
		--(
		--	select	1
		--	from	dbo.invoice
		--	where	invoice_no = @p_invoice_no
		--	and		isnull(faktur_no, '') = ''
		--)
		--begin
		--	set	@msg = 'Please allocate Faktur No before proceed.'
		--	raiserror (@msg, 16, -1)
		--end

		if exists
		(
			select	1
			from	dbo.invoice_pph
			where	settlement_status	= 'HOLD'
			and		invoice_no			= @p_invoice_no
		)
		begin
			exec dbo.xsp_invoice_pph_journal @p_reff_name		= N'WITHHOLDING SETTLEMENT'
											 ,@p_reff_code		= @p_invoice_no
											 ,@p_value_date		= @p_payment_reff_date
											 ,@p_trx_date		= @p_payment_reff_date
											 ,@p_mod_date		= @p_mod_date
											 ,@p_mod_by			= @p_mod_by
											 ,@p_mod_ip_address = @p_mod_ip_address
			
			update	dbo.invoice_pph
			set		settlement_status	= 'POST'
					,payment_reff_no	= @p_payment_reff_no
					,payment_reff_date	= @p_payment_reff_date
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	invoice_no			= @p_invoice_no

			update	dbo.invoice
			set		payment_pph_code	= @p_payment_reff_no
					,payment_pph_date	= @p_payment_reff_date
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	invoice_no			= @p_invoice_no
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

