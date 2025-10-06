CREATE PROCEDURE dbo.xsp_reverse_sale_detail_history_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,reverse_sale_code
			,asset_code
			,description
			,sale_value
	from	reverse_sale_detail
	where	id = @p_id ;
end ;
