CREATE FUNCTION [dbo].[xfn_invoice_registration_get_price_amount_without_asset_backup_for_compare_to_qa]
(
	@p_id	bigint
    ,@p_po_object_id	bigint = 0
)returns decimal(18, 2)
as
begin


	declare @return_amount				decimal(18,2)
			,@price_amount				decimal(18, 2)
			,@category_type				nvarchar(50)
			,@is_journal_asset			nvarchar(1)
			,@id_fgrnr_asset			int
			,@grn_code_category_asset	nvarchar(50)
			,@invoice_code				nvarchar(50)
			,@grn_code					nvarchar(50)
			,@item_group_code			nvarchar(50)
			,@grn_detail_id_asset		bigint
            ,@fgrn_request_status		nvarchar(50)
			,@invoice_asset_status		nvarchar(50)
			,@fgrn_detail_id			bigint
            ,@grnd_id					bigint
            ,@procurement_type			nvarchar(50)
			,@status_final				nvarchar(50)
			,@id_grn_request_detail		bigint
			
	SELECT	@procurement_type	= pr.procurement_type
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
			-- 30/06/2025 INTRANSIT: JIKA BELULM FINAL, MAKA SAAT INVOICE, NILAI ASSET/ACC/KAROSERI DI SIMPAN DI INTRANSIT
			select	@id_grn_request_detail = fgrnd.id
			from	dbo.ap_invoice_registration_detail invd
					inner join dbo.ap_invoice_registration_detail_faktur invdf on invdf.invoice_registration_detail_id = invd.id
					inner join dbo.final_grn_request_detail fgrnd on fgrnd.grn_detail_id_asset = invd.grn_detail_id and invdf.purchase_order_detail_object_info_id = fgrnd.grn_po_detail_id
			where	invd.id = @p_id
			and		grn_po_detail_id = @p_po_object_id
			and		fgrnd.status = 'POST'

			if isnull(@id_grn_request_detail,0) = 0
			begin
				select	@id_grn_request_detail = fgrnd.id
				from	dbo.ap_invoice_registration_detail invd
						inner join dbo.ap_invoice_registration_detail_faktur invdf on invdf.invoice_registration_detail_id = invd.id
						inner join dbo.final_grn_request_detail_accesories_lookup fgrndl on fgrndl.grn_po_detail_id = invdf.purchase_order_detail_object_info_id
						inner join dbo.final_grn_request_detail_accesories fgrnda on fgrnda.final_grn_request_detail_accesories_id = fgrndl.id
						inner join dbo.final_grn_request_detail fgrnd on fgrnd.id = fgrnda.final_grn_request_detail_id 
				where	invd.id = @p_id
				and		fgrndl.grn_po_detail_id = @p_po_object_id
				and		fgrnd.status = 'POST'

				if isnull(@id_grn_request_detail,0) = 0
				begin
					select	@id_grn_request_detail = fgrnd.id
					from	dbo.ap_invoice_registration_detail invd
							inner join dbo.ap_invoice_registration_detail_faktur invdf on invdf.invoice_registration_detail_id = invd.id
							inner join dbo.final_grn_request_detail_karoseri_lookup fgrndl on fgrndl.grn_po_detail_id = invdf.purchase_order_detail_object_info_id
							inner join dbo.final_grn_request_detail_karoseri fgrnda on fgrnda.final_grn_request_detail_karoseri_id = fgrndl.id
							inner join dbo.final_grn_request_detail fgrnd on fgrnd.id = fgrnda.final_grn_request_detail_id
					where	invd.id = @p_id
					and		fgrndl.grn_po_detail_id = @p_po_object_id
					and		fgrnd.status = 'POST'
				end
			end
    
			declare @frgna_status nvarchar(50),@podoi_invoice_id bigint

			select	@frgna_status = frgna.status
					,@podoi_invoice_id	= podoi.invoice_id	
			from	dbo.final_grn_request_detail frgna
					inner join dbo.purchase_order_detail_object_info podoi on podoi.id = frgna.grn_po_detail_id
			where	frgna.id = @id_grn_request_detail
	
			-- jika sudah post grn request tp asset belum di bayar
			if (@frgna_status = 'POST')
			begin
				if(isnull(@podoi_invoice_id,0) = 0)
				begin
					select	@return_amount = isnull(invd.purchase_amount,0) - isnull(invd.discount,0) 
					from	dbo.ap_invoice_registration_detail invd
							inner join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
							inner join dbo.ap_invoice_registration_detail_faktur invdf on invdf.invoice_registration_detail_id = invd.id
					where	invd.id = @p_id
					and		invdf.purchase_order_detail_object_info_id = @p_po_object_id
				end
				else
				begin
					select	@return_amount = (isnull(invd.purchase_amount,0) - isnull(invd.discount,0)) * -1
					from	dbo.ap_invoice_registration_detail invd
							inner join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
							inner join dbo.ap_invoice_registration_detail_faktur invdf on invdf.invoice_registration_detail_id = invd.id
					where	invd.id = @p_id
					and		invdf.purchase_order_detail_object_info_id = @p_po_object_id
				end
			end
			else
			begin
					select	@return_amount = (isnull(invd.purchase_amount,0) - isnull(invd.discount,0))
					from	dbo.ap_invoice_registration_detail invd
							inner join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
							inner join dbo.ap_invoice_registration_detail_faktur invdf on invdf.invoice_registration_detail_id = invd.id
					where	invd.id = @p_id
					and		invdf.purchase_order_detail_object_info_id = @p_po_object_id
			END
	end
	return @return_amount
end
