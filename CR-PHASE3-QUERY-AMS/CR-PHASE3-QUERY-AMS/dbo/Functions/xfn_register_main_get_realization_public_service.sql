create FUNCTION dbo.xfn_register_main_get_realization_public_service
(
	@p_code nvarchar(50)
)returns decimal(18, 2)
as
begin
	
	declare @return_amount			decimal(18,2)
			,@realization_amount	decimal(18, 2)

		select	@realization_amount	= abs(public_service_settlement_amount) 
		from	dbo.register_main
		where	code = @p_code 

	set @return_amount = isnull(@realization_amount,0)

	return @return_amount
end
