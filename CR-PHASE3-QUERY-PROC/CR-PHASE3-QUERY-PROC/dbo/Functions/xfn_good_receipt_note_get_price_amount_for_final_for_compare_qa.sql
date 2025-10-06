CREATE FUNCTION [dbo].[xfn_good_receipt_note_get_price_amount_for_final_for_compare_qa]
(
	@p_id	int
    ,@p_po_detail_object_id	bigint
)returns decimal(18, 2)
as
begin
	
	declare @return_amount			decimal(18,2)
			,@id_grn_request_detail		BIGINT

	--01/07/2025: sepria
	-- cek, jika sudah dibayar semua, dicatat sebagai asset. ambil nilai dari invoice
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
	end
    
	--cek dulu dalam kombinasi ini, untuk grn unit sudah di bayar atau belum, hanya di akui asset jika grn unit sudah di bayar
	if exists (	select 1 from dbo.final_grn_request_detail frgna
				inner join dbo.purchase_order_detail_object_info podoi on podoi.id = frgna.grn_po_detail_id
				where frgna.id = @id_grn_request_detail
				and podoi.invoice_id is not null
				)
	begin
	     select	@return_amount = isnull(invd.purchase_amount,0) - isnull(invd.discount,0) 
		from	dbo.ap_invoice_registration_detail invd
				inner join dbo.ap_invoice_registration inv on inv.code = invd.invoice_register_code
				inner join dbo.ap_invoice_registration_detail_faktur invdf on invdf.invoice_registration_detail_id = invd.id
		where	invd.grn_detail_id = @p_id
		and		invdf.purchase_order_detail_object_info_id = @p_po_detail_object_id
		and		inv.status in ('POST','APPROVE')
	end


	set @return_amount = isnull(@return_amount,0)
	return @return_amount
end
