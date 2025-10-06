
CREATE procedure xsp_master_banknote_and_coin_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,description
			,type
			,value_amount
			,is_active
	from	master_banknote_and_coin
	where	code = @p_code ;
end ;
