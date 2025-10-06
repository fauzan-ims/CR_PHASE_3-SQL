
CREATE procedure xsp_sale_detail_history_getrow
(
	@p_id			bigint
) as
begin

	select	id
			,sale_code
			,asset_code
			,description
			,net_book_value
			,sale_value
			,cost_center_code
	from	sale_detail_history
	where	id	= @p_id
end
