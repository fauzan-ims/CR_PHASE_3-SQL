CREATE FUNCTION dbo.xfn_threshold_validation
(@p_category nvarchar(50),@p_purchase_price decimal(18,2))
returns int
as
begin
	
	declare @is_valid			int = 1
			,@amount_threshold	decimal(18,2)
			,@value_type		nvarchar(50)
	
	select	@amount_threshold	= asset_amount_threshold
			,@value_type		= value_type
	from	dbo.master_category
	where	code = @p_category
	
	if (@value_type = 'HIGH VALUE' and @p_purchase_price < @amount_threshold)
	begin
		set @is_valid = 0
	end
	else if (@value_type = 'LOW VALUE' and @p_purchase_price >= @amount_threshold)
	begin
		set @is_valid = 0
	end
		
    return @is_valid;

end
