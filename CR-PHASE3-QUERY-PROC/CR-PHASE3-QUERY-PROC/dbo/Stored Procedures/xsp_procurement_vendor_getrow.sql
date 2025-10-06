
CREATE procedure xsp_procurement_vendor_getrow
(
	@p_id			int
) as
begin

	select		id
		,procurement_code
		,vendor_code
		,vendor_name
	from	procurement_vendor
	where	id	= @p_id
end
