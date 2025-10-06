CREATE FUNCTION dbo.xfn_get_gl_code_from_item_grup_gl
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
			,@asset_code		nvarchar(50)
			,@asset_in_progress	nvarchar(50)
			,@expense_code		nvarchar(50);
	
	if right(@p_gl_link_code,2) <> 'BI'
	begin
	
		select	@asset_code			= mc.gl_asset_code
				,@asset_in_progress	= mc.gl_inprogress_code
				,@expense_code		= mc.gl_expend_code
		from	ifinbam.dbo.master_item_group_gl mc
				inner join ifinbam.dbo.master_item mi on mi.item_group_code = mc.item_group_code
				inner join dbo.asset ast on ast.item_code = mi.code
		where	ast.code = @p_assset_code

		if @p_gl_link_code = 'DFASST'
			set @gl_asset_code = @asset_code
		else if @p_gl_link_code = 'DFASIN'
		begin
			set @gl_asset_code = @asset_in_progress
		end
		else if @p_gl_link_code = 'DFEXIN'
		begin	    
			select @gl_asset_code = gl_expend_code
			from	ifinbam.dbo.master_item_group_gl mc
				inner join ifinbam.dbo.master_item mi on mi.item_group_code = mc.item_group_code
			where	mi.code = @p_assset_code
		end
		else
			set @gl_asset_code = @p_gl_link_code
	end
	else
	begin
		select	@asset_code			= mc.gl_asset_code
				,@asset_in_progress	= mc.gl_inprogress_code
				,@expense_code		= mc.gl_expend_code
		from	ifinbam.dbo.master_item_group_gl mc
				inner join ifinbam.dbo.master_item mi on mi.item_group_code = mc.item_group_code
		where	mi.code = @p_assset_code

		if @p_gl_link_code = 'DFASSTBI'
			set @gl_asset_code = @asset_code
		else if @p_gl_link_code = 'DFASINBI'
		begin
			set @gl_asset_code = @asset_in_progress
		end
		else if @p_gl_link_code = 'DFEXINBI'
		begin	    
			select @gl_asset_code = gl_expend_code
			from	ifinbam.dbo.master_item_group_gl mc
				inner join ifinbam.dbo.master_item mi on mi.item_group_code = mc.item_group_code
			where	mi.code = @p_assset_code
		end
		else
			set @gl_asset_code = @p_gl_link_code	    
	end
		
	return @gl_asset_code

end ;
