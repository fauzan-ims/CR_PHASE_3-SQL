CREATE procedure dbo.xsp_asset_get_net_book_value_comm_amount
(
	@p_company_code nvarchar(50)
	,@p_code		nvarchar(50)
	,@p_asset_no	nvarchar(50)
)
as
begin
	select	net_book_value_comm
	from	dbo.asset
	where	code = @p_asset_no ;
end ;
