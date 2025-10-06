
CREATE FUNCTION dbo.fn_get_ceiling
(
	 @p_value				decimal(18,2)
	 ,@p_round_value		decimal(18,2)	
)
returns decimal(18,2)	
as 
begin
	
	set	@p_value = ceiling(cast(@p_value as decimal(18,0)) / @p_round_value) * @p_round_value
	
	return @p_value
	
end
