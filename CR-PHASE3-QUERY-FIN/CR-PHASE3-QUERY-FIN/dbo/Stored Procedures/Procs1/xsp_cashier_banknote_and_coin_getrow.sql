
create procedure xsp_cashier_banknote_and_coin_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,cashier_code
			,banknote_code
			,quantity
			,total_amount
	from	cashier_banknote_and_coin
	where	id = @p_id ;
end ;
