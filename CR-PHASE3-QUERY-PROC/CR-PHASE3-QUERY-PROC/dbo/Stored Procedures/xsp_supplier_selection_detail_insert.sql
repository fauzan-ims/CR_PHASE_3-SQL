
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_supplier_selection_detail_insert]
(
	 @p_id									bigint	= 0 output
	,@p_selection_code						nvarchar(50)
	,@p_supplier_selection_detail_status	nvarchar(50)
	,@p_item_code							nvarchar(50)
	,@p_item_name							nvarchar(250)
	,@p_uom_code							nvarchar(50)
	,@p_uom_name							nvarchar(250)
	,@p_type_asset_code						nvarchar(50)
	,@p_item_category_code					nvarchar(250)
	,@p_item_category_name					nvarchar(250)
	,@p_item_merk_code						nvarchar(50)
	,@p_item_merk_name						nvarchar(250)
	,@p_item_model_code						nvarchar(50)
	,@p_item_model_name						nvarchar(250)
	,@p_item_type_code						nvarchar(50)
	,@p_item_type_name						nvarchar(250)
	,@p_supplier_code						nvarchar(50)
	,@p_supplier_name						nvarchar(250)
	,@p_amount								decimal(18, 2)
	,@p_quotation_amount					decimal(18, 2)
	,@p_quantity							int
	,@p_quotation_quantity					int
	,@p_total_amount						decimal(18, 2)
	,@p_spesification						nvarchar(4000)
	,@p_remark								nvarchar(4000)
	,@p_procurement_code					nvarchar(50)
	,@p_requestor_code						nvarchar(50)
	,@p_requestor_name						nvarchar(250)
	,@p_tax_code							nvarchar(50)	= ''
	,@p_tax_name							nvarchar(250)	= ''
	,@p_ppn_pct								decimal(9,6)	= 0
	,@p_pph_pct								decimal(9,6)	= 0
	,@p_pph_amount							decimal(18,2)	= 0
	,@p_ppn_amount							decimal(18,2)	= 0
	,@p_quotation_detail_id					int
	,@p_discount_amount						decimal(18,2)
	,@p_unit_from							nvarchar(25)
	,@p_purchase_order_no					nvarchar(50)	= ''
	,@p_unit_available_status				nvarchar(25)	= ''
	,@p_indent_days							int				= null
	,@p_offering							nvarchar(4000)	= ''
	--,@p_supplier_address					NVARCHAR(250)
	--,@p_supplier_npwp						NVARCHAR(50)
	,@p_asset_amount						decimal(18,2)
	,@p_asset_discount_amount				decimal(18,2)
	,@p_karoseri_amount						decimal(18,2)
	,@p_karoseri_discount_amount			decimal(18,2)
	,@p_accesories_amount					decimal(18,2)
	,@p_accesories_discount_amount			decimal(18,2)
	,@p_mobilization_amount					decimal(18,2)
	,@p_application_no						nvarchar(50)
	,@p_otr_amount							decimal(18,2)
	,@p_gps_amount							decimal(18,2)
	,@p_budget_amount						decimal(18,2)
	,@p_bbn_name							nvarchar(250)
	,@p_bbn_location						nvarchar(250)
	,@p_bbn_address							nvarchar(4000)
	,@p_deliver_to_address					nvarchar(4000)
	--(+) Raffy 2025/02/01 CR NITKU
	,@p_supplier_nitku						nvarchar(50) = ''
	,@p_supplier_npwp_pusat					nvarchar(50) = ''
	--
	,@p_cre_date							datetime
	,@p_cre_by								nvarchar(15)
	,@p_cre_ip_address						nvarchar(15)
	,@p_mod_date							datetime
	,@p_mod_by								nvarchar(15)
	,@p_mod_ip_address						nvarchar(15)
)
as
begin
	declare @msg	nvarchar(max);

	begin try

	set @p_ppn_amount = @p_ppn_pct / 100 * (@p_total_amount) ;
	set @p_pph_amount = @p_pph_pct / 100 * (@p_total_amount) ;

	insert into dbo.supplier_selection_detail
	(
		selection_code
		,supplier_selection_detail_status
		,item_code
		,item_name
		,uom_code
		,uom_name
		,type_asset_code
		,item_category_code
		,item_category_name
		,item_merk_code
		,item_merk_name
		,item_model_code
		,item_model_name
		,item_type_code
		,item_type_name
		,supplier_code
		,supplier_name
		--,supplier_address
		--,supplier_npwp
		,tax_code
		,tax_name
		,ppn_pct
		,pph_pct
		,pph_amount
		,ppn_amount
		,amount
		,quotation_amount
		,quantity
		,quotation_quantity
		,total_amount
		,discount_amount
		,reff_no
		,spesification
		,remark
		,requestor_code
		,requestor_name
		,quotation_detail_id
		,purchase_order_no
		,unit_from
		,unit_available_status
		,indent_days
		,offering
		,asset_amount
		,asset_discount_amount
		,karoseri_amount
		,karoseri_discount_amount
		,accesories_amount
		,accesories_discount_amount
		,mobilization_amount
		,application_no
		,otr_amount
		,gps_amount
		,budget_amount
		,bbn_name
		,bbn_location
		,bbn_address
		,deliver_to_address
		--(+) Raffy 2025/02/01 CR NITKU
		,supplier_nitku
		,supplier_npwp_pusat
		--
		,cre_date
		,cre_by
		,cre_ip_address
		,mod_date
		,mod_by
		,mod_ip_address
	)
	values
	(	
		 @p_selection_code
		,@p_supplier_selection_detail_status
		,@p_item_code
		,@p_item_name
		,@p_uom_code
		,@p_uom_name
		,@p_type_asset_code						
		,@p_item_category_code					
		,@p_item_category_name					
		,@p_item_merk_code						
		,@p_item_merk_name						
		,@p_item_model_code						
		,@p_item_model_name						
		,@p_item_type_code						
		,@p_item_type_name
		,@p_supplier_code
		,@p_supplier_name
		--,@p_supplier_address
		--,@p_supplier_npwp
		,@p_tax_code
		,@p_tax_name
		,@p_ppn_pct
		,@p_pph_pct
		,@p_pph_amount
		,@p_ppn_amount
		,@p_amount
		,@p_quotation_amount
		,@p_quantity
		,@p_quotation_quantity
		,@p_total_amount
		,@p_discount_amount
		,@p_procurement_code
		,@p_spesification
		,@p_remark
		,@p_requestor_code
		,@p_requestor_name
		,@p_quotation_detail_id
		,@p_purchase_order_no
		,@p_unit_from
		,@p_unit_available_status
		,@p_indent_days
		,@p_offering
		,@p_asset_amount
		,@p_asset_discount_amount
		,@p_karoseri_amount
		,@p_karoseri_discount_amount
		,@p_accesories_amount
		,@p_accesories_discount_amount
		,@p_mobilization_amount
		,@p_application_no
		,@p_otr_amount
		,@p_gps_amount
		,@p_budget_amount
		,@p_bbn_name
		,@p_bbn_location
		,@p_bbn_address
		,@p_deliver_to_address
		,@p_supplier_nitku
		,@p_supplier_npwp_pusat
		--
		,@p_cre_date
		,@p_cre_by
		,@p_cre_ip_address
		,@p_mod_date
		,@p_mod_by
		,@p_mod_ip_address
	) 

	set @p_id = @@IDENTITY

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
end

