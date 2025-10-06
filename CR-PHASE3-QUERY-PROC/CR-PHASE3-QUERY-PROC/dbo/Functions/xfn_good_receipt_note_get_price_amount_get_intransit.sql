
-- User Defined Function

CREATE FUNCTION dbo.xfn_good_receipt_note_get_price_amount_get_intransit
(
	@p_id	int
    ,@p_po_detail_object_id	bigint
)returns decimal(18, 2)
as
begin

	declare @return_amount			decimal(18,2)
			,@id_grn_request_detail	bigint

	-- cek, jika sudah dibayar semua, dicatat sebagai asset, jika ada yg belum dibayar maka di catat di intransit. ambil nilai dari invoice
	-- cari id dari grn request detail dulu:
	select	@id_grn_request_detail = id
	from	dbo.final_grn_request_detail
	where	grn_detail_id_asset = @p_id
	and		grn_po_detail_id = @p_po_detail_object_id

	if isnull(@id_grn_request_detail,0) = 0
	begin
	    select	@id_grn_request_detail = fgrnd.id
		from	dbo.final_grn_request_detail_accesories_lookup fgrndl
				inner join dbo.final_grn_request_detail_accesories fgrnda on fgrnda.final_grn_request_detail_accesories_id = fgrndl.id
				inner join dbo.final_grn_request_detail fgrnd on fgrnd.id = fgrnda.final_grn_request_detail_id 
		where	fgrndl.grn_detail_id = @p_id
		and		fgrndl.grn_po_detail_id = @p_po_detail_object_id

		if isnull(@id_grn_request_detail,0) = 0
		begin
			select	@id_grn_request_detail = fgrnd.id
			from	dbo.final_grn_request_detail_karoseri_lookup fgrndl 
					inner join dbo.final_grn_request_detail_karoseri fgrnda on fgrnda.final_grn_request_detail_karoseri_id = fgrndl.id
					inner join dbo.final_grn_request_detail fgrnd on fgrnd.id = fgrnda.final_grn_request_detail_id
			where	fgrndl.grn_detail_id = @p_id
			and		fgrndl.grn_po_detail_id = @p_po_detail_object_id
		end
	END


	if  exists(
					select grn_id, status 
					from (
							select	grn_detail_id_asset 'grn_id' ,  inv.status
							from	dbo.final_grn_request_detail fgrnd
									left join dbo.ap_invoice_registration_detail invd on invd.grn_detail_id = grn_detail_id_asset
									left join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
							where	fgrnd.id = @id_grn_request_detail
							and		fgrnd.grn_po_detail_id = @p_po_detail_object_id
							and		isnull(grn_detail_id_asset,0) <> 0

							union

							select	fgrndl.grn_detail_id 'grn_id',  inv.status
							from	dbo.final_grn_request_detail_accesories_lookup fgrndl
									inner join dbo.final_grn_request_detail_accesories fgrnda on fgrnda.final_grn_request_detail_accesories_id = fgrndl.id
									inner join dbo.final_grn_request_detail fgrnd on fgrnd.id = fgrnda.final_grn_request_detail_id 
									left join dbo.ap_invoice_registration_detail invd on invd.grn_detail_id = fgrndl.grn_detail_id
									left join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
							where	fgrnd.id = @id_grn_request_detail
							and		fgrnda.grn_po_detail_id = @p_po_detail_object_id
							and		isnull(fgrndl.grn_detail_id,0) <> 0

							union
							select	fgrndl.grn_detail_id 'grn_id', inv.status
							from	dbo.final_grn_request_detail_karoseri_lookup fgrndl 
									inner join dbo.final_grn_request_detail_karoseri fgrnda on fgrnda.final_grn_request_detail_karoseri_id = fgrndl.id
									inner join dbo.final_grn_request_detail fgrnd on fgrnd.id = fgrnda.final_grn_request_detail_id
									left join dbo.ap_invoice_registration_detail invd on invd.grn_detail_id = fgrndl.grn_detail_id
									left join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
							where	fgrnd.id = @id_grn_request_detail
							and		fgrnda.grn_po_detail_id = @p_po_detail_object_id
							and		isnull(fgrndl.grn_detail_id,0) <> 0
					) a
					where isnull(a.status,'') = 'approve')
	begin
		    select	@return_amount = isnull(invd.purchase_amount,0) - isnull(invd.discount,0) 
			from	dbo.ap_invoice_registration_detail invd
					inner join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
					inner join dbo.ap_invoice_registration_detail_faktur invdf on invdf.invoice_registration_detail_id = invd.id
			where	invd.grn_detail_id = @p_id
			and		inv.status in ('POST','APPROVE')
			and		invdf.purchase_order_detail_object_info_id = @p_po_detail_object_id

			--if isnull(@return_amount,0) = 0
			--begin
			--	select	@return_amount = (price_amount - grnd.discount_amount) 
			--	from	dbo.good_receipt_note_detail grnd
			--			inner join ifinbam.dbo.master_item mi on mi.code = grnd.item_code
			--	where	id = @p_id
			--	and		mi.item_group_code not in ('MOBLS', 'EXPS')--<> 'MOBLS'
			--	and		grnd.invoice_detail_id is not null	
			--end
	end

	set @return_amount = isnull(@return_amount,0)
	return @return_amount
end
