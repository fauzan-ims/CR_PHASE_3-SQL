CREATE PROCEDURE dbo.xsp_purchase_order_detail_update
(
	@p_id						bigint
	,@p_po_code					nvarchar(50)
	,@p_item_code				nvarchar(50)
	,@p_item_name				nvarchar(250)
	,@p_type_asset_code			nvarchar(50)
	,@p_item_category_code		nvarchar(50)
	,@p_item_category_name		nvarchar(250)
	,@p_item_merk_code			nvarchar(50)
	,@p_item_merk_name			nvarchar(250)
	,@p_item_model_code			nvarchar(50)
	,@p_item_model_name			nvarchar(250)
	,@p_item_type_code			nvarchar(50)
	,@p_item_type_name			nvarchar(250)
	,@p_uom_code				nvarchar(50)
	,@p_price_amount			decimal(18, 2)
	,@p_discount_amount			decimal(18, 2)
	,@p_order_quantity			int
	,@p_order_remaining			int
	,@p_description				nvarchar(4000)
	,@p_tax_code				nvarchar(50)
	,@p_tax_name				nvarchar(250)
	,@p_ppn_amount				decimal(18, 2) = 0
	,@p_pph_amount				decimal(18, 2) = 0
	,@p_ppn_pct					decimal(9,6)
	,@p_pph_pct					decimal(9,6)
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@pph			decimal(9, 6)
			,@temp_pph		decimal(18, 2)
			,@ppn			decimal(9, 6)
			,@temp_ppn		decimal(18, 2)
			,@total_amount	decimal(18, 2)
			,@order_qty		int
			,@counter		int
			,@total_count	int

	begin try
		if @p_order_remaining > @p_order_quantity or @p_order_remaining < @p_order_quantity
		begin
			set @msg = 'Order remaining must be equal with Order Quantity.'
			raiserror (@msg, 16, 1)
		end

		if (((@p_price_amount - @p_discount_amount)* @p_order_quantity) + @p_ppn_amount -  @p_pph_amount) = 0
		begin
			set @msg = 'Total amount must be greater than 0.'
			raiserror (@msg, 16, 1)
		end

		update	purchase_order_detail
		set		po_code					= @p_po_code
				,item_code				= @p_item_code
				,item_name				= @p_item_name
				,type_asset_code		= @p_type_asset_code
				,item_category_code		= @p_item_category_code
				,item_category_name		= @p_item_category_name
				,item_merk_code			= @p_item_merk_code
				,item_merk_name			= @p_item_merk_name
				,item_model_code		= @p_item_model_code
				,item_model_name		= @p_item_model_name
				,item_type_code			= @p_item_type_code
				,item_type_name			= @p_item_type_name
				,uom_code				= @p_uom_code
				,price_amount			= @p_price_amount
				,discount_amount		= @p_discount_amount
				,order_quantity			= @p_order_quantity
				,order_remaining		= @p_order_remaining
				,description			= @p_description
				,tax_code				= @p_tax_code
				,tax_name				= @p_tax_name
				,ppn_amount				= @p_ppn_pct / 100 * (@p_price_amount * @p_order_quantity)
				,pph_amount				= @p_pph_pct / 100 * (@p_price_amount * @p_order_quantity)
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	id						= @p_id ;


		--select sum data total amount, ppn, pph dari tabel purchase order detail
		select	@total_amount	= sum ((isnull(price_amount, 0) - isnull(discount_amount, 0)) * isnull(order_quantity, 0) + isnull(ppn_amount, 0) - isnull(pph_amount, 0)) 
				,@temp_pph		= sum(isnull(pph_amount, 0))
				,@temp_ppn		= sum(isnull(ppn_amount, 0))
		from	dbo.purchase_order_detail
		where	po_code			= @p_po_code

		--update data di tabel puchase order
		update	dbo.purchase_order
		set		total_amount	= isnull(@total_amount, 0)
				,pph_amount		= isnull(@temp_pph, 0)
				,ppn_amount		= isnull(@temp_ppn, 0)
		where	code			= @p_po_code

		--insert ke purchse order detail object info
		
		select @order_qty = count(id) 
		from dbo.purchase_order_detail_object_info
		where purchase_order_detail_id = @p_id

		set @total_count = abs(@p_order_quantity - @order_qty)
		set @counter = 1

		if(@order_qty > 0)
		begin
			while(@counter <= @total_count)
			begin
				exec dbo.xsp_purchase_order_detail_object_info_insert @p_id								= 0
																	  ,@p_purchase_order_detail_id		= @p_id
																	  ,@p_good_receipt_note_detail_id	= 0
																	  ,@p_plat_no						= ''
																	  ,@p_chassis_no					= ''
																	  ,@p_engine_no						= ''
																	  ,@p_serial_no						= ''
																	  ,@p_invoice_no					= ''
																	  ,@p_domain						= ''
																	  ,@p_imei							= ''
																	  ,@p_cre_date						= @p_mod_date
																	  ,@p_cre_by						= @p_mod_by
																	  ,@p_cre_ip_address				= @p_mod_ip_address
																	  ,@p_mod_date						= @p_mod_date
																	  ,@p_mod_by						= @p_mod_by
																	  ,@p_mod_ip_address				= @p_mod_ip_address
				
				
				set @counter  = @counter  + 1
			end
		end
		else
		begin
			delete dbo.purchase_order_detail_object_info
			where purchase_order_detail_id = @p_id
		end

		if (@p_order_quantity = 0)
		begin
			delete dbo.purchase_order_detail_object_info
			where purchase_order_detail_id = @p_id
		end

		--jika order quantity yang diupdate kurang dari order quantity yang sekarang
		if(@p_order_quantity <> @order_qty and @order_qty <> 0)
		begin
			delete dbo.purchase_order_detail_object_info
			where purchase_order_detail_id = @p_id

			set @counter = 1
			while(@counter <= @p_order_quantity)
			begin
				exec dbo.xsp_purchase_order_detail_object_info_insert @p_id								= 0
																	  ,@p_purchase_order_detail_id		= @p_id
																	  ,@p_good_receipt_note_detail_id	= 0
																	  ,@p_plat_no						= ''
																	  ,@p_chassis_no					= ''
																	  ,@p_engine_no						= ''
																	  ,@p_serial_no						= ''
																	  ,@p_invoice_no					= ''
																	  ,@p_domain						= ''
																	  ,@p_imei							= ''
																	  ,@p_cre_date						= @p_mod_date
																	  ,@p_cre_by						= @p_mod_by
																	  ,@p_cre_ip_address				= @p_mod_ip_address
																	  ,@p_mod_date						= @p_mod_date
																	  ,@p_mod_by						= @p_mod_by
																	  ,@p_mod_ip_address				= @p_mod_ip_address
				
				set @counter  = @counter  + 1
			end
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
end ;
