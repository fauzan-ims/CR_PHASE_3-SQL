create FUNCTION dbo.xfn_register_main_get_invoice_amount
(
	@p_code nvarchar(50)
)returns decimal(18, 2)
as
begin
	
	declare @return_amount			decimal(18,2)
			,@realization_amount	decimal(18, 2)

		select	@realization_amount				= isnull(realization_service_fee + realization_actual_fee,0)
		from	dbo.register_main
		where	code = @p_code 

	set @return_amount = isnull(@realization_amount,0)

	return @return_amount
end
