CREATE PROCEDURE [dbo].[xsp_stock_on_customer_not_active_sell_on_process_getrows]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
)
AS
BEGIN
	DECLARE @rows_count INT = 0 ;

	IF EXISTS
	(
		SELECT	1
		FROM	sys_global_param
		WHERE	code	  = 'HO'
				AND value = @p_branch_code
	)
	BEGIN
		SET @p_branch_code = 'ALL' ;
	END ;

	SELECT	@rows_count = COUNT(1)
	FROM	dbo.ASSET ast
			INNER JOIN	dbo.ASSET_VEHICLE			av	ON av.ASSET_CODE	= ast.CODE
			INNER JOIN	IFINOPL.dbo.AGREEMENT_ASSET	ass	ON ass.ASSET_NO		= ast.ASSET_NO
			INNER JOIN	dbo.SALE_DETAIL				sd	ON sd.ASSET_CODE	= ast.CODE
			INNER JOIN dbo.SALE						sl	ON sl.CODE			= sd.SALE_CODE
			INNER JOIN IFINOPL.dbo.AGREEMENT_ASSET	aa	ON aa.ASSET_NO		= ast.ASSET_NO
			OUTER APPLY (
				SELECT MAX(due_date) AS max_due_date
				FROM IFINOPL.dbo.AGREEMENT_ASSET_AMORTIZATION aaa
				WHERE aaa.ASSET_NO = ast.ASSET_NO
			) amort
	WHERE		ast.BRANCH_CODE = CASE @p_branch_code
										WHEN 'ALL' THEN ast.BRANCH_CODE
										ELSE @p_branch_code
									END
	AND	 (ast.CODE IN (SELECT sd.ASSET_CODE FROM dbo.SALE sl INNER JOIN dbo.SALE_DETAIL sd ON sd.SALE_CODE = sl.CODE
									--WHERE sl.STATUS = 'ON PROCESS' OR sl.STATUS = 'APPROVE') OR ass.MATURITY_DATE<dbo.xfn_get_system_date())
									WHERE sl.STATUS in ('ON PROCESS', 'APPROVE') AND sd.SALE_DETAIL_STATUS IN ('HOLD','ON PROCESS') ) OR (ass.MATURITY_DATE<dbo.xfn_get_system_date()))
	AND			ast.status			= 'STOCK'
	AND			ast.fisical_status	= 'ON CUSTOMER'
	--AND			(ast.rental_status	= '' OR ast.rental_status	= NULL)
	----AND			ast.MONITORING_STATUS	= 'SELL ON PROCESS'
	--AND			ass.asset_status	= 'TERMINATE'
	AND		(
				ast.code									LIKE '%' + @p_keywords + '%'
				OR ast.branch_code							LIKE '%' + @p_keywords + '%'
				OR ast.branch_name							LIKE '%' + @p_keywords + '%'
				OR ast.item_name							LIKE '%' + @p_keywords + '%'
				OR av.built_year							LIKE '%' + @p_keywords + '%'
				OR av.plat_no								LIKE '%' + @p_keywords + '%'
				OR av.engine_no								LIKE '%' + @p_keywords + '%'
				OR av.chassis_no							LIKE '%' + @p_keywords + '%'
				OR ast.agreement_no							LIKE '%' + @p_keywords + '%'
				OR ast.client_name							LIKE '%' + @p_keywords + '%'
				OR CONVERT(VARCHAR(30), sl.sale_date, 103)	LIKE '%' + @p_keywords + '%'
				OR ast.CLIENT_NAME            	            LIKE '%' + @p_keywords + '%'
				OR ast.agreement_external_no                LIKE '%' + @p_keywords + '%'
				OR ast.unit_province_name                   LIKE '%' + @p_keywords + '%'
				OR ast.unit_city_name                       LIKE '%' + @p_keywords + '%'
				OR ast.parking_location                     LIKE '%' + @p_keywords + '%'
				OR convert(varchar(30), CASE
					WHEN aa.first_payment_TYPE = 'adv' AND aa.BILLING_TYPE = 'MNT' THEN DATEADD(MONTH, 1, amort.max_due_date)
					WHEN aa.first_payment_TYPE = 'adv' AND aa.BILLING_TYPE = 'QRT' THEN DATEADD(MONTH, 3, amort.max_due_date)
					WHEN aa.first_payment_TYPE = 'adv' AND aa.BILLING_TYPE = 'ANN' THEN DATEADD(MONTH, 12, amort.max_due_date)
					WHEN aa.first_payment_TYPE = 'adv' AND aa.BILLING_TYPE = 'SMA' THEN DATEADD(MONTH, 6, amort.max_due_date)
					ELSE amort.max_due_date
				END, 103)									LIKE '%' + @p_keywords + '%'
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
				,ast.client_name
				,convert(varchar(30), sl.sale_date, 103) AS sell_request_date
				,convert(varchar(30), CASE
					WHEN aa.first_payment_TYPE = 'adv' AND aa.BILLING_TYPE = 'MNT' THEN DATEADD(MONTH, 1, amort.max_due_date)
					WHEN aa.first_payment_TYPE = 'adv' AND aa.BILLING_TYPE = 'QRT' THEN DATEADD(MONTH, 3, amort.max_due_date)
					WHEN aa.first_payment_TYPE = 'adv' AND aa.BILLING_TYPE = 'ANN' THEN DATEADD(MONTH, 12, amort.max_due_date)
					WHEN aa.first_payment_TYPE = 'adv' AND aa.BILLING_TYPE = 'SMA' THEN DATEADD(MONTH, 6, amort.max_due_date)
					ELSE amort.max_due_date
				END, 103) AS end_contract_date
				,ast.parking_location
				,ast.unit_province_name
				,ast.unit_city_name
				,@rows_count 'rowcount'
	from	dbo.ASSET ast
			INNER JOIN	dbo.ASSET_VEHICLE			av	ON av.ASSET_CODE	= ast.CODE
			INNER JOIN	IFINOPL.dbo.AGREEMENT_ASSET	ass	ON ass.ASSET_NO		= ast.ASSET_NO
			INNER JOIN	dbo.SALE_DETAIL				sd	ON sd.ASSET_CODE	= ast.CODE
			INNER JOIN dbo.SALE						sl	ON sl.CODE			= sd.SALE_CODE
			inner JOIN IFINOPL.dbo.AGREEMENT_ASSET	aa	ON aa.ASSET_NO		= ast.ASSET_NO
			OUTER APPLY (
				SELECT MAX(due_date) AS max_due_date
				FROM IFINOPL.dbo.AGREEMENT_ASSET_AMORTIZATION aaa
				WHERE aaa.ASSET_NO = ast.ASSET_NO
			) amort
	where		ast.BRANCH_CODE = case @p_branch_code
										when 'ALL' then ast.BRANCH_CODE
										else @p_branch_code
									END
	AND	 (ast.CODE IN (SELECT sd.ASSET_CODE FROM dbo.SALE sl INNER JOIN dbo.SALE_DETAIL sd ON sd.SALE_CODE = sl.CODE
									--WHERE sl.STATUS = 'ON PROCESS' OR sl.STATUS = 'APPROVE') OR (ass.MATURITY_DATE<dbo.xfn_get_system_date()))
									WHERE sl.STATUS in ('ON PROCESS', 'APPROVE')  AND sd.SALE_DETAIL_STATUS IN ('HOLD','ON PROCESS')) OR (ass.MATURITY_DATE<dbo.xfn_get_system_date()))
	AND			ast.status			= 'STOCK'
	AND			ast.fisical_status	= 'ON CUSTOMER'
	--AND			(ast.rental_status	= '' OR ast.rental_status	= NULL)
	----AND			ast.MONITORING_STATUS	= 'SELL ON PROCESS'
	--AND			ass.asset_status	= 'TERMINATE'
	AND		(
				ast.code									like '%' + @p_keywords + '%'
				or ast.branch_code							like '%' + @p_keywords + '%'
				or ast.branch_name							like '%' + @p_keywords + '%'
				or ast.item_name							like '%' + @p_keywords + '%'
				or av.built_year							like '%' + @p_keywords + '%'
				or av.plat_no								like '%' + @p_keywords + '%'
				or av.engine_no								like '%' + @p_keywords + '%'
				or av.chassis_no							like '%' + @p_keywords + '%'
				or ast.agreement_no							like '%' + @p_keywords + '%'
				or ast.client_name							like '%' + @p_keywords + '%'
				or convert(varchar(30), sl.sale_date, 103)	like '%' + @p_keywords + '%'
				OR ast.CLIENT_NAME            	            LIKE '%' + @p_keywords + '%'
				OR ast.agreement_external_no                LIKE '%' + @p_keywords + '%'
				OR ast.unit_province_name                   LIKE '%' + @p_keywords + '%'
				OR ast.unit_city_name                       LIKE '%' + @p_keywords + '%'
				OR ast.parking_location                     LIKE '%' + @p_keywords + '%'
				OR convert(varchar(30), CASE
					WHEN aa.first_payment_TYPE = 'adv' AND aa.BILLING_TYPE = 'MNT' THEN DATEADD(MONTH, 1, amort.max_due_date)
					WHEN aa.first_payment_TYPE = 'adv' AND aa.BILLING_TYPE = 'QRT' THEN DATEADD(MONTH, 3, amort.max_due_date)
					WHEN aa.first_payment_TYPE = 'adv' AND aa.BILLING_TYPE = 'ANN' THEN DATEADD(MONTH, 12, amort.max_due_date)
					WHEN aa.first_payment_TYPE = 'adv' AND aa.BILLING_TYPE = 'SMA' THEN DATEADD(MONTH, 6, amort.max_due_date)
					ELSE amort.max_due_date
				END, 103)									LIKE '%' + @p_keywords + '%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then ast.code
													when 2 then ast.item_name
													when 3 then av.plat_no
													when 4 then ast.agreement_external_no
													when 5 then cast(
														case
															when aa.first_payment_type = 'adv' and aa.billing_type = 'mnt' then dateadd(month, 1, amort.max_due_date)
															when aa.first_payment_type = 'adv' and aa.billing_type = 'qrt' then dateadd(month, 3, amort.max_due_date)
															when aa.first_payment_type = 'adv' and aa.billing_type = 'ann' then dateadd(month, 12, amort.max_due_date)
															when aa.first_payment_type = 'adv' and aa.billing_type = 'sma' then dateadd(month, 6, amort.max_due_date)
															else amort.max_due_date
														end as sql_variant
													)
													when 6 then cast(sl.sale_date as sql_variant)
													when 7 then ast.unit_province_name

												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then ast.code
													when 2 then ast.item_name
													when 3 then av.plat_no
													when 4 then ast.agreement_external_no
													when 5 then cast(
														case
															when aa.first_payment_type = 'adv' and aa.billing_type = 'mnt' then dateadd(month, 1, amort.max_due_date)
															when aa.first_payment_type = 'adv' and aa.billing_type = 'qrt' then dateadd(month, 3, amort.max_due_date)
															when aa.first_payment_type = 'adv' and aa.billing_type = 'ann' then dateadd(month, 12, amort.max_due_date)
															when aa.first_payment_type = 'adv' and aa.billing_type = 'sma' then dateadd(month, 6, amort.max_due_date)
															else amort.max_due_date
														end as sql_variant
													)
													when 6 then cast(sl.sale_date as sql_variant)
													when 7 then ast.unit_province_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
