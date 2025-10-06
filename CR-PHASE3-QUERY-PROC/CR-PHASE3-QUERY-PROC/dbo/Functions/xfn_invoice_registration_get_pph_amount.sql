
-- User Defined Function

CREATE FUNCTION [dbo].[xfn_invoice_registration_get_pph_amount]
(
	@p_id	bigint
    ,@p_po_object_id	bigint = 0
)returns decimal(18, 2)
as
begin

	declare @return_amount			decimal(18,2)
			,@pph_amount			decimal(18, 2)

	select @pph_amount = pph / quantity
	from dbo.ap_invoice_registration_detail
	where id = @p_id

	set @return_amount = isnull(@pph_amount,0)

	return @return_amount
end
