CREATE PROCEDURE dbo.xsp_fin_interface_agreement_fund_in_used_history_getrow
(
	@p_id bigint
)
as
begin
	select	id
            ,fiafiuh.agreement_no
			,am.agreement_external_no
			,am.client_name
            ,charges_date
            ,charges_type
            ,transaction_no
            ,transaction_name
            ,charges_amount
            ,source_reff_module
            ,source_reff_remarks
	from	fin_interface_agreement_fund_in_used_history fiafiuh
			left join dbo.agreement_main am on (am.agreement_no = fiafiuh.agreement_no)
	where	id = @p_id ;
end ;
