create FUNCTION dbo.xfn_register_main_get_realization_internal_income
(
	@p_code nvarchar(50)
)returns decimal(18, 2)
as
begin
	
	declare @return_amount					decimal(18,2)
			,@realization_internal_income	decimal(18, 2)

		select	@realization_internal_income	= abs(realization_internal_income) 
		from	dbo.register_main
		where	code = @p_code 

	set @return_amount = isnull(@realization_internal_income,0)

	return @return_amount
end
