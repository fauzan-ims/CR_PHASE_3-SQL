create procedure dbo.xsp_fin_interface_agreement_deposit_history_getrow
(
	@p_id bigint
)
as
begin
	select	dm.id,
            dm.branch_code,
            dm.branch_name,
            dm.agreement_no,
            dm.deposit_type,
            dm.transaction_date,
            dm.orig_amount,
            dm.orig_currency_code,
            dm.exch_rate,
            dm.base_amount,
            dm.source_reff_module,
            dm.source_reff_code,
            dm.source_reff_name
			,am.agreement_external_no
			,am.client_name
	from	dbo.fin_interface_agreement_deposit_history dm
			inner join dbo.agreement_main am on (am.agreement_no = dm.agreement_no)
	where	id = @p_id;
end ;
