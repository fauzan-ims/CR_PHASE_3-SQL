CREATE FUNCTION dbo.xfn_get_gl_code_depre_accum
(
	@p_item_code	 nvarchar(50) = ''
	,@p_assset_code	 nvarchar(50)
	,@p_company_code nvarchar(50)
)
returns nvarchar(50)
as
begin
	declare @gl_asset_code		nvarchar(50)
			,@category_code		nvarchar(50)
			,@trx_gl_code		nvarchar(50);

	if @p_item_code = ''
	begin
		select	@category_code = category_code
		from	dbo.asset
		where	code = @p_assset_code ;

		select top 1 @trx_gl_code = transaction_accum_depre_code 
		from dbo.master_category
		where code		 = @category_code
		and company_code = @p_company_code
	end ;
	else
	begin
		select	@category_code = category_code
		from	dbo.asset
		where	code = @p_assset_code ;

		select top 1 @trx_gl_code = transaction_accum_depre_code 
		from dbo.master_category
		where code		 = @category_code
		and company_code = @p_company_code
	end ;

	return @gl_asset_code
end ;

