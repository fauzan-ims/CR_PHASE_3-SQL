--created by, Rian at 17/02/2023 

CREATE procedure dbo.xsp_master_category_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	mc.code
			,mc.company_code
			,mc.description
			,asset_type_code
			,sgs.description 'general_subcode_desc'
			,mc.transaction_depre_code
			,mc.transaction_depre_name
			,mc.transaction_accum_depre_code
			,mc.transaction_accum_depre_name
			,mc.transaction_gain_loss_code
			,mc.transaction_gain_loss_name
			,mc.transaction_profit_sell_code
			,mc.transaction_profit_sell_name
			,mc.transaction_loss_sell_code
			,mc.transaction_loss_sell_name
			,mc.depre_cat_fiscal_code
			,mc.depre_cat_fiscal_name
			,mc.depre_cat_commercial_code
			,mc.depre_cat_commercial_name
			,last_depre_date
			,asset_amount_threshold
			,depre_amount_threshold
			,total_net_book_value_amount
			,total_accum_depre_amount
			,total_asset_value
			,mc.value_type
			,mc.nde
			,mc.is_active
	from	master_category mc
			left join dbo.sys_general_subcode sgs on (sgs.code = mc.asset_type_code)
	where	mc.code = @p_code ;
end ;
