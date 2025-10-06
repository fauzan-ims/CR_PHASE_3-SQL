CREATE PROCEDURE dbo.xsp_quotation_review_detail_add
(
	@p_id						bigint
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@quotation_review_code		nvarchar(50)
			,@quotation_review_date		datetime
			,@reff_no					nvarchar(50)
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(250)
			,@currency_code				nvarchar(20)
			,@currency_name				nvarchar(250)
			,@payment_methode_code		nvarchar(50)
			,@item_code					nvarchar(50)
			,@item_name					nvarchar(250)
			,@supplier_code				nvarchar(50)
			,@tax_code					nvarchar(50)
			,@warranty_month			int
			,@warranty_part_month		int
			,@quantity					int
			,@approved_quantity			int
			,@remaining_quantity		int
			,@uom_code					nvarchar(50)
			,@price_amount				decimal(18,2)
			,@winner_amount				decimal(18,2)
			,@winner_quantity			int
			,@discount_amount			decimal(18,2)
			,@reff_type					nvarchar(20)
			,@requestor_code			nvarchar(50)
			,@requestor_name			nvarchar(250)
			,@remark					nvarchar(4000)
			,@tax_name					nvarchar(250)
			,@type_asset_code			nvarchar(50)
			,@item_category_code		nvarchar(50)
			,@item_category_name		nvarchar(250)
			,@item_merk_code			nvarchar(50)
			,@item_merk_name			nvarchar(250)
			,@uom_name					nvarchar(250)
			,@item_model_code			nvarchar(50)
			,@item_model_name			nvarchar(250)
			,@item_type_code			nvarchar(50)
			,@item_type_name			nvarchar(250)
			,@ppn_pct					decimal(9, 6)
			,@pph_pct					decimal(9, 6)
			,@unit_from					nvarchar(50)
			,@spesifikasi				nvarchar(4000)
	
	begin try

		select @quotation_review_code	= 	quotation_review_code
			  ,@quotation_review_date	=	quotation_review_date
			  ,@reff_no					=	reff_no
			  ,@branch_code				=	branch_code
			  ,@branch_name				=	branch_name
			  ,@currency_code			=	currency_code
			  ,@currency_name			=	currency_name
			  ,@payment_methode_code	=	payment_methode_code
			  ,@item_code				=	item_code
			  ,@item_name				=	item_name
			  ,@supplier_code			=	supplier_code
			  ,@tax_code				=	tax_code
			  ,@tax_name				=	tax_name
			  ,@warranty_month			=	warranty_month
			  ,@warranty_part_month		=	warranty_part_month
			  ,@quantity				=	quantity
			  ,@approved_quantity		=	approved_quantity
			  ,@uom_code				=	uom_code
			  ,@uom_name				=	uom_name
			  ,@price_amount			=	price_amount
			  ,@discount_amount			=	discount_amount
			  ,@requestor_code			=	requestor_code
			  ,@requestor_name			=	requestor_name
			  ,@remark					=	remark
			  ,@type_asset_code			=	type_asset_code
			  ,@item_category_code		=	item_category_code
			  ,@item_category_name		=	item_category_name
			  ,@item_merk_code			=	item_merk_code
			  ,@item_merk_name			=	item_merk_name
			  ,@item_model_code			=	item_model_code
			  ,@item_model_name			=	item_model_name
			  ,@item_type_code			=	item_type_code
			  ,@item_type_name			=	item_type_name
			  ,@pph_pct					=	pph_pct
			  ,@ppn_pct					=	ppn_pct
			  ,@unit_from				=	unit_from
			  ,@spesifikasi				=	spesification
		from dbo.quotation_review_detail
		where	id = @p_id
		
		exec dbo.xsp_quotation_review_detail_insert @p_id						= 0
													,@p_quotation_review_code	= @quotation_review_code
													,@p_quotation_review_date	= @quotation_review_date
													,@p_reff_no					= @reff_no
													,@p_branch_code				= @branch_code
													,@p_branch_name				= @branch_name
													,@p_currency_code			= @currency_code
													,@p_currency_name			= @currency_name
													,@p_payment_methode_code	= @payment_methode_code
													,@p_item_code				= @item_code
													,@p_item_name				= @item_name
													,@p_type_asset_code			= @type_asset_code
													,@p_item_category_code		= @item_category_code
													,@p_item_category_name		= @item_category_name
													,@p_item_merk_code			= @item_merk_code
													,@p_item_merk_name			= @item_merk_name
													,@p_item_model_code			= @item_model_code
													,@p_item_model_name			= @item_model_name
													,@p_item_type_code			= @item_type_code
													,@p_item_type_name			= @item_type_name
													,@p_supplier_code			= ''
													,@p_supplier_name			= ''
													,@p_tax_code				= @tax_code
													,@p_tax_name				= @tax_name
													,@p_ppn_pct					= @ppn_pct
													,@p_pph_pct					= @ppn_pct
													,@p_warranty_month			= @warranty_month
													,@p_warranty_part_month		= @warranty_part_month
													,@p_quantity				= @quantity
													,@p_approved_quantity		= @approved_quantity
													,@p_uom_code				= @uom_code
													,@p_uom_name				= @uom_name
													,@p_price_amount			= @price_amount
													,@p_discount_amount			= @discount_amount
													,@p_requestor_code			= @requestor_code
													,@p_requestor_name			= @requestor_name
													,@p_unit_from				= @unit_from
													,@p_spesification			= @spesifikasi
													,@p_remark					= @remark
													,@p_cre_date				= @p_mod_date		
													,@p_cre_by					= @p_mod_by			
													,@p_cre_ip_address			= @p_mod_ip_address
													,@p_mod_date				= @p_mod_date		
													,@p_mod_by					= @p_mod_by			
													,@p_mod_ip_address			= @p_mod_ip_address
		
		--exec dbo.xsp_quotation_review_detail_insert @p_id						= 0
		--											,@p_quotation_review_code	= @quotation_review_code
		--											,@p_quotation_review_date	= @quotation_review_date
		--											,@p_reff_no					= @reff_no
		--											,@p_branch_code				= @branch_code
		--											,@p_branch_name				= @branch_name
		--											,@p_currency_code			= @currency_code
		--											,@p_currency_name			= @currency_name
		--											,@p_payment_methode_code	= @payment_methode_code
		--											,@p_item_code				= @item_code
		--											,@p_item_name				= @item_name
		--											,@p_supplier_code			= ''
		--											,@p_supplier_name			= ''
		--											,@p_tax_code				= @tax_code
		--											,@p_tax_name				= @tax_name
		--											,@p_warranty_month			= @warranty_month
		--											,@p_warranty_part_month		= @warranty_part_month
		--											,@p_quantity				= @quantity
		--											,@p_approved_quantity		= @approved_quantity
		--											,@p_uom_code				= @uom_code
		--											,@p_price_amount			= @price_amount
		--											,@p_discount_amount			= @discount_amount
		--											,@p_requestor_code			= @requestor_code
		--											,@p_requestor_name			= @requestor_name
		--											,@p_remark					= @remark
		--											,@p_cre_date				= @p_mod_date		
		--											,@p_cre_by					= @p_mod_by			
		--											,@p_cre_ip_address			= @p_mod_ip_address
		--											,@p_mod_date				= @p_mod_date		
		--											,@p_mod_by					= @p_mod_by			
		--											,@p_mod_ip_address			= @p_mod_ip_address
		

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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;


