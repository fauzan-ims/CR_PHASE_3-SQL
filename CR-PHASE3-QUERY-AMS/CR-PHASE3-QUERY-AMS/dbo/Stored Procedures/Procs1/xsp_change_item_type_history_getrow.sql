
CREATE PROCEDURE dbo.xsp_change_item_type_history_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,date
			,description
			,branch_code
			,branch_name
			,location_code
			,location_name
			,from_item_code
			,from_item_name
			,to_item_code
			,to_item_name
			,from_net_book_value_comm
			,from_net_book_value_fiscal
			,to_net_book_value_comm
			,to_net_book_value_fiscal
			,from_category_code
			,from_category_name
			,to_category_code
			,to_category_name
			,cost_center_code
			,cost_center_name
			,purchase_price
			,remark
			,status
			,asset_code
			,barcode
	from	dbo.change_item_type_history
	where	code = @p_code ;
end ;
