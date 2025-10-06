
create procedure xsp_invoice_pph_getrow
(
	@p_id			bigint
) as
begin

	select	id
			,invoice_no
			,settlement_type
			,settlement_status
			,file_path
			,file_name
			,payment_reff_no
			,payment_reff_date
	from	invoice_pph
	where	id	= @p_id
end
