
-- exec [fn_get_ceiling] 1750356.00, 1000.00
CREATE FUNCTION dbo.fn_get_round
(
	 @p_value				decimal(18,2)
	 ,@p_round_value		decimal(18,2)	
)
returns decimal(18,2)	
as 
begin
	
	set	@p_value = round(@p_value / @p_round_value, 0) * @p_round_value
	
	return @p_value
	
end
