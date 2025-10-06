CREATE procedure dbo.xsp_disposal_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,disposal_code
			,asset_code
			,ass.item_name
			,description 'description_detail'
	from	disposal_detail dd
			inner join	dbo.asset ass on (ass.code = dd.asset_code)
	where	id = @p_id ;
end ;
