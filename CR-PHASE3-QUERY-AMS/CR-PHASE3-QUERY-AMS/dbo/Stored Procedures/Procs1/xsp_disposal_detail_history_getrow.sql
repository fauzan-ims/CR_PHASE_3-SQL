
create procedure xsp_disposal_detail_history_getrow
(
	@p_id			bigint
) as
begin

	select	id
			,disposal_code
			,asset_code
			,description
	from	disposal_detail_history
	where	id	= @p_id
end
