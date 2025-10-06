-- User Defined Function

-- User Defined Function

-- User Defined Function

CREATE FUNCTION dbo.xfn_crp_invoice_registration_get_ppn_amount
(
	@p_id	bigint
)returns decimal(18, 2)
as
begin
	
	declare @return_amount			decimal(18,2)
			,@ppn_amount			decimal(18, 2)

	select @ppn_amount = (ppn / quantity) --* quantity
	from dbo.ap_invoice_registration_detail
	where id = @p_id

	set @return_amount = isnull(@ppn_amount,0)

	return @return_amount
end
