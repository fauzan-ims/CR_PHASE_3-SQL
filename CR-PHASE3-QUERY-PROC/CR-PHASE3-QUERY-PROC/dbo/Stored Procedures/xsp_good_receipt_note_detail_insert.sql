CREATE PROCEDURE [dbo].[xsp_good_receipt_note_detail_insert]
(
	@p_id						 bigint		   = 0 output
	,@p_good_receipt_note_code	 nvarchar(50)
	,@p_item_code				 nvarchar(50)
	,@p_item_name				 nvarchar(250)
	,@p_type_asset_code			 nvarchar(50)
	,@p_item_category_code		 nvarchar(50)
	,@p_item_category_name		 nvarchar(250)
	,@p_item_merk_code			 nvarchar(50)
	,@p_item_merk_name			 nvarchar(250)
	,@p_item_model_code			 nvarchar(50)
	,@p_item_model_name			 nvarchar(250)
	,@p_item_type_code			 nvarchar(50)
	,@p_item_type_name			 nvarchar(250)
	,@p_uom_code				 nvarchar(50)
	,@p_uom_name				 nvarchar(250)
	,@p_price_amount			 decimal(18, 2)
	,@p_po_quantity				 decimal(18, 2)
	,@p_receive_quantity		 decimal(18, 2)
	,@p_shipper_code			 nvarchar(50)  = ''
	,@p_no_resi					 nvarchar(50)  = ''
	,@p_purchase_order_detail_id int
	,@p_spesification			 nvarchar(4000)
	,@p_discount_amount			 decimal(18, 2)	= 0
	,@p_ppn_amount				 decimal(18, 2)	= 0
	,@p_pph_amount				 decimal(18, 2)	= 0
	,@p_orig_price_amount		 decimal(18, 2)	= 0
	,@p_orig_discount_amount	 decimal(18, 2)	= 0
	,@p_orig_ppn_amount			 decimal(18, 2)	= 0
	,@p_orig_pph_amount			 decimal(18, 2)	= 0
	,@p_orig_total_amount		 decimal(18, 2)	= 0
	--  
	,@p_cre_date				 datetime
	,@p_cre_by					 nvarchar(15)
	,@p_cre_ip_address			 nvarchar(15)
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into good_receipt_note_detail
		(
			good_receipt_note_code
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
			,po_quantity
			,discount_amount
			,ppn_amount
			,pph_amount
			,receive_quantity
			,shipper_code
			,no_resi
			,purchase_order_detail_id
			,spesification
			,orig_price_amount
			,orig_discount_amount
			,orig_ppn_amount
			,orig_pph_amount
			,orig_total_amount
			--  
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_good_receipt_note_code
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
			,@p_po_quantity
			,@p_discount_amount
			,@p_ppn_amount
			,@p_pph_amount
			,@p_receive_quantity
			,@p_shipper_code
			,@p_no_resi
			,@p_purchase_order_detail_id
			,@p_spesification
			,@p_orig_price_amount		
			,@p_orig_discount_amount	
			,@p_orig_ppn_amount			
			,@p_orig_pph_amount			
			,@p_orig_total_amount		
			--  
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;

		update	dbo.GOOD_RECEIPT_NOTE
		set		is_validate = '0'
		where	code = @p_good_receipt_note_code 


		-- (+) Ari 2024-01-12 ket : bawa tax dari quotation/supplier
		declare	@tax_code	nvarchar(50)
				,@tax_name	nvarchar(250)
				,@ppn_pct	decimal(18,2)
				,@pph_pct	decimal(18,2)

		select	@ppn_pct = isnull(qrd.ppn_pct, ssd.ppn_pct)
				,@pph_pct = isnull(qrd.pph_pct, ssd.pph_pct)
				,@tax_code = isnull(qrd.tax_code, ssd.tax_code)
				,@tax_name = isnull(qrd.tax_name, ssd.tax_name)
		from	dbo.good_receipt_note_detail			 grnd
		inner	join dbo.good_receipt_note				 grn on (grn.code									= grnd.good_receipt_note_code)
		inner	join dbo.purchase_order					 po on (po.code										= grn.purchase_order_code)
		inner	join dbo.purchase_order_detail			 pod on (
																	pod.po_code								= po.code
																	and pod.id								= grnd.purchase_order_detail_id
																)
		inner	join dbo.supplier_selection_detail		 ssd on (ssd.id										= pod.supplier_selection_detail_id)
		left	join dbo.quotation_review_detail		 qrd on (qrd.id										= ssd.quotation_detail_id)
		where	grnd.good_receipt_note_code = @p_good_receipt_note_code

		update	good_receipt_note_detail
		set		master_tax_code	= @tax_code
				,master_tax_description = @tax_name
				,master_tax_ppn_pct = @ppn_pct
				,master_tax_pph_pct = @pph_pct
		where	good_receipt_note_code = @p_good_receipt_note_code
		-- (+) Ari 2024-01-12

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
