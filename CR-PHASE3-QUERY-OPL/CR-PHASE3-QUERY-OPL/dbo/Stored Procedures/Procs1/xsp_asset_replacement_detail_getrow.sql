CREATE PROCEDURE dbo.xsp_asset_replacement_detail_getrow
(
	@p_id			bigint
) 
as
begin

	select	id
			,old_asset_no
			,new_fa_code
			,new_fa_name
			,replacement_type
			,reason_code
			,estimate_return_date
			,remark
	from	asset_replacement_detail
	where	id	= @p_id
end
