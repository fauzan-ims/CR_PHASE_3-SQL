CREATE procedure dbo.xsp_term_of_payment_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,po_code
			,transaction_code
			,transaction_name
			,transaction_date
			,termin_type_code
			,termin_type_name
			,refference_code
			,percentage
			,amount
			,is_paid
			,pph_amount
			,ppn_amount
			,remark
	from	term_of_payment
	where	id = @p_id ;
end ;
