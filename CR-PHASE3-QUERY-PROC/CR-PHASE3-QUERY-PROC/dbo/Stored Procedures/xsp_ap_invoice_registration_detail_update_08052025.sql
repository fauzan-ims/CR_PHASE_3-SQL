CREATE PROCEDURE dbo.xsp_ap_invoice_registration_detail_update_08052025
(
	@p_id				bigint
	,@p_purchase_amount decimal(18, 2)
	,@p_total_amount	decimal(18, 2) = 0
	,@p_ppn				decimal(18, 2) = 0
	,@p_pph				decimal(18, 2) = 0
	,@p_tax_code		nvarchar(50)
	,@p_tax_name		nvarchar(250)
	,@p_ppn_pct			decimal(9, 6)
	,@p_pph_pct			decimal(9, 6)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max)
			,@total_amount		decimal(18, 2)
			,@total_amount_head decimal(18, 2)
			,@total_amount_dtl	decimal(18, 2)
			,@ppn				decimal(18, 2)
			,@pph				decimal(18, 2)
			,@shipping_fee		decimal(18, 2)
			,@discount			decimal(18, 2)
			,@discount_head		decimal(18, 2)
			,@invoice_code		nvarchar(50) ;

	begin try

		--set @total_amount_dtl = (isnull(@p_purchase_amount, 0)  - isnull(@p_discount_detail, 0) * isnull(@p_quantity, 0)) - isnull(@p_pph, 0) + isnull(@p_ppn, 0)
		select	@invoice_code = invoice_register_code
		from	dbo.ap_invoice_registration_detail
		where	id = @p_id ;

		if (
			   @p_ppn <= 0
			   and	@p_ppn_pct > 0
		   )
		begin
			set @msg = 'PPN Must be Greater Than 0.' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if (
					@p_pph <= 0
					and @p_pph_pct > 0
				)
		begin
			set @msg = 'PPH Must be Greater Than 0.' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if ((
					 isnull(@p_ppn_pct, 0) = 0
					 and isnull(@p_ppn, 0) <> 0
				 )
				)
		begin
			set @msg = 'Cannot set PPN amount because PPN PCT = 0' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if ((
					 isnull(@p_pph_pct, 0) = 0
					 and isnull(@p_pph, 0) <> 0
				 )
				)
		begin
			set @msg = 'Cannot set PPH amount because PPH PCT = 0' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if (right(@p_ppn, 2) <> '00')
		begin
			set @msg = 'The Comma at the end cannot be anything other than 0' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if (right(@p_pph, 2) <> '00')
		begin
			set @msg = 'The Comma at the end cannot be anything other than 0' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if (@p_ppn > @p_purchase_amount)
		begin
			set @msg = 'PPN cannot bigger than unit price.';  

			raiserror(@msg, 16, -1) ;
		end ;
		else if (@p_pph > @p_purchase_amount)
		begin
			set @msg = 'PPH cannot bigger than unit price.';  

			raiserror(@msg, 16, -1) ;
		end ;

		update	ap_invoice_registration_detail
		set		ppn					= @p_ppn
				,pph				= @p_pph
				,total_amount		= @p_total_amount
				,purchase_amount	= @p_purchase_amount
				,tax_code			= @p_tax_code
				,tax_name			= @p_tax_name
				,ppn_pct			= @p_ppn_pct
				,pph_pct			= @p_pph_pct
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id = @p_id ;

		select	@total_amount_head = isnull(sum(total_amount), 0)
				,@discount_head	   = isnull(sum(discount), 0)
				,@ppn			   = isnull(sum(ppn), 0)
				,@pph			   = isnull(sum(pph), 0)
		from	dbo.ap_invoice_registration_detail
		where	invoice_register_code = @invoice_code ;

		--select	@discount_head = discount
		--from	dbo.ap_invoice_registration
		--where	code = @p_invoice_register_code ;

		--if @discount_head = 0
		--begin
		--	set @discount_head = @discount_head + @p_discount
		--end
		--else
		--begin
		--	set @discount_head = @discount_head - @discount + @p_discount
		--end
		select	@total_amount_head = sum(isnull(total_amount, 0))
		from	dbo.ap_invoice_registration_detail
		where	invoice_register_code = @invoice_code ;

		update	dbo.ap_invoice_registration
		set		invoice_amount	= @total_amount_head
				,ppn			= @ppn
				,pph			= @pph
				,discount		= @discount_head
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code			= @invoice_code ;
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
