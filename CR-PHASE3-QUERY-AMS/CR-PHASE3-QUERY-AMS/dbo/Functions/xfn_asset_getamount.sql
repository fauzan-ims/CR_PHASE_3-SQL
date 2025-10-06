

CREATE function dbo.xfn_asset_getamount
(
	@p_asset_no nvarchar(50)
)
returns decimal(18,2)
as
begin
	declare @amount			decimal(18,2)

	select	@amount = total_depre_comm
	from	dbo.asset
	where	code = @p_asset_no ;

	return @amount
end ;
