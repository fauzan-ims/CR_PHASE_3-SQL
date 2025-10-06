
create procedure xsp_fin_interface_bank_mutation_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,gl_link_code
			,reff_no
			,reff_name
			,reff_remarks
			,mutation_date
			,mutation_value_date
			,mutation_orig_amount
			,mutation_exch_rate
			,mutation_base_amount
	from	fin_interface_bank_mutation
	where	id = @p_id ;
end ;
