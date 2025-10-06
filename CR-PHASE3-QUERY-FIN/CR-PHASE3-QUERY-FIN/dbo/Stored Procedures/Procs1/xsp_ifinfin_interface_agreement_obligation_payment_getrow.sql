
create procedure xsp_ifinfin_interface_agreement_obligation_payment_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,obligation_code
			,agreement_no
			,installment_no
			,payment_date
			,value_date
			,payment_source_type
			,payment_source_no
			,payment_amount
	from	ifinfin_interface_agreement_obligation_payment
	where	id = @p_id ;
end ;
