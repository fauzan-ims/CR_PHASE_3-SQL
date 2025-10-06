
-- User Defined Function

CREATE FUNCTION [dbo].[xfn_invoice_registration_get_price_amount_aoip]
(
	@p_id	bigint
    ,@p_po_object_id	bigint = 0
)returns  decimal(18,2)
as
begin

	declare @return_amount			decimal(18,2)
			,@price_amount			decimal(18, 2)
			,@procurement_type		nvarchar(50)
			,@grn_id				bigint

	select	@grn_id = invd.grn_detail_id
			,@procurement_type	= pr.procurement_type
	from	dbo.ap_invoice_registration_detail				invd
			inner join dbo.good_receipt_note_detail grnd on grnd.good_receipt_note_code = invd.grn_code and grnd.item_code collate sql_latin1_general_cp1_ci_as = invd.item_code collate sql_latin1_general_cp1_ci_as and invd.quantity > 0
			inner join dbo.good_receipt_note				grn on (grn.code							  = grnd.good_receipt_note_code)
			inner join dbo.purchase_order					po on (po.code								  = grn.purchase_order_code)
			inner join dbo.purchase_order_detail			pod on (
																		pod.po_code						  = po.code
																		and pod.id						  = grnd.purchase_order_detail_id
																	)
			left join dbo.purchase_order_detail_object_info podoi on (
																			podoi.purchase_order_detail_id	  = pod.id
																			and   grnd.id					  = podoi.good_receipt_note_detail_id
																		)
			inner join dbo.supplier_selection_detail		ssd on (ssd.id								  = pod.supplier_selection_detail_id)
			left join dbo.quotation_review_detail			qrd on (qrd.id								  = ssd.quotation_detail_id)
			inner join dbo.procurement						prc on (prc.code collate latin1_general_ci_as = isnull(qrd.reff_no, ssd.reff_no))
			inner join dbo.procurement_request				pr on (prc.procurement_request_code			  = pr.code)
	where	invd.id = @p_id
	and		grnd.receive_quantity	<> 0

	if(@procurement_type = 'PURCHASE')
	begin
		--select @price_amount = (purchase_amount - discount)-- * quantity
		--from dbo.ap_invoice_registration_detail
		--where id = @p_id

		--12082025: sepria, CR Priority. ini dengan nilai = di GRN
		select	@price_amount = isnull(price_amount,0) - isnull(discount_amount,0)
		from	dbo.good_receipt_note_detail
		where	id = @grn_id

	end

	set @return_amount = isnull(@price_amount,0)
	return @return_amount
end
