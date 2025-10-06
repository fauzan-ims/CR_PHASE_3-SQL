CREATE FUNCTION dbo.xfn_get_gl_code_asset
(
	@p_item_code	 nvarchar(50) = ''
	,@p_assset_code	 nvarchar(50)
	,@p_company_code nvarchar(50)
)
returns nvarchar(50)
as
begin
	declare @item_code			nvarchar(50)
			,@gl_asset_code		nvarchar(50)
			,@item_group_code	nvarchar(50) ;

	if @p_item_code = ''
	begin
		select	@item_code = item_code
		from	dbo.asset
		where	code = @p_assset_code ;

		select @item_group_code = item_group_code 
		from ifinbam.dbo.master_item
		where code = @item_code

		select	top 1 @gl_asset_code = gl_asset_code
		from	ifinbam.dbo.master_item_group_gl
		where	item_group_code	 = @item_group_code
				and company_code = @p_company_code ;
	end ;
	else
	begin
		select @item_group_code = item_group_code 
		from ifinbam.dbo.master_item
		where code = @item_code

		select	top 1 @gl_asset_code = gl_asset_code
		from	ifinbam.dbo.master_item_group_gl
		where	item_group_code	 = @item_group_code
				and company_code = @p_company_code ;
	end ;

	--return @gl_asset_code ;
	return @gl_asset_code
end ;

