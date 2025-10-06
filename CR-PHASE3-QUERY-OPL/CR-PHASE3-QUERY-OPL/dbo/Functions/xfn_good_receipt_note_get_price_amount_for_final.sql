
-- User Defined Function

CREATE FUNCTION [dbo].[xfn_good_receipt_note_get_price_amount_for_final]
(
	@p_id	int
    ,@p_po_detail_object_id	bigint
)returns decimal(18, 2)
as
begin

	declare @return_amount				decimal(18,2)
			,@id_grn_request_detail		bigint
			,@all_invoice_paid			nvarchar(1)='0'
			,@final_grn_code			nvarchar(50)


	select @final_grn_code = final_good_receipt_note_code from dbo.final_good_receipt_note_detail where good_receipt_note_detail_id = @p_id and po_object_id = @p_po_detail_object_id

	if not exists (	select	1
					from	dbo.final_good_receipt_note_detail fgrnd
							left join dbo.ap_invoice_registration_detail invd on invd.grn_detail_id = fgrnd.good_receipt_note_detail_id
							left join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
					where	fgrnd.final_good_receipt_note_code = @final_grn_code
					and		isnull(inv.status,'') not in ('APPROVE','POST')
					)
	begin
		set @all_invoice_paid = '1'
	end

	if (isnull(@all_invoice_paid,'0') = '1')
	begin
		select	@return_amount = isnull(invd.purchase_amount,0) - isnull(invd.discount,0) 
		from	dbo.ap_invoice_registration_detail invd
				inner join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
				inner join dbo.ap_invoice_registration_detail_faktur invdf on invdf.invoice_registration_detail_id = invd.id
		where	invd.grn_detail_id = @p_id
		and		invdf.purchase_order_detail_object_info_id = @p_po_detail_object_id
		and		isnull(inv.status,'') in ('POST','APPROVE')
	end

	-- jika sudah terbayar maka ambil dari invoice
	--begin
	--	select	@return_amount = isnull(invd.purchase_amount,0) - isnull(invd.discount,0) 
	--	from	dbo.ap_invoice_registration_detail invd
	--			inner join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
	--	where	invd.grn_detail_id = @p_id
	--	and		inv.status in ('POST','APPROVE')
	--end

	--if isnull(@return_amount,0) = 0
	--begin
	--	select	@price_amount = (price_amount - grnd.discount_amount) 
	--	from	dbo.good_receipt_note_detail grnd
	--			inner join ifinbam.dbo.master_item mi on mi.code = grnd.item_code
	--	where	id = @p_id
	--	and		mi.item_group_code not in ('MOBLS', 'EXPS')--<> 'MOBLS'
	--end


	----01/07/2025: sepria
	---- cek, jika sudah dibayar semua, dicatat sebagai asset. ambil nilai dari invoice
	---- cari id dari grn request detail dulu:
	--select	@id_grn_request_detail = id
	--from	dbo.final_grn_request_detail
	--where	grn_detail_id_asset = @p_id
	--and		grn_po_detail_id = @p_po_detail_object_id


	--if isnull(@id_grn_request_detail,0) = 0
	--begin
	--    select	@id_grn_request_detail = fgrnd.id
	--	from	dbo.final_grn_request_detail_accesories_lookup fgrndl
	--			inner join dbo.final_grn_request_detail_accesories fgrnda on fgrnda.final_grn_request_detail_accesories_id = fgrndl.id
	--			inner join dbo.final_grn_request_detail fgrnd on fgrnd.id = fgrnda.final_grn_request_detail_id 
	--	where	fgrndl.grn_detail_id = @p_id
	--	and		fgrndl.grn_po_detail_id = @p_po_detail_object_id

	--	if isnull(@id_grn_request_detail,0) = 0
	--	begin
	--		select	@id_grn_request_detail = fgrnd.id
	--		from	dbo.final_grn_request_detail_karoseri_lookup fgrndl 
	--				inner join dbo.final_grn_request_detail_karoseri fgrnda on fgrnda.final_grn_request_detail_karoseri_id = fgrndl.id
	--				inner join dbo.final_grn_request_detail fgrnd on fgrnd.id = fgrnda.final_grn_request_detail_id
	--		where	fgrndl.grn_detail_id = @p_id
	--		and		fgrndl.grn_po_detail_id = @p_po_detail_object_id
	--	end
	--end

	----cek dulu dalam kombinasi ini, untuk grn unit sudah di bayar atau belum, hanya di akui asset jika grn unit sudah di bayar
	--if exists (	select 1 from dbo.final_grn_request_detail frgna
	--			inner join dbo.purchase_order_detail_object_info podoi on podoi.id = frgna.grn_po_detail_id
	--			where frgna.id = @id_grn_request_detail
	--			and podoi.invoice_id is not null
	--			)
	--begin
	--    select	@return_amount = isnull(invd.purchase_amount,0) - isnull(invd.discount,0) 
	--	from	dbo.ap_invoice_registration_detail invd
	--			inner join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
	--			inner join dbo.ap_invoice_registration_detail_faktur invdf on invdf.invoice_registration_detail_id = invd.id
	--	where	invd.grn_detail_id = @p_id
	--	and		invdf.purchase_order_detail_object_info_id = @p_po_detail_object_id
	--	and		inv.status in ('POST','APPROVE')
	--end


	--IF not exists(
	--				select grn_id, status 
	--				from (
	--						select	grn_detail_id_asset 'grn_id' ,  inv.status
	--						from	dbo.final_grn_request_detail fgrnd
	--								left join dbo.ap_invoice_registration_detail invd on invd.grn_detail_id = grn_detail_id_asset
	--								left join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
	--						where	fgrnd.id = @id_grn_request_detail
	--						and		isnull(grn_detail_id_asset,0) <> 0
	--						and		fgrnd.grn_po_detail_id = @p_po_detail_object_id
	--						and		fgrnd.id in (select grnda.id from dbo.final_grn_request_detail fgrna 
	--												inner join dbo.good_receipt_note_detail grnda on grnda.id = fgrna.grn_detail_id_asset
	--												where grnda.invoice_detail_id is not null
	--											)

	--						union
	--						select	fgrndl.grn_detail_id 'grn_id',  inv.status
	--						from	dbo.final_grn_request_detail_accesories_lookup fgrndl
	--								inner join dbo.final_grn_request_detail_accesories fgrnda on fgrnda.final_grn_request_detail_accesories_id = fgrndl.id
	--								inner join dbo.final_grn_request_detail fgrnd on fgrnd.id = fgrnda.final_grn_request_detail_id 
	--								left join dbo.ap_invoice_registration_detail invd on invd.grn_detail_id = fgrndl.grn_detail_id
	--								left join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
	--						where	fgrnd.id = @id_grn_request_detail
	--						and		isnull(fgrndl.grn_detail_id,0) <> 0
	--						and		fgrndl.grn_po_detail_id = @p_po_detail_object_id
	--						and		fgrnd.id in (select grnda.id from dbo.final_grn_request_detail fgrna 
	--										inner join dbo.good_receipt_note_detail grnda on grnda.id = fgrna.grn_detail_id_asset
	--										where grnda.invoice_detail_id is not null
	--									)

	--						union
	--						select	fgrndl.grn_detail_id 'grn_id', inv.status
	--						from	dbo.final_grn_request_detail_karoseri_lookup fgrndl 
	--								inner join dbo.final_grn_request_detail_karoseri fgrnda on fgrnda.final_grn_request_detail_karoseri_id = fgrndl.id
	--								inner join dbo.final_grn_request_detail fgrnd on fgrnd.id = fgrnda.final_grn_request_detail_id
	--								left join dbo.ap_invoice_registration_detail invd on invd.grn_detail_id = fgrndl.grn_detail_id
	--								left join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
	--						where	fgrnd.id = @id_grn_request_detail
	--						and		isnull(fgrndl.grn_detail_id,0) <> 0
	--						and		fgrndl.grn_po_detail_id = @p_po_detail_object_id
	--						and		fgrnd.id in (select grnda.id from dbo.final_grn_request_detail fgrna 
	--										inner join dbo.good_receipt_note_detail grnda on grnda.id = fgrna.grn_detail_id_asset
	--										where grnda.invoice_detail_id is not null
	--									)
	--				) a
	--				where isnull(a.status,'') <> 'approve')
	--begin
	--	    select	@return_amount = isnull(invd.purchase_amount,0) - isnull(invd.discount,0) 
	--		from	dbo.ap_invoice_registration_detail invd
	--				inner join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
	--				inner join dbo.ap_invoice_registration_detail_faktur invdf on invdf.invoice_registration_detail_id = invd.id
	--		where	invd.grn_detail_id = @p_id
	--		and		inv.status in ('POST','APPROVE')
	--		and		invdf.purchase_order_detail_object_info_id = @p_po_detail_object_id

	--end

	----jika dari manual langsung pilih fa code (tidak masuk ke grn request) maka ambil nilai dari grn
	--if isnull(@id_grn_request_detail,0) = 0 and isnull( @return_amount,0 ) = 0
	--begin
	--    select	@return_amount  = isnull(grnd.price_amount,0) - isnull(grnd.discount_amount,0)
	--	from	dbo.good_receipt_note_detail grnd
	--			inner join dbo.purchase_order_detail_object_info podoi on podoi.good_receipt_note_detail_id = grnd.id
	--	where	grnd.id = @p_id
	--	and		podoi.id = @p_po_detail_object_id

	--end

	set @return_amount = isnull(@return_amount,0)
	return @return_amount
end
