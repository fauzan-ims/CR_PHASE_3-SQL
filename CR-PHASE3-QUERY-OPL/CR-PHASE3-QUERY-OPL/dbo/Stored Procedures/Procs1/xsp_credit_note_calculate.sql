

--------
CREATE PROCEDURE dbo.xsp_credit_note_calculate
(
	@p_code				 nvarchar(50)
	--
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg					 nvarchar(max)
			,@is_invoice_deduct_pph	 nvarchar(1)
			,@billing_to_faktur_type nvarchar(3)
			,@invoice_no			 nvarchar(50)
			,@billing_amount		 decimal(18, 2) = 0
			,@discount_amount		 decimal(18, 2) = 0
			,@ppn_pct				 decimal(9, 6)	= 0
			,@pph_pct				 decimal(9, 6)	= 0
			,@credit_amount			 decimal(18, 2) = 0
			,@new_ppn_amount		 decimal(18,2) = 0
			,@new_pph_amount		 decimal(18,2) = 0
			,@new_total_amount		 decimal(18, 2) = 0 ;

	begin try 
	
		select	@credit_amount		= credit_amount
				,@billing_amount	= billing_amount
				,@discount_amount	= discount_amount
				,@ppn_pct			= ppn_pct
				,@pph_pct			= pph_pct
				,@invoice_no		= invoice_no
		from	dbo.credit_note
		where	code				= @p_code ;

		if (@credit_amount > 0)
		begin

			select @billing_to_faktur_type = aa.billing_to_faktur_type
					,@is_invoice_deduct_pph = aa.is_invoice_deduct_pph
			from	dbo.invoice aa
			where	invoice_no = @invoice_no ;

			set @new_ppn_amount = round(((@billing_amount - @discount_amount - @credit_amount) * (@ppn_pct / 100)),0) ;
			set @new_pph_amount = round(((@billing_amount - @discount_amount - @credit_amount) * (@pph_pct / 100)),0) ;

			-- WAPU
			if (@billing_to_faktur_type = '01')
			begin
				set @new_total_amount = @billing_amount + @new_ppn_amount - @credit_amount ;
			end ;
			-- NON WAPU
			else
			begin
				set @new_total_amount = @billing_amount - @credit_amount ;
			end ;

			--jika potong pph 
			if (@is_invoice_deduct_pph = '1')
			begin
				set @new_total_amount = @new_total_amount - @new_pph_amount
			end 
		end ;
		else
		begin
			set @new_ppn_amount = 0 ;
			set @new_pph_amount = 0 ;
			set @new_total_amount = 0 ;
		end ; 
		 
		update	credit_note
		set		credit_amount			= @credit_amount 
				,new_ppn_amount			= @new_ppn_amount
				,new_pph_amount			= @new_pph_amount
				,new_total_amount		= @new_total_amount
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code					= @p_code ;
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
