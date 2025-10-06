

CREATE FUNCTION [dbo].[xfn_invoice_registration_get_discount_amount]
(
	@p_id	bigint
)returns decimal(18, 2)
as
begin
	
	declare @return_amount			decimal(18,2)
			,@discount_amount		decimal(18, 2)

	select @discount_amount = discount * quantity --* quantity konsep diskon untuk semua unit yang di terima, jangan di kali quantity
	from dbo.ap_invoice_registration_detail
	where id = @p_id

	set @return_amount = isnull(@discount_amount,0)

	return @return_amount
end
