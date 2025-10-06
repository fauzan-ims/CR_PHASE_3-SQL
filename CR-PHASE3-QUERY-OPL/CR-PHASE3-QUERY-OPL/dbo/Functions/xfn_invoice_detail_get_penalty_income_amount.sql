CREATE FUNCTION dbo.xfn_invoice_detail_get_penalty_income_amount
(
	@p_id bigint
)
returns decimal(18, 2)
as
begin
	declare @total_amount			 decimal(18, 2)
			,@total_invoice_amount	 decimal(18, 2)
			,@pph_amount			 decimal(18, 2) ;

	set @total_invoice_amount = dbo.xfn_invoice_detail_get_total_amount(@p_id) ;
	set @pph_amount = dbo.xfn_invoice_detail_get_pph_amount(@p_id) ;
	set @total_amount = @total_invoice_amount - @pph_amount ;

	return isnull(@total_amount, 0) ;
end ;
