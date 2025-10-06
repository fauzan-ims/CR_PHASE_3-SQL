CREATE FUNCTION dbo.xfn_get_amount_for_hfs
(
	@p_id bigint
)
returns decimal(18, 2)
as
begin
	declare @purchase_price		decimal(18,2)
			,@accum_depre		decimal(18,2)
			,@amount			bigint--decimal(18, 2)
	
	select @purchase_price = purchase_price 
	from dbo.asset
	where code = 
	(
		select asset_code 
		from dbo.sale_detail
		where id = @p_id
	)

	select @accum_depre = max(accum_depre_amount) 
	from dbo.asset_depreciation_schedule_commercial
	where asset_code = 
	(
		select asset_code 
		from dbo.sale_detail
		where id = @p_id
	)
	and isnull(transaction_code, '') <> ''

	set @amount = @purchase_price - @accum_depre
	 

	return @amount ;
end ;
