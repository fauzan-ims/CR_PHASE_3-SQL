create procedure dbo.xsp_asset_get_adjustment_amount_reval_after_tax_with_special_formula
(
    @p_company_code nvarchar(50)
  , @p_code			nvarchar(50)
  , @p_asset_no		nvarchar(50)
)
as
begin
    declare @pajak	decimal(18,2)
	
	select	(total_adjustment * (22-10)) / 100.00
    from	dbo.adjustment adj
			inner join dbo.asset ast on adj.asset_code = ast.code
    where	asset_code		= @p_asset_no
			and adj.company_code	= @p_company_code;
end;
