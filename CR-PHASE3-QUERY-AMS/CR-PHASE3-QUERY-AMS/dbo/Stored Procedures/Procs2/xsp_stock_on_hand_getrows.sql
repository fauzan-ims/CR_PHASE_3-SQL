CREATE PROCEDURE [dbo].[xsp_stock_on_hand_getrows]
(
	@p_keywords			NVARCHAR(50)
	,@p_pagenumber		INT
	,@p_rowspage		INT
	,@p_order_by		INT
	,@p_sort_by			NVARCHAR(5)
	,@p_branch_code		NVARCHAR(50)
)
AS
BEGIN
	DECLARE @rows_count INT = 0 ;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
				and value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;

	select	@rows_count = count(1)
	from	dbo.ASSET ast
			INNER JOIN	dbo.ASSET_VEHICLE av			ON av.ASSET_CODE	= ast.CODE
	where		ast.BRANCH_CODE = case @p_branch_code
										when 'ALL' then ast.BRANCH_CODE
										else @p_branch_code
									END
	--AND			(
	--				ast.CODE IN (SELECT podoi.ASSET_CODE
	--							FROM IFINPROC.dbo.PURCHASE_ORDER_DETAIL_OBJECT_INFO podoi
	--							INNER JOIN IFINPROC.dbo.GOOD_RECEIPT_NOTE_DETAIL  grnd ON grnd.id = podoi.GOOD_RECEIPT_NOTE_DETAIL_ID
	--							INNER JOIN IFINPROC.dbo.FINAL_GOOD_RECEIPT_NOTE_DETAIL fgrnd ON fgrnd.GOOD_RECEIPT_NOTE_DETAIL_ID = podoi.GOOD_RECEIPT_NOTE_DETAIL_ID
	--							INNER JOIN IFINPROC.dbo.FINAL_GOOD_RECEIPT_NOTE fgrn ON fgrn.CODE = fgrnd.FINAL_GOOD_RECEIPT_NOTE_CODE
	--							WHERE fgrn.STATUS = 'POST' AND ast.ASSET_FROM = 'BUY')
	--			)
	AND			ast.STATUS			= 'STOCK'
	AND			ast.FISICAL_STATUS	= 'ON HAND'
	AND			(ast.RENTAL_STATUS	= '' OR ast.RENTAL_STATUS IS NULL)
	--AND			(ast.MONITORING_STATUS	= '' OR ast.MONITORING_STATUS IS NULL)
	AND		(
				ast.code										LIKE '%' + @p_keywords + '%'
				OR ast.BRANCH_CODE								LIKE '%' + @p_keywords + '%'
				OR ast.BRANCH_NAME								LIKE '%' + @p_keywords + '%'
				OR ast.item_name								LIKE '%' + @p_keywords + '%'
				OR av.BUILT_YEAR								LIKE '%' + @p_keywords + '%'
				OR av.plat_no									LIKE '%' + @p_keywords + '%'	
				OR av.ENGINE_NO									LIKE '%' + @p_keywords + '%'
				OR av.CHASSIS_NO								LIKE '%' + @p_keywords + '%'
				OR CONVERT(VARCHAR(30), ast.purchase_date, 103)	LIKE '%' + @p_keywords + '%'
				OR CONVERT(VARCHAR(30), ast.POSTING_DATE, 103)	LIKE '%' + @p_keywords + '%'
				OR ast.unit_city_name							LIKE '%' + @p_keywords + '%'
				OR ast.parking_location							LIKE '%' + @p_keywords + '%'
				OR ast.status_condition							like '%' + @p_keywords + '%'
				or ast.status_progress							like '%' + @p_keywords + '%'
				or ast.status_remark							like '%' + @p_keywords + '%'
				or ast.status_last_update_by					like '%' + @p_keywords + '%'
			) ;

	SELECT		ast.code		
				,ast.branch_code
				,ast.branch_name
				,ast.item_name
				,av.built_year
				,av.plat_no
				,av.engine_no
				,av.chassis_no
				,ast.agreement_no
				,ast.agreement_external_no
				,convert(varchar(30), ast.purchase_date, 103)	AS purchase_date
				,convert(varchar(30), ast.posting_date, 103)	AS posting_date
				,ast.unit_province_name
				,ast.unit_city_name
				,ast.parking_location
				,ast.status_condition
				,ast.status_progress
				,ast.status_remark
				,ast.status_last_update_by	'last_update_by'
				,@rows_count 'rowcount'
	FROM	dbo.ASSET ast
			INNER JOIN	dbo.ASSET_VEHICLE av			ON av.ASSET_CODE	= ast.CODE
	WHERE		ast.BRANCH_CODE = CASE @p_branch_code
										WHEN 'ALL' THEN ast.BRANCH_CODE
										ELSE @p_branch_code
									END
	--AND			(
	--				ast.CODE IN (SELECT podoi.ASSET_CODE
	--							FROM IFINPROC.dbo.PURCHASE_ORDER_DETAIL_OBJECT_INFO podoi
	--							INNER JOIN IFINPROC.dbo.GOOD_RECEIPT_NOTE_DETAIL  grnd ON grnd.id = podoi.GOOD_RECEIPT_NOTE_DETAIL_ID
	--							INNER JOIN IFINPROC.dbo.FINAL_GOOD_RECEIPT_NOTE_DETAIL fgrnd ON fgrnd.GOOD_RECEIPT_NOTE_DETAIL_ID = podoi.GOOD_RECEIPT_NOTE_DETAIL_ID
	--							INNER JOIN IFINPROC.dbo.FINAL_GOOD_RECEIPT_NOTE fgrn ON fgrn.CODE = fgrnd.FINAL_GOOD_RECEIPT_NOTE_CODE
	--							WHERE fgrn.STATUS = 'POST' AND ast.ASSET_FROM = 'BUY')
	--			)
	AND			ast.STATUS			= 'STOCK'
	AND			ast.FISICAL_STATUS	= 'ON HAND'
	AND			(ast.RENTAL_STATUS	= '' OR ast.RENTAL_STATUS IS NULL)
	--AND			(ast.MONITORING_STATUS	= '' OR ast.MONITORING_STATUS IS NULL)
	AND		(
				ast.code										LIKE '%' + @p_keywords + '%'
				OR ast.BRANCH_CODE								LIKE '%' + @p_keywords + '%'
				OR ast.BRANCH_NAME								LIKE '%' + @p_keywords + '%'
				OR ast.item_name								LIKE '%' + @p_keywords + '%'
				OR av.BUILT_YEAR								like '%' + @p_keywords + '%'
				or av.plat_no									like '%' + @p_keywords + '%'	
				OR av.ENGINE_NO									LIKE '%' + @p_keywords + '%'
				OR av.CHASSIS_NO								like '%' + @p_keywords + '%'
				or convert(varchar(30), ast.purchase_date, 103)	like '%' + @p_keywords + '%'
				OR convert(varchar(30), ast.POSTING_DATE, 103)	like '%' + @p_keywords + '%'
				or ast.unit_city_name							like '%' + @p_keywords + '%'
				or ast.parking_location							like '%' + @p_keywords + '%'
				or ast.status_condition							like '%' + @p_keywords + '%'
				or ast.status_progress							like '%' + @p_keywords + '%'
				or ast.status_remark							like '%' + @p_keywords + '%'
				or ast.status_last_update_by					like '%' + @p_keywords + '%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ast.code
													 when 2 then ast.item_name
													 when 3 then av.plat_no
													 when 4 then cast(ast.purchase_date as sql_variant)
													 when 5 then ast.unit_city_name
													 when 6 then ast.status_condition
													 when 7 then ast.status_progress
													 when 8 then ast.status_remark
													 when 9 then ast.status_last_update_by
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then ast.code
													 when 2 then ast.item_name
													 when 3 then av.plat_no
													 when 4 then cast(ast.purchase_date as sql_variant)
													 when 5 then ast.unit_city_name
													 when 6 then ast.status_condition
													 when 7 then ast.status_progress
													 when 8 then ast.status_remark
													 when 9 then ast.status_last_update_by
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
