CREATE PROCEDURE dbo.mtn_invoice_amount
(
	@p_invoice_no		nvarchar(50)
	,@p_ppn_amount		DECIMAL(18,2) = 3377000
	,@p_pph_amount		DECIMAL(18,2) = 614000
	,@p_asset_no		NVARCHAR(50) = '0000026.4.16.02.2022-1'
	,@p_billing_amount	DECIMAL(18,2) = '30700000'
	,@p_billing_no		INT				= 29
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
			,@total_ppn_amount		 INT
            ,@id					INT
			,@invoice_status		NVARCHAR(50)

	begin try
		--set untuk jumlah persentase dati ppn

		select	@invoice_status  = invoice_status 
		from	dbo.invoice 
		where	invoice_no = @p_invoice_no

		select	@id = id
				,@discount_amount = DISCOUNT_AMOUNT
		from	dbo.invoice_detail
		where	invoice_no	= @p_invoice_no
		and		asset_no	= @p_asset_no
		and		billing_no	= @p_billing_no

		select	@ppn_pct	= ppn_pct
				,@pph_pct	= pph_pct
		from	dbo.invoice_detail
		where	id			= @id

		select 	@billing_to_faktur_type = billing_to_faktur_type
				,@is_invoice_deduct_pph = is_invoice_deduct_pph
		from	dbo.invoice 
		where	invoice_no = @p_invoice_no ;


		IF (@invoice_status = 'NEW')
		BEGIN
			--update data discount amount di invoice detail
			update	dbo.invoice_detail
			set		PPN_AMOUNT			= isnull(@p_ppn_amount, 0)
					,PPH_AMOUNT			= ISNULL(@p_pph_amount,0)
					,BILLING_AMOUNT		= ISNULL(@p_billing_amount,0)
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	id					= @id ;

			--select data di invoice detail setelh di update ppn, pph, dan discountnya
			--select	@billing_amount		= billing_amount
			--		,@pph_amount		= PPH_AMOUNT
			--		,@ppn_amount		= PPN_AMOUNT
			--		--
			--		,mod_date			= @p_mod_date
			--		,mod_by				= @p_mod_by
			--		,mod_ip_address		= @p_mod_ip_address
			--from	dbo.invoice_detail
			--where	id					= @id ;
	
			-- WAPU
			if (@billing_to_faktur_type = '01')
			begin
				set @total_amount = (@p_billing_amount - @discount_amount) + @p_ppn_amount ;
			end ;
			-- NON WAPU
			else
			begin
				set @total_amount = (@p_billing_amount - @discount_amount) ;
			end ; 
			
			--jika potong pph 
			if (@is_invoice_deduct_pph = '1')
			begin
				SET @total_amount = @total_amount - @p_pph_amount
			end 

			update	dbo.invoice_detail
			set		total_amount = @total_amount
			where	id = @id

			--select data dari invoice ddetail yang terupdate
			select	@total_ppn_amount		= sum(ppn_amount)
					,@total_pph_amount		= sum(pph_amount)
					,@total_discount_amount = sum(discount_amount)
					,@sub_total_amount		= sum(total_amount)
					,@billing_amount		= SUM(BILLING_AMOUNT)
			from	dbo.invoice_detail
			where	invoice_no				= @p_invoice_no ;

			SELECT @total_ppn_amount, @total_pph_amount, @total_amount, @billing_amount

			--update data tabel invoice
			update dbo.invoice
			set		total_discount_amount	= @total_discount_amount
					,total_pph_amount		= @total_pph_amount
					,total_ppn_amount		= @total_ppn_amount
					,total_amount			= @sub_total_amount
					,TOTAL_BILLING_AMOUNT	= @billing_amount
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	invoice_no				= @p_invoice_no


			INSERT INTO dbo.MTN_DATA_DSF_LOG
			(
			    MAINTENANCE_NAME,
			    REMARK,
			    TABEL_UTAMA,
			    REFF_1,
			    REFF_2,
			    REFF_3,
			    CRE_DATE,
			    CRE_BY
			)
			VALUES
			(   N'DATA MAINTENANCE INVOICE',       -- MAINTENANCE_NAME - nvarchar(50)
			    N'PERUBAHAN BILLING AMOUNT, PPN AMOUNT, PPH AMOUNT',       -- REMARK - nvarchar(4000)
			    N'INVOICE_DETAIL',       -- TABEL_UTAMA - nvarchar(50)
			    @p_invoice_no,       -- REFF_1 - nvarchar(50)
			    @p_asset_no,       -- REFF_2 - nvarchar(50)
			    @p_billing_no,       -- REFF_3 - nvarchar(50)
			    GETDATE(), -- CRE_DATE - datetime
			    @p_mod_by        -- CRE_BY - nvarchar(250)
			    )



		END
		ELSE
		BEGIN
			SET @msg = 'CANNOT PROCESS THIS MAINTENANCE, INVOICE HAS BEEN PROCEED'
			RAISERROR (@msg, 16, -1)
		END
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
