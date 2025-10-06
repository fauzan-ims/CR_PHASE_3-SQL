
create procedure xsp_master_tax_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,tax_code
			,effective_date
			,from_value_amount
			,to_value_amount
			,with_tax_number_pct
			,without_tax_number_pct
	from	master_tax_detail
	where	id = @p_id ;
end ;
