CREATE PROCEDURE dbo.xsp_change_item_type_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	cit.code
			,cit.date
			,cit.description
			,cit.branch_code
			,cit.branch_name
			,cit.from_item_code
			,cit.from_item_name
			,cit.to_item_code
			,cit.to_item_name
			,cit.from_net_book_value_comm
			,cit.from_net_book_value_fiscal
			,cit.to_net_book_value_comm
			,cit.to_net_book_value_fiscal
			,cit.from_category_code
			,cit.from_category_name
			,cit.to_category_code
			,cit.to_category_name
			,cit.cost_center_code
			,cit.cost_center_name
			,cit.purchase_price
			,cit.remark
			,cit.status
			,cit.asset_code 'asset_code'
			,a.barcode
	from	change_item_type	 cit
			inner join dbo.asset a on a.code = cit.asset_code collate Latin1_General_CI_AS
	where	cit.code = @p_code ;
end ;
