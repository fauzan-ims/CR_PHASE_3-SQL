CREATE procedure dbo.xsp_budget_approval_get_data_status
(
	@p_asset_no nvarchar(50)
)
as
begin
	select	ba.asset_no
			,ba.status
	from	budget_approval ba
	where	ba.asset_no = @p_asset_no ;
end ;
