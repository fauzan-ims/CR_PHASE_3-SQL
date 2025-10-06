CREATE FUNCTION dbo.xfn_register_main_get_realization_ppn
(
	@p_code nvarchar(50)
)returns decimal(18, 2)
as
begin
	
	declare @return_amount				decimal(18,2)
			,@realization_ppn			bigint

		select	@realization_ppn	= (abs(realization_service_fee * realization_service_tax_ppn_pct / 100))
		from	dbo.register_main
		where	code = @p_code 

	set @return_amount = isnull(@realization_ppn,0)

	return @return_amount
end
