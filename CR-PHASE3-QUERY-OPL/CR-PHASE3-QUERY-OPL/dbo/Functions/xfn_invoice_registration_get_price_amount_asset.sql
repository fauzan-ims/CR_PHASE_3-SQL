
-- User Defined Function

CREATE FUNCTION [dbo].[xfn_invoice_registration_get_price_amount_asset]
(
	@p_id	bigint
)returns decimal(18, 2)
as
begin
	--jika asset sudah di invoice post lebih dulu dari accecories/karoseri (berlaku jika sudah final grn)

		declare @grnd_id				bigint
				,@grn_id_asset_acc		nvarchar(50)
				,@return_amount			decimal(18,2)
				,@price_amount			decimal(18, 2)
				,@grn_id_asset_kar		nvarchar(50)

		select	@grnd_id = grn_detail_id
		from	dbo.ap_invoice_registration_detail
		where	id = @p_id

		select	@grn_id_asset_acc = grnd.grn_code_asset
		from	dbo.final_grn_request_detail grnd
				inner join dbo.final_grn_request_detail_accesories grndc on grnd.id = grndc.final_grn_request_detail_id
				inner join dbo.final_grn_request_detail_accesories_lookup grndal on grndal.id = grndc.final_grn_request_detail_accesories_id
		where	grndal.grn_detail_id = @grnd_id


		select	@grn_id_asset_kar = grnd.grn_code_asset
		from	dbo.final_grn_request_detail grnd
				inner join dbo.final_grn_request_detail_karoseri grndc on grnd.id = grndc.final_grn_request_detail_id
				inner join dbo.final_grn_request_detail_karoseri_lookup grndal on grndal.id = grndc.final_grn_request_detail_karoseri_id
		where	grndal.grn_detail_id = @grnd_id

		---- cek jika grn detail asset?
		if isnull(@grn_id_asset_acc,'') <> '' OR ISNULL(@grn_id_asset_kar,'') <> ''
		begin
		    select	@price_amount = purchase_amount - discount
			from	dbo.ap_invoice_registration_detail
			where	(grn_detail_id = @grn_id_asset_acc) or (grn_detail_id = @grn_id_asset_kar)
		end

	set @return_amount = isnull(@price_amount,0)
	return @return_amount
end
