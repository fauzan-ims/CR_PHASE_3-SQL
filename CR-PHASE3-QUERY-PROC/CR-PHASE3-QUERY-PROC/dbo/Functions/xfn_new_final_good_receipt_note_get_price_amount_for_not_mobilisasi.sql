create FUNCTION [dbo].[xfn_new_final_good_receipt_note_get_price_amount_for_not_mobilisasi]
(
	@p_id	int
)returns decimal(18, 2)
as
begin
	
	declare @return_amount			decimal(18,2)
			,@price_amount			decimal(18, 2)


		select @price_amount = (aird.purchase_amount - aird.discount) --* aird.quantity
		from dbo.ap_invoice_registration_detail aird
		inner join ifinbam.dbo.master_item mi on mi.code collate latin1_general_ci_as = aird.item_code
		where id = @p_id
		and mi.item_group_code <> 'MOBLS'

	set @return_amount = isnull(@price_amount,0)

	return @return_amount
end
