create FUNCTION dbo.xfn_get_ppn
(
	 @p_initial_discount_amount_period	decimal(18,2)
)
returns decimal(18,2)	
as 
BEGIN
	DECLARE @ppn decimal(18,2)
	
	set	@ppn = ROUND(10.00/100.00 * ISNULL(@p_initial_discount_amount_period,0),0)
	--set	@ppn = 0 --(10.00/100.00) * ISNULL(@p_initial_discount_amount_period,0)

	
	return @ppn
	
end

