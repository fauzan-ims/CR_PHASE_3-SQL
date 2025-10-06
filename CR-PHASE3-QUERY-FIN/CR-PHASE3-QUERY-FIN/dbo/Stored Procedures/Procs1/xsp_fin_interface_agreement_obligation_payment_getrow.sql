CREATE PROCEDURE dbo.xsp_fin_interface_agreement_obligation_payment_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,code
			,am.agreement_external_no
			,am.client_name
			,installment_no
			,obligation_type
			,payment_date
			,value_date
			,payment_source_type
			,payment_source_no
			,payment_amount
			,payment_remarks
			,is_waive
	from	fin_interface_agreement_obligation_payment fiaop
			left join dbo.agreement_main am on (am.agreement_no = fiaop.agreement_no)
	where	id = @p_id ;
end ;
