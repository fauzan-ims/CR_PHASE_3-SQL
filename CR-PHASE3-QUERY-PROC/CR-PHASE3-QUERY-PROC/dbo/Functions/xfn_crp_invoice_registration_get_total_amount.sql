-- User Defined Function

-- User Defined Function

-- User Defined Function

-- User Defined Function

CREATE FUNCTION dbo.xfn_crp_invoice_registration_get_total_amount
(
	@p_id	bigint
)returns decimal(18, 2)
as
begin
	
	declare @return_amount			decimal(18,2)
			,@price_amount			decimal(18, 2)

	select @price_amount = (((purchase_amount - discount) + (ppn/quantity) - (pph/quantity))) --* quantity) --* quantity) + ppn - pph)  --*  konsep diskon untuk semua unit yang di terima, diskon after unit* quantity
	from dbo.ap_invoice_registration_detail
	where id = @p_id

	set @return_amount = isnull(@price_amount,0)

	return @return_amount
end
