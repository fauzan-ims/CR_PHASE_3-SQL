
create procedure xsp_doc_interface_agreement_collateral_aging_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,aging_date
			,agreement_no
			,collateral_no
			,branch_code
			,branch_name
			,locker_position
			,locker_name
			,drawer_name
			,row_name
			,document_status
			,mutation_type
			,mutation_location
			,mutation_from
			,mutation_to
			,mutation_by
			,mutation_date
			,mutation_return_date
			,last_mutation_type
			,last_mutation_date
			,last_locker_position
			,first_receive_date
			,release_customer_date
	from	doc_interface_agreement_collateral_aging
	where	id = @p_id ;
end ;
