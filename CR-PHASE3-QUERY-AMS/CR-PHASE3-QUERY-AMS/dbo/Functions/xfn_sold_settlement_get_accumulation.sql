CREATE FUNCTION dbo.xfn_sold_settlement_get_accumulation
(
	@p_id bigint
)
returns decimal(18, 2)
as
begin
	declare @amount			   decimal(18, 2)
	-- mendapatkan accumulasi asset untuk sale
	--select	@amount = total_depre_comm
	--from	asset
	--where	code =
	--(
	--	select	asset_code
	--	from	dbo.sale_detail
	--	where	id = @p_id
	--) ;

	select @amount = max(accum_depre_amount) 
	from dbo.asset_depreciation_schedule_commercial
	where asset_code = 
	(
		select asset_code 
		from dbo.sale_detail
		where id = @p_id
	)
	and isnull(transaction_code, '') <> ''

	 

	return @amount ;
end ;
