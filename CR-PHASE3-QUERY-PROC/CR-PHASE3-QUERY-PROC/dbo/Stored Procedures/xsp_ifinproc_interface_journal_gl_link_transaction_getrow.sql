create PROCEDURE dbo.xsp_ifinproc_interface_journal_gl_link_transaction_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,code
			,branch_code
			,branch_name
			,transaction_status
			,transaction_date
			,transaction_value_date
			,transaction_code
			,transaction_name
			,reff_module_code
			,reff_source_no
			,reff_source_name
			,is_journal_reversal
			,reversal_reff_no
	from	dbo.ifinproc_interface_journal_gl_link_transaction
	where	id = @p_id ;
end ;
