
create procedure xsp_master_currency_rate_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,currency_code
			,eff_date
			,exch_rate
	from	master_currency_rate
	where	id = @p_id ;
end ;
