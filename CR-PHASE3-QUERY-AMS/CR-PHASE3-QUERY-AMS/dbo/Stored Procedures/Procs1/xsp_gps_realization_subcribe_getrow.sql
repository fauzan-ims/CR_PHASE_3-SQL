CREATE PROCEDURE [dbo].[xsp_gps_realization_subcribe_getrow]	
(
	@p_code nvarchar(50)
)
as
begin
	select		ast.code
				,ast.item_name
				,av.plat_no
				,av.engine_no
				,av.chassis_no
				,ast.agreement_external_no
				,ags.vendor_name
				,ast.gps_status
				,ags.subcribe_amount_month
				,convert(nvarchar(30), ags.due_date, 103) 'paid_date'
				,convert(nvarchar(30), ags.periode, 103) 'payment_date'
				,convert(nvarchar(30), agast.handover_bast_date, 103) 'from_period'
				,convert(nvarchar(30), agast.maturity_date, 103) 'to_period'
				,ags.subcribe_amount_month
	from	dbo.GPS_REALIZATION_SUBCRIBE grs
			LEFT JOIN dbo.ASSET						ast	ON ast.CODE = grs.FA_CODE
			left JOIN dbo.ASSET_VEHICLE				av	ON av.ASSET_CODE = ast.CODE
			left JOIN dbo.ASSET_GPS_SCHEDULE 		ags	ON ags.FA_CODE = ast.CODE
			left JOIN IFINOPL.dbo.AGREEMENT_ASSET	agast ON agast.ASSET_NO = ast.ASSET_NO
	where	grs.REALIZATION_NO = @p_code ;
end ;
