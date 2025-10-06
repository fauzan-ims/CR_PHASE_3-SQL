
create PROCEDURE dbo.xsp_application_asset_budget_getrow
(
	@p_asset_no nvarchar(50)
)
as
begin
	select	asset_no
		   ,cost_code
		   ,cost_type
		   ,cost_amount_monthly
		   ,cost_amount_yearly 
	from	application_asset_budget
	where	asset_no = @p_asset_no ;
end ;
