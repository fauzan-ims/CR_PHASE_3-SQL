

-- User Defined Function


CREATE FUNCTION dbo.xfn_crp_good_receipt_note_get_price_amount_expense
(
	@p_id	int
)returns decimal(18, 2)
as
begin
	
	declare @return_amount			decimal(18,2)
			,@price_amount			decimal(18, 2)


		select @price_amount = (price_amount - grnd.discount_amount) * receive_quantity
		from dbo.good_receipt_note_detail grnd
		inner join ifinbam.dbo.master_item mi on mi.code = grnd.item_code
		where id = @p_id
		and mi.item_group_code = 'EXPS'

	set @return_amount = isnull(@price_amount,0)

	return @return_amount
end
