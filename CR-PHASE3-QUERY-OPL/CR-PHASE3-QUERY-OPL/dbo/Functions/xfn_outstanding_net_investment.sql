create function dbo.xfn_outstanding_net_investment
(
	@p_application_no nvarchar(50)
)
returns decimal(18, 2)
as
begin
	declare @return_amount decimal(18, 2)
			,@total_amount decimal(18, 2) ;

	select	@total_amount = isnull(sum(isnull(asset_amount, 0)), 0)
	from	dbo.application_asset
	where	application_no = @p_application_no ;

	select	@total_amount = @total_amount + isnull(sum(isnull(amount_finance_amount, 0)), 0)
	from	dbo.application_exposure
	where	application_no = @p_application_no ;

	set @return_amount = isnull(@total_amount, 0) ;

	return @return_amount ;
end ;
