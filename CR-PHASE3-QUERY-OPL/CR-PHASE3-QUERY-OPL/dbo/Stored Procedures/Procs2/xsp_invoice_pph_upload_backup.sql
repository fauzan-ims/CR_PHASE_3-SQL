create PROCEDURE dbo.xsp_invoice_pph_upload_backup
(
	@p_invoice_external_no nvarchar(50)
	,@p_payment_reff_no	   nvarchar(50) = ''
	,@p_payment_reff_date  datetime		= ''
	--
	,@p_cre_date		   datetime
	,@p_cre_by			   nvarchar(15)
	,@p_cre_ip_address	   nvarchar(15)
	,@p_mod_date		   datetime
	,@p_mod_by			   nvarchar(15)
	,@p_mod_ip_address	   nvarchar(15)
)
as
begin
	declare @msg		 nvarchar(max)
			,@invoice_no nvarchar(50) ;

	begin try
		if (
			   @p_payment_reff_no = ''
			   or	@p_payment_reff_no is null
		   )
		begin
			set @msg = N'Please Insert Payment Reff No.' ;

			raiserror(@msg, 16, 1) ;
		end ;

		if (
			   @p_payment_reff_date = ''
			   or	@p_payment_reff_date is null
		   )
		begin
			set @msg = N'Please Insert Payment Reff Date.' ;

			raiserror(@msg, 16, 1) ;
		end ;

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
		if (@p_payment_reff_date > dbo.xfn_get_system_date())
		begin
			set @msg = N'Payment Reff Date Must Be Less or Equal Than System Date.' ;

			raiserror(@msg, 16, 1) ;
		end ;

		select	@invoice_no = invoice_no
		from	dbo.invoice
		where	invoice_external_no = @p_invoice_external_no ;

		--update	dbo.invoice_pph
		--set		payment_reff_no		= @p_payment_reff_no
		--		,payment_reff_date	= @p_payment_reff_date
		--		,settlement_status  = 'POST'
		--		--
		--		,cre_date			= @p_cre_date
		--		,cre_ip_address		= @p_cre_ip_address
		--		,cre_by				= @p_cre_by
		--		,mod_date			= @p_mod_date
		--		,mod_ip_address		= @p_mod_ip_address
		--		,mod_by				= @p_mod_by
		--where	invoice_no			= @invoice_no ;

		
		exec dbo.xsp_invoice_pph_journal @p_reff_name		= N'WITHHOLDING SETTLEMENT'
										 ,@p_reff_code		= @invoice_no
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
		where	invoice_no			= @invoice_no

		update	dbo.invoice
		set		payment_pph_code	= @p_payment_reff_no
				,payment_pph_date	= @p_payment_reff_date
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	invoice_no			= @invoice_no
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
