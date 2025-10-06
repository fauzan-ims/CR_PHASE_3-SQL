-- exec [fn_get_ceiling] 1750356.00, 1000.00
CREATE FUNCTION dbo.fn_get_floor
(
	 @p_value				decimal(18,2)
	 ,@p_round_value		decimal(18,2)	
)
returns decimal(18,2)	
as 
begin
	
	set	@p_value = floor(@p_value / @p_round_value) * @p_round_value
	
	return @p_value
	
end

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[fn_get_floor] TO [ims-raffyanda]
    AS [dbo];

