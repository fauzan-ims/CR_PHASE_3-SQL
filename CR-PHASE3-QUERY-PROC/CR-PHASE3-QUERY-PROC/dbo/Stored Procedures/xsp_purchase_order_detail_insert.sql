
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_purchase_order_detail_insert]
(
	@p_id								bigint				= 0 output
	,@p_po_code							nvarchar(50)
	,@p_item_code						nvarchar(50)
	,@p_item_name						nvarchar(250)
	,@p_type_asset_code					nvarchar(50)
	,@p_item_category_code				nvarchar(50)
	,@p_item_category_name				nvarchar(250)
	,@p_item_merk_code					nvarchar(50)
	,@p_item_merk_name					nvarchar(250)
	,@p_item_model_code					nvarchar(50)
	,@p_item_model_name					nvarchar(250)
	,@p_item_type_code					nvarchar(50)
	,@p_item_type_name					nvarchar(250)
	,@p_uom_code						nvarchar(50)
	,@p_uom_name						nvarchar(250)
	,@p_price_amount					decimal(18, 2)
	,@p_discount_amount					decimal(18, 2)
	,@p_order_quantity					int
	,@p_order_remaining					int					= 0
	,@p_description						nvarchar(4000)
	,@p_tax_code						nvarchar(50)
	,@p_tax_name						nvarchar(250)
	,@p_ppn_pct							decimal(9,6)		= 0
	,@p_pph_pct							decimal(9,6)		= 0
	,@p_ppn_amount						bigint				= 0	
	,@p_pph_amount						bigint				= 0
	,@p_requestor_code					nvarchar(50)		= ''
	,@p_requestor_name					nvarchar(250)		= ''
	,@p_supplier_selection_detail_id	int					= null
	,@p_eta_date_detail					datetime
	,@p_initiation_eta_date				datetime
	,@p_spesification					nvarchar(4000)		= ''
	,@p_unit_available_status			nvarchar(50)		= null
	,@p_indent_days						int					= null
	,@p_offering						nvarchar(4000)		= null
	,@p_bbn_name						nvarchar(250)
	,@p_bbn_location					nvarchar(250)
	,@p_bbn_address						nvarchar(4000)
	,@p_deliver_to_address				nvarchar(4000)
	--
	,@p_cre_date						datetime
	,@p_cre_by							nvarchar(15)
	,@p_cre_ip_address					nvarchar(15)
	,@p_mod_date						datetime
	,@p_mod_by							nvarchar(15)
	,@p_mod_ip_address					nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@temp_pph		decimal(18, 2)
			,@temp_ppn		decimal(18, 2)
			,@total_amount	decimal(18, 2)
			,@count			int

	begin try
		if @p_order_remaining > @p_order_quantity or @p_order_remaining < @p_order_quantity
		begin
			set @msg = 'Order remaining must be equal with Order Quantity.'
			raiserror (@msg, 16, 1)
		end

		set @p_ppn_amount = round(((@p_ppn_pct / 100) * ((@p_price_amount - @p_discount_amount) * @p_order_quantity)),0)
		set @p_pph_amount = round(((@p_pph_pct / 100) * ((@p_price_amount - @p_discount_amount) * @p_order_quantity)),0)

		if (((@p_price_amount - @p_discount_amount)* @p_order_quantity) + @p_ppn_amount -  @p_pph_amount) = 0
		begin
			set @msg = 'Total amount must be greater than 0.'
			raiserror (@msg, 16, 1)
		end

		insert into purchase_order_detail
		(
			po_code
			,item_code
			,item_name
			,type_asset_code
			,item_category_code
			,item_category_name
			,item_merk_code
			,item_merk_name
			,item_model_code
			,item_model_name
			,item_type_code
			,item_type_name
			,uom_code
			,uom_name
			,price_amount
			,discount_amount
			,order_quantity
			,order_remaining
			,description
			,tax_code
			,tax_name
			,ppn_pct
			,pph_pct
			,ppn_amount
			,pph_amount
			,requestor_code
			,requestor_name
			,supplier_selection_detail_id
			,eta_date
			,initiation_eta_date
			,spesification
			,unit_available_status
			,indent_days
			,offering
			,bbn_name
			,bbn_location
			,bbn_address
			,deliver_to_address
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_po_code
			,@p_item_code
			,@p_item_name
			,@p_type_asset_code
			,@p_item_category_code				
			,@p_item_category_name				
			,@p_item_merk_code					
			,@p_item_merk_name					
			,@p_item_model_code					
			,@p_item_model_name					
			,@p_item_type_code					
			,@p_item_type_name
			,@p_uom_code
			,@p_uom_name
			,@p_price_amount
			,@p_discount_amount 
			,@p_order_quantity
			,@p_order_remaining
			,@p_description
			,@p_tax_code
			,@p_tax_name
			,@p_ppn_pct
			,@p_pph_pct
			,@p_ppn_amount
			,@p_pph_amount
			,@p_requestor_code
			,@p_requestor_name
			,@p_supplier_selection_detail_id
			,@p_eta_date_detail
			,@p_initiation_eta_date
			,@p_spesification
			,@p_unit_available_status
			,@p_indent_days
			,@p_offering
			,@p_bbn_name
			,@p_bbn_location
			,@p_bbn_address
			,@p_deliver_to_address
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		)set @p_id = @@identity ;

		--select sum data total amount, ppn, pph dari tabel purchase order detail
		select	@total_amount	= sum ((price_amount - discount_amount) * order_quantity + ppn_amount - pph_amount)
				,@temp_pph		= sum(pph_amount)
				,@temp_ppn		= sum(ppn_amount)
		from	dbo.purchase_order_detail
		where	po_code			= @p_po_code

		--update data di tabel puchase order
		update	dbo.purchase_order
		set		total_amount	= isnull(@total_amount, 0)
				,pph_amount		= isnull(@temp_pph, 0)
				,ppn_amount		= isnull(@temp_ppn, 0)
		where	code			= @p_po_code

		set @count = 0
		while(@count < @p_order_quantity)
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
																  ,@p_cre_date						= @p_cre_date
																  ,@p_cre_by						= @p_cre_by
																  ,@p_cre_ip_address				= @p_cre_ip_address
																  ,@p_mod_date						= @p_mod_date
																  ,@p_mod_by						= @p_mod_by
																  ,@p_mod_ip_address				= @p_mod_ip_address
			set @count = @count + 1;
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


