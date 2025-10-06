CREATE FUNCTION dbo.xfn_get_asset_gl_code_by_item_rent
(
	@p_item_group_code		 nvarchar(50)
)
returns nvarchar(50)
as
begin
	declare @gl_asset_code		nvarchar(50)

	select @gl_asset_code = gl_asset_rent_code 
	from dbo.master_item_group_gl
	where item_group_code = @p_item_group_code

	return @gl_asset_code

end ;
