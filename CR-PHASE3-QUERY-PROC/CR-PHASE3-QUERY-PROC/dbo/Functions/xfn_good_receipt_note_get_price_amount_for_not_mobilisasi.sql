-- User Defined Function

CREATE FUNCTION dbo.xfn_good_receipt_note_get_price_amount_for_not_mobilisasi
(
	@p_id	int
    ,@p_po_object_id	bigint
)returns decimal(18, 2)
as
begin

	declare @return_amount			decimal(18,2)
			,@price_amount			decimal(18, 2)
			--
			,@id_grn_request_detail bigint


		select	@price_amount = (price_amount - grnd.discount_amount) --* receive_quantity
		from	dbo.good_receipt_note_detail grnd
				inner join ifinbam.dbo.master_item mi on mi.code = grnd.item_code
				inner join dbo.purchase_order_detail_object_info podoi  on podoi.good_receipt_note_detail_id = grnd.id
		where	grnd.id = @p_id
		and		podoi.id = @p_po_object_id
		and		mi.item_group_code not in ('MOBLS', 'EXPS')--<> 'MOBLS'
		and		grnd.invoice_detail_id is null

	set @return_amount = isnull(@price_amount,0)


	--	select @price_amount = (price_amount - grnd.discount_amount) --* receive_quantity
	--	from dbo.good_receipt_note_detail grnd
	--	inner join ifinbam.dbo.master_item mi on mi.code = grnd.item_code
	--	where id = @p_id
	--	and mi.item_group_code not in ('MOBLS', 'EXPS')--<> 'MOBLS'
	--	--30/06/2025: ambil yng belum di bayar
	--	and		not exists (	select invd.grn_detail_id from dbo.ap_invoice_registration_detail invd
	--								inner join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
	--								where inv.status in ('POST','APPROVE')
	--								AND		grn_detail_id =  grnd.id)

	--set @return_amount = isnull(@price_amount,0)

	return @return_amount
end
