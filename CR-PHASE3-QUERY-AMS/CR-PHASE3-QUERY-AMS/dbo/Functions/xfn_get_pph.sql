CREATE FUNCTION dbo.xfn_get_pph
(
	 @initial_discount_amount_period	decimal(18,2)
)
returns decimal(18,2)	
as 
BEGIN
	DECLARE @pph decimal(18,2)
	
	set	@pph = ROUND(2.00/100.00 * ISNULL(@initial_discount_amount_period,0),0)
	--set	@pph = 0--(2.00/100.00) * ISNULL(@initial_discount_amount_period,0)
	return @pph
	
end


