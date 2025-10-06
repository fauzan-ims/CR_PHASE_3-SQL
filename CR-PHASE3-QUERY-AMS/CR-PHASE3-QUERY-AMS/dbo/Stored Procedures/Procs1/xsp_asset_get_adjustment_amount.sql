
CREATE procedure dbo.xsp_asset_get_adjustment_amount
(
    @p_company_code nvarchar(50)
  , @p_code nvarchar(50)
  , @p_asset_no nvarchar(50)
)
as
begin
    select	total_adjustment
    from	dbo.adjustment
    where	code				= @p_code
			and asset_code		= @p_asset_no
			and company_code	= @p_company_code;
end;
