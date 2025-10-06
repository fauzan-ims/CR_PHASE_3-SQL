
CREATE PROCEDURE dbo.xsp_write_off_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,write_off_code
			,asset_no 
			,is_take_assets
	from	write_off_detail
	where	id = @p_id ;
end ;

