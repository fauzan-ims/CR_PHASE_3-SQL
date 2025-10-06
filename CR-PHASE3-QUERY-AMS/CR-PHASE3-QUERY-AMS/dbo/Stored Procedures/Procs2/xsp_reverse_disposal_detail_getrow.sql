
create procedure xsp_reverse_disposal_detail_getrow
(
	@p_id			bigint
) as
begin

	select		id
		,reverse_disposal_code
		,asset_code
		,description
	from	reverse_disposal_detail
	where	id	= @p_id
end
