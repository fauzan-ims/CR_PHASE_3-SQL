CREATE PROCEDURE [dbo].[xsp_gps_realization_subscribe_getrows]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_status			nvarchar(20)
)
as
begin
	declare @rows_count int = 0 ;

	SELECT	@rows_count = COUNT(1)
	FROM	dbo.GPS_REALIZATION_SUBCRIBE grs
	LEFT JOIN dbo.ASSET						ast	ON ast.CODE			= grs.FA_CODE
	LEFT JOIN dbo.ASSET_VEHICLE				av	ON av.ASSET_CODE	= ast.CODE
	outer apply (
					select top 1 *
					from dbo.ASSET_GPS_SCHEDULE ags
					where ags.FA_CODE = ast.CODE
					order by ags.DUE_DATE asc
				) ags
	LEFT JOIN IFINOPL.dbo.AGREEMENT_ASSET	agast ON agast.ASSET_NO = ast.ASSET_NO
	WHERE	ast.status = CASE @p_status
						WHEN 'ALL' THEN ast.status
						ELSE @p_status
					END
	AND		(
				ast.code												LIKE '%' + @p_keywords + '%'
				OR grs.realization_no									LIKE '%' + @p_keywords + '%'
				OR grs.payment_date										LIKE '%' + @p_keywords + '%'
				OR ast.code												LIKE '%' + @p_keywords + '%'
				OR ast.item_name										LIKE '%' + @p_keywords + '%'
				OR av.plat_no											LIKE '%' + @p_keywords + '%'
				OR av.engine_no											LIKE '%' + @p_keywords + '%'
				OR av.chassis_no										LIKE '%' + @p_keywords + '%'
				OR ast.agreement_external_no							LIKE '%' + @p_keywords + '%'
				OR CONVERT(NVARCHAR(30), agast.handover_bast_date, 103)	LIKE '%' + @p_keywords + '%'
				OR CONVERT(NVARCHAR(30), agast.maturity_date, 103) 		LIKE '%' + @p_keywords + '%'
				OR ags.vendor_name										LIKE '%' + @p_keywords + '%'
				OR ast.gps_status										LIKE '%' + @p_keywords + '%'
				OR ast.invoice_no										LIKE '%' + @p_keywords + '%'
				OR grs.remarks											LIKE '%' + @p_keywords + '%'
				or ags.subcribe_amount_month 							LIKE '%' + @p_keywords + '%'
				or grs.status											LIKE '%' + @p_keywords + '%'
			) ;

	select		grs.realization_no
				,grs.payment_date
				,ast.code
				,ast.item_name
				,av.plat_no
				,av.engine_no
				,av.chassis_no
				,ast.agreement_external_no
				,CONVERT(NVARCHAR(30), agast.handover_bast_date, 103) 'from_period'
				,CONVERT(NVARCHAR(30), agast.maturity_date, 103) 'to_period'
				,ags.vendor_name
				,ast.gps_status
				,ast.invoice_no
				,grs.remarks
				,ags.subcribe_amount_month 'invoice_amount'
				,grs.status
				,@rows_count 'rowcount'
	FROM	dbo.GPS_REALIZATION_SUBCRIBE grs
	LEFT JOIN dbo.ASSET						ast	ON ast.CODE			= grs.FA_CODE
	LEFT JOIN dbo.ASSET_VEHICLE				av	ON av.ASSET_CODE	= ast.CODE
	outer apply (
					select top 1 *
					from dbo.ASSET_GPS_SCHEDULE ags
					where ags.FA_CODE = ast.CODE
					order by ags.DUE_DATE asc
				) ags
	LEFT JOIN IFINOPL.dbo.AGREEMENT_ASSET	agast ON agast.ASSET_NO = ast.ASSET_NO
	WHERE	ast.status = CASE @p_status
						WHEN 'ALL' THEN ast.status
						ELSE @p_status
					END
	AND		(
					ast.code												LIKE '%' + @p_keywords + '%'
					OR grs.realization_no									LIKE '%' + @p_keywords + '%'
					OR grs.payment_date										LIKE '%' + @p_keywords + '%'
					OR ast.code												LIKE '%' + @p_keywords + '%'
					OR ast.item_name										LIKE '%' + @p_keywords + '%'
					OR av.plat_no											LIKE '%' + @p_keywords + '%'
					OR av.engine_no											LIKE '%' + @p_keywords + '%'
					OR av.chassis_no										LIKE '%' + @p_keywords + '%'
					OR ast.agreement_external_no							LIKE '%' + @p_keywords + '%'
					OR CONVERT(NVARCHAR(30), agast.handover_bast_date, 103)	LIKE '%' + @p_keywords + '%'
					OR CONVERT(NVARCHAR(30), agast.maturity_date, 103) 		LIKE '%' + @p_keywords + '%'
					OR ags.vendor_name										LIKE '%' + @p_keywords + '%'
					OR ast.gps_status										LIKE '%' + @p_keywords + '%'
					OR ast.invoice_no										LIKE '%' + @p_keywords + '%'
					OR grs.remarks											LIKE '%' + @p_keywords + '%'
					OR ags.subcribe_amount_month 							LIKE '%' + @p_keywords + '%'
					OR grs.status											LIKE '%' + @p_keywords + '%'
				)	
	ORDER BY	CASE
					WHEN @p_sort_by = 'asc' THEN CASE @p_order_by
													 when 1 then grs.realization_no
													 when 2 then cast(grs.payment_date as sql_variant)
													 when 3 then ast.item_name
													 when 4 then av.plat_no + av.chassis_no + av.engine_no
													 when 5 then ast.agreement_external_no
													 when 6 then ags.vendor_name
													 when 7 then ast.invoice_no
													 when 8 then grs.remarks
													 when 9 then invoice_amount
													 when 10 then grs.status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then grs.realization_no
													 when 2 then cast(grs.payment_date as sql_variant)
													 when 3 then ast.item_name
													 when 4 then av.plat_no + av.chassis_no + av.engine_no
													 when 5 then ast.agreement_external_no
													 when 6 then ags.vendor_name
													 when 7 then ast.invoice_no
													 when 8 then grs.remarks
													 when 9 then invoice_amount
													 when 10 then grs.status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
