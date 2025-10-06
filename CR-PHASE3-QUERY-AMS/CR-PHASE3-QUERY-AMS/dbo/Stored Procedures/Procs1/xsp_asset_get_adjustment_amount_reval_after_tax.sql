
create procedure xsp_asset_get_adjustment_amount_reval_after_tax
(
    @p_company_code nvarchar(50)
  , @p_code nvarchar(50)
  , @p_asset_no nvarchar(50)
)
as
begin
    select	((total_adjustment + ast.total_depre_comm) * 10) / 100.00
    from	dbo.adjustment adj
			inner join dbo.asset ast on adj.asset_code = ast.code
    where	adj.code				= @p_code
			and asset_code		= @p_asset_no
			and adj.company_code	= @p_company_code;
end;
