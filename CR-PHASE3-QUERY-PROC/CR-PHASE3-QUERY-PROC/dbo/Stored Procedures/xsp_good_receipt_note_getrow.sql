CREATE PROCEDURE [dbo].[xsp_good_receipt_note_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	grn.code
			,grn.company_code
			,grn.purchase_order_code
			,grn.receive_date
			,grn.supplier_code
			,grn.supplier_name
			,grn.branch_code
			,grn.branch_name
			,grn.division_code
			,grn.division_name
			,grn.department_code
			,grn.department_name
			,grn.remark
			,grn.status
			,po.unit_from
			,grn.cover_note_status
			,grn.is_validate
			--(+) Ari 2024-03-22 ket : add cr total qty, price, ppn, pph
			,isnull(grnd.total_receive_quantity, 0) 'total_receive_quantity'
			,isnull(grnd.total_unit_price, 0)		'total_unit_price'
			,isnull(grnd.total_ppn, 0)				'total_ppn'
			,isnull(grnd.total_pph, 0)				'total_pph'
			,grnd.total_amount						'total_grn_amount'
	from	good_receipt_note			  grn
			inner join dbo.purchase_order po on (po.code = grn.purchase_order_code)
			--(+) Ari 2024-03-22 ket : add cr total qty, price, ppn, pph
			outer apply
	(
		select	isnull(sum(receive_quantity), 0) 'total_receive_quantity'
				,isnull(sum(price_amount), 0)	 'total_unit_price'
				,isnull(sum(ppn_amount), 0)		 'total_ppn'
				,isnull(sum(pph_amount), 0)		 'total_pph'
				,isnull(sum(total_amount), 0)	 'total_amount'
		from	dbo.good_receipt_note_detail
		where	good_receipt_note_code = @p_code
		and receive_quantity <> 0
	)									  grnd
			outer apply
	(
		select	isnull(sum(price_amount), 0) + isnull(sum(ppn_amount), 0) - isnull(sum(pph_amount), 0) - isnull(sum(DISCOUNT_AMOUNT), 0) 'total_grn_amount'
		from	dbo.good_receipt_note_detail
		where	good_receipt_note_code = @p_code
				and receive_quantity   <> 0
	) grnd2
	--(+) Ari 2024-03-22 
	where	grn.code = @p_code ;
end ;
