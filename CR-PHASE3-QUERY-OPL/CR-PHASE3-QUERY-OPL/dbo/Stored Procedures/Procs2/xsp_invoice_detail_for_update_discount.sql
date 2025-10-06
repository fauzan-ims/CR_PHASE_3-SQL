--created by, Rian at 22/02/2023 

CREATE PROCEDURE dbo.xsp_invoice_detail_for_update_discount
(
	@p_id				bigint
	,@p_invoice_no		nvarchar(50)
	,@p_discount_amount decimal(18, 2)
	,@p_description		nvarchar(4000) = ''
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg					 nvarchar(max)
			,@is_invoice_deduct_pph	 nvarchar(1) 
			,@billing_to_faktur_type nvarchar(3)
			,@total_amount			 decimal(18, 2)
			,@ppn_pct				 decimal(9, 6)
			,@pph_pct				 decimal(9, 6)
			,@billing_amount		 decimal(18, 2)
			,@discount_amount		 decimal(18, 2)
			,@total_discount_amount	 decimal(18, 2)
			,@sub_total_amount		 decimal(18, 2)
			,@pph_amount			 int
			,@total_pph_amount		 int
			,@ppn_amount			 int
			,@total_ppn_amount		 int

	begin try
		--set untuk jumlah persentase dati ppn
		select	@ppn_pct	= ppn_pct
				,@pph_pct	= pph_pct
		from	dbo.invoice_detail
		where	id			= @p_id

		select 	@billing_to_faktur_type = billing_to_faktur_type
				,@is_invoice_deduct_pph = is_invoice_deduct_pph
		from	dbo.invoice 
		where	invoice_no = @p_invoice_no ;

		--update data discount amount di invoice detail
		update	dbo.invoice_detail
		set		discount_amount = isnull(@p_discount_amount, 0)
				,description	= @p_description
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	id				= @p_id ;

		--select data di invoice detail setelh di update discount nya
		select	@billing_amount		= billing_amount
				,@discount_amount	= discount_amount
		from	dbo.invoice_detail
		where	id					= @p_id ;

		--set ppn dan pph untuk invoice detail
		set @ppn_amount		= (@billing_amount - @discount_amount) * (@ppn_pct / 100) ;
		set @pph_amount		= (@billing_amount - @discount_amount) * (@pph_pct / 100) ;
	
		-- WAPU
		if (@billing_to_faktur_type = '01')
		begin
			set @total_amount = (@billing_amount - @discount_amount) + @ppn_amount ;
		end ;
		-- NON WAPU
		else
		begin
			set @total_amount = (@billing_amount - @discount_amount) ;
		end ; 
		
		--jika potong pph 
		if (@is_invoice_deduct_pph = '1')
		begin
			SET @total_amount = @total_amount - @pph_amount
		end 
	
		--update pph dan ppn di invoice detail
		update	dbo.invoice_detail
		set		pph_amount			= @pph_amount
				,ppn_amount			= @ppn_amount
				,total_amount		= @total_amount
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id					= @p_id ;

		--select data dari invoice ddetail yang terupdate
		select	@total_ppn_amount		= sum(ppn_amount)
				,@total_pph_amount		= sum(pph_amount)
				,@total_discount_amount = sum(discount_amount)
				,@sub_total_amount		= sum(total_amount)
		from	dbo.invoice_detail
		where	invoice_no				= @p_invoice_no ;

		--update data tabel invoice
		update dbo.invoice
		set		total_discount_amount	= @total_discount_amount
				,total_pph_amount		= @total_pph_amount
				,total_ppn_amount		= @total_ppn_amount
				,total_amount			= @sub_total_amount
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	invoice_no				= @p_invoice_no

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
