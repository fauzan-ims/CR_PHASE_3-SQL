CREATE PROCEDURE [dbo].[xsp_realization_subcription_gps_getrow]	
(
	@p_code nvarchar(50)
)
as
BEGIN
	SELECT		grs.realization_no
				,grs.payment_date
				,grs.status
				,ast.code
				,ast.item_name
				,av.plat_no
				,av.engine_no
				,av.chassis_no
				,ast.agreement_external_no
				,grs.vendor_name
				,ast.gps_status
				,ags.subcribe_amount_month
				,convert(nvarchar(30), ags.due_date, 103) 'paid_date'
				,convert(nvarchar(30), ags.periode, 103) 'payment_date'
				,agast.handover_bast_date 'from_period'
				,agast.maturity_date 'to_period'
				,ags.subcribe_amount_month
				,grs.bank_name
				,grs.bank_account_no
				,grs.bank_account_name
				,grs.realization_date
				,grs.invoice_no
				,grs.invoice_date
				,grs.faktur_no
				,grs.faktur_date
				,grs.tax_code
				,grs.tax_name
				,grs.billing_amount
				,grs.billing_amount
				,grs.ppn_amount
				,grs.pph_amount
				,grs.invoice_amount
				,grs.invoice_file_name
				,grs.voucher
	from	dbo.GPS_REALIZATION_SUBCRIBE grs
			LEFT JOIN dbo.ASSET						ast	ON ast.CODE = grs.FA_CODE
			left JOIN dbo.ASSET_VEHICLE				av	ON av.ASSET_CODE = grs.FA_CODE
			left JOIN dbo.ASSET_GPS_SCHEDULE 		ags	ON ags.FA_CODE = grs.FA_CODE
			left JOIN IFINOPL.dbo.AGREEMENT_ASSET	agast ON agast.ASSET_NO = grs.FA_CODE
	where	grs.REALIZATION_NO = @p_code ;
end ;
