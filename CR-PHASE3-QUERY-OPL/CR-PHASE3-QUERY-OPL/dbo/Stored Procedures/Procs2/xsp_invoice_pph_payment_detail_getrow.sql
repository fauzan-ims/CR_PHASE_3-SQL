
create procedure xsp_invoice_pph_payment_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id
			,tax_payment_code
			,invoice_no
			,pph_amount
	from	invoice_pph_payment_detail
	where	id = @p_id ;
end ;
