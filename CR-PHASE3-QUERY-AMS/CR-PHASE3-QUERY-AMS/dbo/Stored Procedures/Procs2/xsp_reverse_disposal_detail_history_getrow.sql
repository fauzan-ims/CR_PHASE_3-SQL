
create procedure xsp_reverse_disposal_detail_history_getrow
(
	@p_id			bigint
) as
begin

	select	id
			,reverse_disposal_code
			,asset_code
			,cost_center_code
			,cost_center_name
			,description
	from	reverse_disposal_detail_history
	where	id	= @p_id
end
