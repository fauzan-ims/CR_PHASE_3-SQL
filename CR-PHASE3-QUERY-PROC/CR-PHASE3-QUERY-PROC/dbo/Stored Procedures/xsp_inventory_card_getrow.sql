
create procedure xsp_inventory_card_getrow
(
	@p_id			bigint
) as
begin

	select	 id
			,company_code
			,branch_code
			,branch_name
			,transaction_code
			,transaction_type
			,transaction_period
			,item_code
			,item_name
			,warehouse_code
			,plus_or_minus
			,quantity
			,on_hand_quantity
	from	inventory_card
	where	id	= @p_id
end
