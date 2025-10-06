CREATE FUNCTION dbo.xfn_get_gl_code_from_category
(
	@p_assset_code		 nvarchar(50)
	,@p_company_code	 nvarchar(50)
	,@p_gl_link_code	 nvarchar(50)
)
returns nvarchar(50)
as
begin
	declare @gl_asset_code		nvarchar(50)
			,@category_code		nvarchar(50)
			,@trx_gl_code		nvarchar(50)
			,@depre_code		nvarchar(50)
			,@accum_depre_code	nvarchar(50)
			,@profit_sell_code	nvarchar(50)
			,@loss_sell_code	nvarchar(50);
	
	select	@depre_code			= mc.transaction_depre_code
			,@accum_depre_code	= mc.transaction_accum_depre_code
			,@profit_sell_code	= mc.transaction_profit_sell_code
			,@loss_sell_code	= mc.transaction_loss_sell_code
	from	dbo.master_category mc
			inner join dbo.asset ast on ast.category_code = mc.code
	where	ast.code = @p_assset_code

	if @p_gl_link_code = 'DFLTDPR'
		set @gl_asset_code = @depre_code
	else if @p_gl_link_code = 'DFACDPR'
		set @gl_asset_code = @accum_depre_code
	else if @p_gl_link_code = 'DFPFSLL'
		set @gl_asset_code = @profit_sell_code
	else if @p_gl_link_code = 'DFLFSLL'
		set @gl_asset_code = @loss_sell_code
	else
		set @gl_asset_code = @p_gl_link_code
		
	return @gl_asset_code

end ;
