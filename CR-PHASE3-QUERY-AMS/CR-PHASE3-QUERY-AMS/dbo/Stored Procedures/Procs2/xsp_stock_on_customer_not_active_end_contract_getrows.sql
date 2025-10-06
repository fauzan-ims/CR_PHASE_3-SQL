CREATE PROCEDURE dbo.xsp_stock_on_customer_not_active_end_contract_getrows
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
	declare @rows_count int = 0 ;

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

	SELECT	@rows_count = COUNT(1)
	FROM	dbo.asset	ast WITH (NOLOCK)
			INNER JOIN	dbo.asset_vehicle	av WITH (NOLOCK)	ON av.asset_code	= ast.code
			INNER JOIN IFINOPL.dbo.AGREEMENT_ASSET aa WITH (NOLOCK)	ON aa.ASSET_NO		= ast.ASSET_NO
			INNER JOIN IFINOPL.dbo.AGREEMENT_MAIN am WITH (NOLOCK)	ON am.AGREEMENT_NO = aa.AGREEMENT_NO
			OUTER APPLY (
				SELECT MAX(due_date) AS max_due_date
				FROM IFINOPL.dbo.AGREEMENT_ASSET_AMORTIZATION aaa WITH (NOLOCK)
				WHERE aaa.ASSET_NO = ast.ASSET_NO
			) amort
	WHERE		ast.branch_code = CASE @p_branch_code
										WHEN 'all' THEN ast.branch_code
										ELSE @p_branch_code
									END
	--AND			
	--AND		(ast.CODE IN (SELECT hr.FA_CODE FROM dbo.HANDOVER_REQUEST hr WHERE STATUS = 'HOLD' AND TYPE='PICK UP')
	--		OR ast.CODE IN (SELECT ha.FA_CODE FROM dbo.HANDOVER_ASSET ha WHERE STATUS = 'HOLD' AND TYPE='PICK UP'))
	AND			aa.MATURITY_DATE			< dbo.xfn_get_system_date()
	AND			ast.STATUS					= 'STOCK'
	AND			ast.FISICAL_STATUS			= 'ON CUSTOMER'
	AND			ast.RENTAL_STATUS			= 'IN USE'
	--AND			(ast.MONITORING_STATUS		= '' OR ast.MONITORING_STATUS			is NULL)
	AND		(
				ast.code																			LIKE '%' + @p_keywords + '%'
				or ast.branch_code																	LIKE '%' + @p_keywords + '%'
				or ast.branch_name																	LIKE '%' + @p_keywords + '%'
				or ast.item_name																	LIKE '%' + @p_keywords + '%'
				or av.built_year																	LIKE '%' + @p_keywords + '%'
				or av.plat_no																		LIKE '%' + @p_keywords + '%'	
				or av.engine_no																		LIKE '%' + @p_keywords + '%'
				or av.chassis_no																	LIKE '%' + @p_keywords + '%'
				or ast.agreement_external_no														LIKE '%' + @p_keywords + '%'
				or ast.client_name																	LIKE '%' + @p_keywords + '%'
				or case when aa.is_purchase_requirement_after_lease = '1' then 'Yes' else 'No' end  LIKE '%' + @p_keywords + '%'
				or am.marketing_name																LIKE '%' + @p_keywords + '%'
				OR CONVERT(VARCHAR(30), 
						CASE
							WHEN aa.first_payment_type = 'adv' AND aa.billing_type = 'mnt' THEN DATEADD(MONTH, 1, amort.max_due_date)
							WHEN aa.first_payment_type = 'adv' AND aa.billing_type = 'qrt' THEN DATEADD(MONTH, 3, amort.max_due_date)
							WHEN aa.first_payment_type = 'adv' AND aa.billing_type = 'ann' THEN DATEADD(MONTH, 12, amort.max_due_date)
							WHEN aa.first_payment_type = 'adv' AND aa.billing_type = 'sma' THEN DATEADD(MONTH, 6, amort.max_due_date)
							ELSE amort.max_due_date
						END, 103
				) LIKE '%' + @p_keywords + '%'
				OR ast.parking_location							LIKE '%' + @p_keywords + '%'
				OR ast.unit_province_name						LIKE '%' + @p_keywords + '%'
				OR ast.unit_city_name						    LIKE '%' + @p_keywords + '%'



			) ;

	SELECT		ast.code		
				,ast.branch_code
				,ast.branch_name
				,ast.item_name
				,av.built_year
				,av.plat_no
				,av.engine_no
				,av.chassis_no
				,ast.agreement_external_no
				,ast.client_name
				,aa.is_purchase_requirement_after_lease 'PRAL'
				,am.marketing_name
				,ast.status_condition
				,ast.status_progress
				,ast.status_remark
				,CONVERT(VARCHAR(30), CASE
					WHEN aa.first_payment_TYPE = 'adv' AND aa.BILLING_TYPE = 'MNT' THEN DATEADD(MONTH, 1, amort.max_due_date)
					WHEN aa.first_payment_TYPE = 'adv' AND aa.BILLING_TYPE = 'QRT' THEN DATEADD(MONTH, 3, amort.max_due_date)
					WHEN aa.first_payment_TYPE = 'adv' AND aa.BILLING_TYPE = 'ANN' THEN DATEADD(MONTH, 12, amort.max_due_date)
					WHEN aa.first_payment_TYPE = 'adv' AND aa.BILLING_TYPE = 'SMA' THEN DATEADD(MONTH, 6, amort.max_due_date)
					ELSE amort.max_due_date
				END, 103) AS end_contract_date
				,convert(varchar(30),	ast.disposal_date, 103)
				,ast.parking_location
				,ast.unit_province_name
				,ast.unit_city_name
				,@rows_count 'rowcount'
	from	dbo.asset ast WITH (NOLOCK)
			inner join	dbo.asset_vehicle			av WITH (NOLOCK)	ON av.asset_code	= ast.code
			inner JOIN IFINOPL.dbo.AGREEMENT_ASSET	aa WITH (NOLOCK)	ON aa.ASSET_NO		= ast.ASSET_NO
			INNER JOIN IFINOPL.dbo.AGREEMENT_MAIN	am WITH (NOLOCK)	ON am.AGREEMENT_NO	= aa.AGREEMENT_NO
			OUTER APPLY (
				SELECT MAX(due_date) AS max_due_date
				FROM IFINOPL.dbo.AGREEMENT_ASSET_AMORTIZATION aaa WITH (NOLOCK)
				WHERE aaa.ASSET_NO = ast.ASSET_NO
			) amort
	where		ast.branch_code = case @p_branch_code
										when 'all' then ast.branch_code
										else @p_branch_code
									END
	--AND		(ast.CODE IN (SELECT hr.FA_CODE FROM dbo.HANDOVER_REQUEST hr WHERE STATUS = 'HOLD' AND TYPE='PICK UP')
	--		OR ast.CODE IN (SELECT ha.FA_CODE FROM dbo.HANDOVER_ASSET ha WHERE STATUS = 'HOLD' AND TYPE='PICK UP'))
	AND			aa.MATURITY_DATE			< dbo.xfn_get_system_date()
	AND			ast.STATUS					= 'STOCK'
	AND			ast.FISICAL_STATUS			= 'ON CUSTOMER'
	AND			ast.RENTAL_STATUS			= 'IN USE'
	--AND			(ast.MONITORING_STATUS		= '' OR ast.MONITORING_STATUS			is NULL)
	AND		(
				ast.code																			LIKE '%' + @p_keywords + '%'
				or ast.branch_code																	LIKE '%' + @p_keywords + '%'
				or ast.branch_name																	LIKE '%' + @p_keywords + '%'
				or ast.item_name																	LIKE '%' + @p_keywords + '%'
				or av.built_year																	LIKE '%' + @p_keywords + '%'
				or av.plat_no																		LIKE '%' + @p_keywords + '%'	
				or av.engine_no																		LIKE '%' + @p_keywords + '%'
				or av.chassis_no																	LIKE '%' + @p_keywords + '%'
				or ast.agreement_external_no														LIKE '%' + @p_keywords + '%'
				or ast.client_name																	LIKE '%' + @p_keywords + '%'
				or case when aa.is_purchase_requirement_after_lease = '1' then 'Yes' else 'No' end  LIKE '%' + @p_keywords + '%'
				or am.marketing_name																LIKE '%' + @p_keywords + '%'
				OR convert(varchar(30), 
						case
							when aa.first_payment_type = 'adv' and aa.billing_type = 'mnt' then dateadd(month, 1, amort.max_due_date)
							when aa.first_payment_type = 'adv' and aa.billing_type = 'qrt' then dateadd(month, 3, amort.max_due_date)
							when aa.first_payment_type = 'adv' and aa.billing_type = 'ann' then dateadd(month, 12, amort.max_due_date)
							when aa.first_payment_type = 'adv' and aa.billing_type = 'sma' then dateadd(month, 6, amort.max_due_date)
							else amort.max_due_date
						end, 103
				) like '%' + @p_keywords + '%'
				OR ast.parking_location							LIKE '%' + @p_keywords + '%'
				OR ast.unit_province_name						LIKE '%' + @p_keywords + '%'
				OR ast.unit_city_name						    LIKE '%' + @p_keywords + '%'



			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ast.code
													 when 2 then ast.item_name
													 when 3 then av.plat_no
													 when 4 then ast.agreement_external_no
													 when 5 then aa.is_purchase_requirement_after_lease
													 when 6 then am.marketing_name
													 when 7 then convert(varchar(30), isnull(
														case
															when aa.first_payment_type = 'adv' and aa.billing_type = 'mnt' then dateadd(month, 1, amort.max_due_date)
															when aa.first_payment_type = 'adv' and aa.billing_type = 'qrt' then dateadd(month, 3, amort.max_due_date)
															when aa.first_payment_type = 'adv' and aa.billing_type = 'ann' then dateadd(month, 12, amort.max_due_date)
															when aa.first_payment_type = 'adv' and aa.billing_type = 'sma' then dateadd(month, 6, amort.max_due_date)
															else amort.max_due_date
														end,
														'1900-01-01'
													), 120)
													WHEN 8 THEN parking_location
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then ast.code
													 when 2 then ast.item_name
													 when 3 then av.plat_no
													 when 4 then ast.agreement_external_no
													 when 5 then aa.is_purchase_requirement_after_lease
													 when 6 then am.marketing_name
													 when 7 then convert(varchar(30), isnull(
														case
															when aa.first_payment_type = 'adv' and aa.billing_type = 'mnt' then dateadd(month, 1, amort.max_due_date)
															when aa.first_payment_type = 'adv' and aa.billing_type = 'qrt' then dateadd(month, 3, amort.max_due_date)
															when aa.first_payment_type = 'adv' and aa.billing_type = 'ann' then dateadd(month, 12, amort.max_due_date)
															when aa.first_payment_type = 'adv' and aa.billing_type = 'sma' then dateadd(month, 6, amort.max_due_date)
															else amort.max_due_date
														end,
														'1900-01-01'
													), 120)
													WHEN 8 THEN parking_location
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
