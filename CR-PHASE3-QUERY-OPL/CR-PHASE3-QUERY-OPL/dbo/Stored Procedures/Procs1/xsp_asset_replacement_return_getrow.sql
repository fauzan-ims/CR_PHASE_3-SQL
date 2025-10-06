
CREATE procedure xsp_asset_replacement_return_getrow
(
	@p_id			bigint
) 
as
begin

	select	id
			,replacement_code
			,new_asset_code
			,reason_code
			,estimate_date
			,remark
			,status
	from	asset_replacement_return
	where	id	= @p_id

end
