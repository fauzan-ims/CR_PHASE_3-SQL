CREATE PROCEDURE dbo.xsp_change_category_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	cc.code
			,cc.company_code
			,date
			,asset_code
			,ass.item_name
			,ass.depre_category_comm_code
			,mdcm2.description 'depre_category_comm_name'
			,ass.depre_category_fiscal_code
			,mdcf2.description 'depre_category_fiscal_name'
			,ass.category_code
			,ass.item_code
			,ass.original_price
			,ass.net_book_value_comm
			,cc.branch_code
			,cc.to_item_name
			,cc.branch_name
			,cc.description
			,cc.from_category_name
			,cc.from_category_code
			,to_category_code
			,cc.to_category_name
			,from_item_code
			,to_item_code
			,to_depre_category_fiscal_code
			,mdcm.description 'description_commercial'
			,to_depre_category_comm_code
			,mdcf.description 'description_fiscal'
			,cc.from_net_book_value_comm	
			,cc.to_net_book_value_comm		
			,cc.from_net_book_value_fiscal	
			,cc.to_net_book_value_fiscal	
			,ass.purchase_price						
			,cc.remarks
			,cc.status
			,ass.barcode
			,cc.from_depre_category_fiscal_code
			,cc.from_depre_category_comm_code
	from	change_category cc
	left join dbo.asset ass on (ass.code = cc.asset_code) and (ass.company_code = cc.company_code)
	left join dbo.master_depre_category_commercial mdcm on (mdcm.code = cc.to_depre_category_comm_code)
	left join dbo.master_depre_category_fiscal mdcf on (mdcf.code = cc.to_depre_category_fiscal_code)
	left join dbo.master_depre_category_commercial mdcm2 on (mdcm2.code = cc.from_depre_category_comm_code)
	left join dbo.master_depre_category_fiscal mdcf2 on (mdcf2.code = cc.from_depre_category_fiscal_code)
	where	cc.code = @p_code ;

end ;
