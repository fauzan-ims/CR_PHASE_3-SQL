CREATE FUNCTION dbo.xfn_get_category_code
(
	@p_code nvarchar(50)
)
returns nvarchar(50)
as
begin
	declare @category_code			nvarchar(50)
			,@tran_accum_depre_code nvarchar(50) ;

	select	@category_code = type_code
	from	dbo.asset
	where	code = @p_code ;

	select	@tran_accum_depre_code = transaction_accum_depre_code
	from	dbo.master_category
	where	asset_type_code = @category_code ;

	return @tran_accum_depre_code ;
end ;
