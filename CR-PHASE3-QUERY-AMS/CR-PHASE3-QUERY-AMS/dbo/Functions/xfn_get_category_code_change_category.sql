CREATE FUNCTION dbo.xfn_get_category_code_change_category
(
	@p_code nvarchar(50)
)
returns nvarchar(50)
as
begin
	declare @category_code nvarchar(50) ;

	select	@category_code = transaction_accum_depre_code
	from	dbo.master_category
	where	code = @p_code ;

	return @category_code ;
end ;
