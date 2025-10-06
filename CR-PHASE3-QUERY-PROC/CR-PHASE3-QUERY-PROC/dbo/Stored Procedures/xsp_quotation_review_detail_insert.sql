
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_quotation_review_detail_insert]
(
	 @p_id								bigint	= 0 output
	,@p_quotation_review_code			nvarchar(50)
	,@p_quotation_review_date			datetime
	,@p_reff_no							nvarchar(50)
	,@p_branch_code						nvarchar(50)
	,@p_branch_name						nvarchar(250)
	,@p_currency_code					nvarchar(20)
	,@p_currency_name					nvarchar(250)
	,@p_payment_methode_code			nvarchar(50)
	,@p_item_code						nvarchar(50)
	,@p_item_name						nvarchar(250)
	,@p_type_asset_code					nvarchar(50)	= ''
	,@p_item_category_code				nvarchar(50)	= ''
	,@p_item_category_name				nvarchar(250)	= ''
	,@p_item_merk_code					nvarchar(50)	= ''
	,@p_item_merk_name					nvarchar(250)	= ''
	,@p_item_model_code					nvarchar(50)	= ''
	,@p_item_model_name					nvarchar(250)	= ''
	,@p_item_type_code					nvarchar(50)	= ''
	,@p_item_type_name					nvarchar(250)	= ''
	,@p_supplier_code					nvarchar(50)	= ''
	,@p_supplier_name					nvarchar(250)	= ''
	,@p_tax_code						nvarchar(50)	= ''
	,@p_tax_name						nvarchar(250)	= ''
	,@p_ppn_pct							decimal(9,6)	= 0
	,@p_pph_pct							decimal(9,6)	= 0
	,@p_warranty_month					int				= 0
	,@p_warranty_part_month				int				= 0
	,@p_quantity						int				= 0
	,@p_approved_quantity				int				= 0
	,@p_uom_code						nvarchar(50)	= null
	,@p_uom_name						nvarchar(250)	= null
	,@p_price_amount					decimal(18, 2)
	,@p_discount_amount					decimal(18, 2)
	,@p_requestor_code					nvarchar(50)	= null
	,@p_requestor_name					nvarchar(250)	= null
	,@p_unit_from						nvarchar(25)
	,@p_spesification					nvarchar(4000)
	,@p_remark							nvarchar(4000)
	,@p_expired_date					datetime		= null
	,@p_total_amount					decimal(18,2)	= 0
	,@p_nett_price						decimal(18,2)	= 0
	,@p_supplier_npwp					nvarchar(50)	= ''
	,@p_supplier_address				nvarchar(4000)	= ''
	,@p_offering						nvarchar(4000)	= ''
	,@p_type							nvarchar(50)	
	,@p_asset_amount					decimal(18,2)	= 0
	,@p_asset_discount_amount			decimal(18,2)	= 0
	,@p_karoseri_amount					decimal(18,2)	= 0
	,@p_karoseri_discount_amount		decimal(18,2)	= 0
	,@p_accesories_amount				decimal(18,2)	= 0
	,@p_accesories_discount_amount		decimal(18,2)	= 0
	,@p_mobilization_amount				decimal(18,2)	= 0
	,@p_application_no					nvarchar(50)	= ''
	,@p_unit_available_status			nvarchar(50)	= ''
	,@p_indent_days						int				= 0
	,@p_otr_amount						decimal(18,2)	= 0
	,@p_gps_amount						decimal(18,2)	= 0
	,@p_budget_amount					decimal(18,2)	= 0
	,@p_bbn_name						nvarchar(250)
	,@p_bbn_location					nvarchar(250)
	,@p_bbn_address						nvarchar(4000)
	,@p_deliver_to_address				nvarchar(4000)
	--(+) Raffy 2025/02/01 CR NITKU
	,@p_supplier_nitku					nvarchar(50) = ''
	,@p_supplier_npwp_pusat				nvarchar(50) = ''
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
	declare @msg nvarchar(max) ;

	begin try
		insert into quotation_review_detail
		(
			 quotation_review_code
			,quotation_review_date
			,reff_no
			,branch_code
			,branch_name
			,currency_code
			,currency_name
			,payment_methode_code
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
			,supplier_code
			,supplier_name
			,tax_code
			,tax_name
			,ppn_pct
			,pph_pct
			,warranty_month
			,warranty_part_month
			,quantity
			,approved_quantity
			,uom_code
			,uom_name
			,price_amount
			,discount_amount
			,requestor_code
			,requestor_name
			,unit_from
			,spesification
			,remark
			,expired_date
			,total_amount
			,nett_price
			,supplier_npwp
			,supplier_address
			,offering
			,type
			,asset_amount
			,asset_discount_amount
			,karoseri_amount
			,karoseri_discount_amount
			,accesories_amount
			,accesories_discount_amount
			,mobilization_amount
			,application_no
			,unit_available_status
			,indent_days
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
			 @p_quotation_review_code
			,@p_quotation_review_date
			,@p_reff_no
			,@p_branch_code
			,@p_branch_name
			,@p_currency_code
			,@p_currency_name
			,@p_payment_methode_code
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
			,@p_supplier_code
			,@p_supplier_name
			,@p_tax_code
			,@p_tax_name
			,@p_ppn_pct
			,@p_pph_pct
			,@p_warranty_month
			,@p_warranty_part_month
			,@p_quantity
			,@p_approved_quantity
			,@p_uom_code
			,@p_uom_name
			,@p_price_amount
			,@p_discount_amount
			,@p_requestor_code
			,@p_requestor_name
			,@p_unit_from
			,@p_spesification
			,@p_remark
			,@p_expired_date
			,@p_total_amount
			,@p_nett_price
			,@p_supplier_npwp
			,@p_supplier_address
			,@p_offering
			,@p_type
			,@p_asset_amount
			,@p_asset_discount_amount
			,@p_karoseri_amount
			,@p_karoseri_discount_amount
			,@p_accesories_amount
			,@p_accesories_discount_amount
			,@p_mobilization_amount
			,@p_application_no
			,@p_unit_available_status
			,@p_indent_days
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
