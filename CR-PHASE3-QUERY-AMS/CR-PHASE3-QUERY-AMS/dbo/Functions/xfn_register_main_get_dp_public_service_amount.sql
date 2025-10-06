create FUNCTION dbo.xfn_register_main_get_dp_public_service_amount
(
	@p_code nvarchar(50)
)returns decimal(18, 2)
as
begin
	
	declare @return_amount			decimal(18,2)
			,@dp_amount	decimal(18, 2)

		select	@dp_amount	= abs(dp_to_public_service_amount) 
		from	dbo.register_main
		where	code = @p_code 

	set @return_amount = isnull(@dp_amount,0)

	return @return_amount
end
