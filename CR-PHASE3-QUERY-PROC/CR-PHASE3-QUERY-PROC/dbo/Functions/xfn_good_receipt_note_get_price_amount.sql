CREATE FUNCTION [dbo].[xfn_good_receipt_note_get_price_amount]
(
	@p_id	int
    ,@p_po_detail_object_id	bigint = 0

)returns decimal(18, 2)
as
begin

	declare @return_amount				decimal(18,2)
			,@price_amount				decimal(18, 2)


			,@id_grn_request_detail		bigint
			,@po_id_unit				bigint
			,@unit_sudah_jadi_asset		nvarchar(1)
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

	if (isnull(@all_invoice_paid,'0') = '0')
	begin
		select	@return_amount = isnull(invd.purchase_amount,0) - isnull(invd.discount,0) 
		from	dbo.ap_invoice_registration_detail invd
				inner join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
				inner join dbo.ap_invoice_registration_detail_faktur invdf on invdf.invoice_registration_detail_id = invd.id
		where	invd.grn_detail_id = @p_id
		and		invdf.purchase_order_detail_object_info_id = @p_po_detail_object_id
		and		isnull(inv.status,'') in ('POST','APPROVE')

		if (isnull(@return_amount,0) = 0)
		begin

			select	@return_amount = (price_amount - grnd.discount_amount) 
			from	dbo.good_receipt_note_detail grnd
					inner join ifinbam.dbo.master_item mi on mi.code = grnd.item_code
			where	id = @p_id
		end

	end

	--select	@id_grn_request_detail = id
	--		,@po_id_unit = grn_po_detail_id
	--from	dbo.final_grn_request_detail
	--where	grn_detail_id_asset = @p_id
	--and		grn_po_detail_id = @p_po_detail_object_id

	--if isnull(@id_grn_request_detail,0) = 0
	--begin
	--	select	@id_grn_request_detail = fgrnd.id
	--			,@po_id_unit = fgrnd.grn_po_detail_id
	--	from	dbo.final_grn_request_detail_accesories_lookup fgrndl
	--			inner join dbo.final_grn_request_detail_accesories fgrnda on fgrnda.final_grn_request_detail_accesories_id = fgrndl.id
	--			inner join dbo.final_grn_request_detail fgrnd on fgrnd.id = fgrnda.final_grn_request_detail_id 
	--	where	fgrndl.grn_detail_id = @p_id
	--	and		fgrndl.grn_po_detail_id = @p_po_detail_object_id

	--	if isnull(@id_grn_request_detail,0) = 0
	--	begin
	--		select	@id_grn_request_detail = fgrnd.id
	--				,@po_id_unit = fgrnd.grn_po_detail_id
	--		from	dbo.final_grn_request_detail_karoseri_lookup fgrndl 
	--				inner join dbo.final_grn_request_detail_karoseri fgrnda on fgrnda.final_grn_request_detail_karoseri_id = fgrndl.id
	--				inner join dbo.final_grn_request_detail fgrnd on fgrnd.id = fgrnda.final_grn_request_detail_id
	--		where	fgrndl.grn_detail_id = @p_id
	--		and		fgrndl.grn_po_detail_id = @p_po_detail_object_id
	--	end
	--end

	---- jika merupakan po unit dan invoice sudah bayar, maka invoice unit gk di hitung aoip lagi
	--begin
	--	select	@unit_sudah_jadi_asset = count(1)
	--	from	dbo.final_grn_request_detail fgrnd
	--			left join dbo.ap_invoice_registration_detail invd on invd.grn_detail_id = grn_detail_id_asset
	--			left join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
	--			left join dbo.ap_invoice_registration_detail_faktur invdf on invdf.invoice_registration_detail_id = invd.id and invdf.purchase_order_detail_object_info_id = fgrnd.grn_po_detail_id
	--	where	fgrnd.id = @id_grn_request_detail
	--	and		fgrnd.grn_po_detail_id = @po_id_unit
	--	and		isnull(grn_detail_id_asset,0) <> 0
	--	and		inv.status in ('POST','APPROVE') 
	--	--and	fgrnd.status = 'POST'
	--end

	--if (isnull(@unit_sudah_jadi_asset,0) = 0)
	--begin
	--	-- jika final sudah di post, maka ambil dari nilai invoice
	--	select	@return_amount = isnull(invd.purchase_amount,0) - isnull(invd.discount,0) 
	--	from	dbo.ap_invoice_registration_detail invd
	--			inner join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
	--			inner join dbo.ap_invoice_registration_detail_faktur invdf on invdf.invoice_registration_detail_id = invd.id
	--	where	invd.grn_detail_id = @p_id
	--	and		invdf.purchase_order_detail_object_info_id = @p_po_detail_object_id
	--	and		inv.status in ('POST','APPROVE')

	--	-- jika invoice belum di bayar, maka ambil dari grn
	--	if isnull(@return_amount,0) = 0
	--	begin
	--		select	@return_amount = (price_amount - grnd.discount_amount) 
	--		from	dbo.good_receipt_note_detail grnd
	--				inner join ifinbam.dbo.master_item mi on mi.code = grnd.item_code
	--		where	id = @p_id
	--		and		mi.item_group_code not in ('MOBLS', 'EXPS')--<> 'MOBLS'
	--	end
 --   end
	--else
	--begin

	--	if  exists(-- CEK JIKA ADA YANG BELUM DI BAYAR, MAKA MASUK KE AOIP
	--				select grn_id, inv_status, fgrn_status
	--				from (
	--						select	fgrndl.grn_detail_id 'grn_id', inv.status 'inv_status', fgrnd.status 'fgrn_status'
	--						from	dbo.final_grn_request_detail_accesories_lookup fgrndl
	--								inner join dbo.final_grn_request_detail_accesories fgrnda on fgrnda.final_grn_request_detail_accesories_id = fgrndl.id
	--								inner join dbo.final_grn_request_detail fgrnd on fgrnd.id = fgrnda.final_grn_request_detail_id 
	--								left join dbo.ap_invoice_registration_detail invd on invd.grn_detail_id = fgrndl.grn_detail_id
	--								left join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
	--								left join dbo.ap_invoice_registration_detail_faktur invdf on invdf.invoice_registration_detail_id = invd.id and invdf.purchase_order_detail_object_info_id = fgrndl.grn_po_detail_id
	--						where	fgrnd.id = @id_grn_request_detail
	--						and		fgrnda.grn_po_detail_id = @p_po_detail_object_id
	--						and		isnull(fgrndl.grn_detail_id,0) <> 0

	--						union
	--						select	fgrndl.grn_detail_id 'grn_id', inv.status 'inv_status', fgrnd.status 'fgrn_status'
	--						from	dbo.final_grn_request_detail_karoseri_lookup fgrndl 
	--								inner join dbo.final_grn_request_detail_karoseri fgrnda on fgrnda.final_grn_request_detail_karoseri_id = fgrndl.id
	--								inner join dbo.final_grn_request_detail fgrnd on fgrnd.id = fgrnda.final_grn_request_detail_id
	--								left join dbo.ap_invoice_registration_detail invd on invd.grn_detail_id = fgrndl.grn_detail_id
	--								left join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
	--								left join dbo.ap_invoice_registration_detail_faktur invdf on invdf.invoice_registration_detail_id = invd.id and invdf.purchase_order_detail_object_info_id = fgrndl.grn_po_detail_id
	--						where	fgrnd.id = @id_grn_request_detail
	--						and		fgrnda.grn_po_detail_id = @p_po_detail_object_id
	--						and		isnull(fgrndl.grn_detail_id,0) <> 0
	--				) a
	--				where isnull(a.inv_status,'') not in ('POST','APPROVE'))
	--	begin

	--			-- jika final sudah di post, maka ambil dari nilai invoice
	--			select	@return_amount = isnull(invd.purchase_amount,0) - isnull(invd.discount,0) 
	--			from	dbo.ap_invoice_registration_detail invd
	--					inner join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
	--					inner join dbo.ap_invoice_registration_detail_faktur invdf on invdf.invoice_registration_detail_id = invd.id
	--			where	invd.grn_detail_id = @p_id
	--			and		invdf.purchase_order_detail_object_info_id = @p_po_detail_object_id
	--			and		inv.status in ('POST','APPROVE')

	--			-- jika invoice belum di bayar, maka ambil dari grn
	--			if isnull(@return_amount,0) = 0
	--			begin
	--				select	@return_amount = (price_amount - grnd.discount_amount) 
	--				from	dbo.good_receipt_note_detail grnd
	--						inner join ifinbam.dbo.master_item mi on mi.code = grnd.item_code
	--				where	id = @p_id
	--				and		mi.item_group_code not in ('MOBLS', 'EXPS')--<> 'MOBLS'
	--			end
	--	end
	----end
	--end

	set @return_amount = isnull(@return_amount,0)

	return @return_amount

	--	select	@return_amount = (price_amount - grnd.discount_amount) --* receive_quantity
	--	from	dbo.good_receipt_note_detail grnd
	--			inner join ifinbam.dbo.master_item mi on mi.code = grnd.item_code
	--	where	id = @p_id
	--	--and mi.item_group_code <> 'mobls'
	--	--30/06/2025: ambil yng belum di bayar
	--	and		not EXISTS (	select invd.grn_detail_id from dbo.ap_invoice_registration_detail invd
	--								inner join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
	--								where inv.status in ('POST','APPROVE')
	--								AND		grn_detail_id =  grnd.id)

	--	if isnull(@return_amount,0) = 0
	--	begin
	--		select	@return_amount = (price_amount - grnd.discount_amount) 
	--		from	dbo.good_receipt_note_detail grnd
	--				inner join ifinbam.dbo.master_item mi on mi.code = grnd.item_code
	--		where	id = @p_id
	--		and		mi.item_group_code not in ('MOBLS', 'EXPS')--<> 'MOBLS'
	--	end							

	--SET @return_amount = isnull(@return_amount,0)

	--return @return_amount
end
