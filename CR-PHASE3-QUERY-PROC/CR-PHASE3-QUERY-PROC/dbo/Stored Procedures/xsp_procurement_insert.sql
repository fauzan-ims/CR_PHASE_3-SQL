
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_procurement_insert]
(
	@p_code								nvarchar(50)
	,@p_company_code					nvarchar(50)
	,@p_procurement_request_item_id		bigint
	,@p_procurement_request_code		nvarchar(50)
	,@p_procurement_request_date		datetime
	,@p_branch_code						nvarchar(50)
	,@p_branch_name						nvarchar(250)
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
	,@p_type_code						nvarchar(50)
	,@p_type_name						nvarchar(50)
	,@p_quantity_request				int
	,@p_approved_quantity				int
	,@p_specification					nvarchar(4000)
	,@p_remark							nvarchar(4000)
	,@p_purchase_type_code				nvarchar(50)
	,@p_purchase_type_name				nvarchar(50)
	,@p_quantity_purchase				int
	,@p_status							nvarchar(20)
	,@p_requestor_code					nvarchar(50)
	,@p_requestor_name					nvarchar(250)
	,@p_unit_from						nvarchar(25) = null
	,@p_spaf_amount						decimal(18,2)	= null
	,@p_subvention_amount				decimal(18,2)	= null
	,@p_asset_amount					decimal(18,2)
	,@p_asset_discount_amount			decimal(18,2)
	,@p_karoseri_amount					decimal(18,2)
	,@p_karoseri_discount_amount		decimal(18,2)
	,@p_accesories_amount				decimal(18,2)
	,@p_accesories_discount_amount		decimal(18,2)
	,@p_application_no					nvarchar(50)
	,@p_mobilization_amount				decimal(18,2)
	,@p_otr_amount						decimal(18,2)
	,@p_gps_amount						decimal(18,2)
	,@p_budget_amount					decimal(18,2)
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
	declare @msg nvarchar(max) ;

	begin try 

		insert into procurement
		(
			code
			,company_code
			,procurement_request_item_id
			,procurement_request_code
			,procurement_request_date
			,branch_code
			,branch_name
			,item_code
			,item_name
			,type_code
			,type_name
			,type_asset_code
			,item_category_code
			,item_category_name
			,item_merk_code
			,item_merk_name
			,item_model_code
			,item_model_name
			,item_type_code
			,item_type_name
			,quantity_request
			,approved_quantity
			,specification
			,remark
			,new_purchase
			,purchase_type_code
			,purchase_type_name
			,quantity_purchase
			,status
			,requestor_code
			,requestor_name
			,unit_from
			,spaf_amount
			,subvention_amount
			,asset_amount
			,asset_discount_amount
			,karoseri_amount
			,karoseri_discount_amount
			,accesories_amount
			,accesories_discount_amount
			,application_no
			,mobilization_amount
			,otr_amount
			,gps_amount
			,budget_amount
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
		(	@p_code
			,@p_company_code
			,@p_procurement_request_item_id
			,@p_procurement_request_code
			,@p_procurement_request_date
			,@p_branch_code
			,@p_branch_name
			,@p_item_code
			,@p_item_name
			,@p_type_code
			,@p_type_name
			,@p_type_asset_code
			,@p_item_category_code
			,@p_item_category_name
			,@p_item_merk_code
			,@p_item_merk_name
			,@p_item_model_code
			,@p_item_model_name
			,@p_item_type_code
			,@p_item_type_name
			,@p_quantity_request
			,@p_approved_quantity
			,@p_specification
			,@p_remark
			,'YES'
			,@p_purchase_type_code
			,@p_purchase_type_name
			,@p_quantity_purchase
			,@p_status
			,@p_requestor_code
			,@p_requestor_name
			,@p_unit_from
			,@p_spaf_amount
			,@p_subvention_amount
			,@p_asset_amount
			,@p_asset_discount_amount
			,@p_karoseri_amount
			,@p_karoseri_discount_amount
			,@p_accesories_amount
			,@p_accesories_discount_amount
			,@p_application_no
			,@p_mobilization_amount
			,@p_otr_amount
			,@p_gps_amount
			,@p_budget_amount
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
		) ;
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

