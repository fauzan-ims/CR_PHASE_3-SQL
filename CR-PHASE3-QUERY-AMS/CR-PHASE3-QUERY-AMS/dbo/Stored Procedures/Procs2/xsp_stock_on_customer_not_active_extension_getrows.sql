CREATE PROCEDURE [dbo].[xsp_stock_on_customer_not_active_extension_getrows]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
)
as
begin
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

	select	@rows_count = count(1)
	FROM	dbo.ASSET ast
			INNER JOIN	dbo.ASSET_VEHICLE av			ON av.ASSET_CODE	= ast.CODE
			INNER JOIN	IFINOPL.dbo.AGREEMENT_ASSET aa	ON aa.ASSET_NO		= ast.ASSET_NO
			--INNER JOIN	dbo.MAINTENANCE mnt				ON mnt.ASSET_CODE	= ast.CODE
			INNER JOIN  IFINOPL.dbo.AGREEMENT_MAIN  am	ON am.AGREEMENT_NO = aa.AGREEMENT_NO
			inner join ifinopl.dbo.maturity ma on ma.agreement_no = aa.agreement_no AND ma.STATUS = 'ON PROCESS'
			OUTER APPLY (
				SELECT MAX(due_date) AS max_due_date
				FROM IFINOPL.dbo.AGREEMENT_ASSET_AMORTIZATION aaa
				WHERE aaa.ASSET_NO = ast.ASSET_NO
			) amort
	where		ast.BRANCH_CODE = case @p_branch_code
										when 'ALL' then ast.BRANCH_CODE
										else @p_branch_code
									END
	AND			(
					ast.CODE IN (SELECT aa.FA_CODE 
								FROM IFINOPL.dbo.MATURITY ma 
								INNER JOIN IFINOPL.dbo.AGREEMENT_ASSET aa ON aa.AGREEMENT_NO = ma.AGREEMENT_NO 
								INNER JOIN IFINOPL.dbo.MATURITY_DETAIL mtd ON mtd.MATURITY_CODE = ma.CODE
								WHERE ma.STATUS = 'ON PROCESS' AND mtd.RESULT='CONTINUE')
				)
	AND			ast.STATUS				= 'STOCK'
	AND			ast.FISICAL_STATUS		= 'ON CUSTOMER'
	AND			ast.RENTAL_STATUS		= 'IN USE'
	--AND			ast.MONITORING_STATUS		= 'EXTEND PRCS'
	--AND			(ast.PROCESS_STATUS		= 'EXTENSION' OR ast.PROCESS_STATUS		= 'RENEWAL ON PROCESS')
	--AND			aa.ASSET_STATUS			= 'TERMINATE'
	and		(
				ast.code																			like '%' + @p_keywords + '%'
				or ast.branch_code																	like '%' + @p_keywords + '%'
				or ast.branch_name																	like '%' + @p_keywords + '%'
				or ast.item_name																	like '%' + @p_keywords + '%'
				or av.built_year																	like '%' + @p_keywords + '%'
				or av.plat_no																		like '%' + @p_keywords + '%'
				or av.engine_no																		like '%' + @p_keywords + '%'
				or av.chassis_no																	like '%' + @p_keywords + '%'
				or am.agreement_external_no															like '%' + @p_keywords + '%'
				or ast.client_name																	like '%' + @p_keywords + '%'
				or case when aa.is_purchase_requirement_after_lease = '1' then 'Yes' else 'No' end  LIKE '%' + @p_keywords + '%'
				or ast.parking_location																LIKE '%' + @p_keywords + '%'
				or ast.unit_province_name															LIKE '%' + @p_keywords + '%'
				or ast.unit_city_name																LIKE '%' + @p_keywords + '%'
				or CONVERT(varchar(30), ast.mod_date, 103)											LIKE '%' + @p_keywords + '%'
				or CONVERT(varchar(30), ma.date, 103)												LIKE '%' + @p_keywords + '%'
				--or mnt.spk_no																		like '%' + @p_keywords + '%'
			)

	SELECT		ast.code		
				,ast.branch_code
				,ast.branch_name
				,ast.item_name
				,av.built_year 'item_year'
				,av.plat_no
				,av.engine_no
				,av.chassis_no
				,ast.agreement_no
				,ast.agreement_external_no
				,ast.client_name
				,aa.is_purchase_requirement_after_lease 'PRAL'
				--,mnt.spk_no
				,am.marketing_name
				,ast.parking_location
				,ast.unit_province_name
				,ast.unit_city_name
				--,CONVERT(varchar(30), ast.mod_date, 103)	'extension_date'
				,CONVERT(varchar(30), ma.date, 103)	'extension_date'
				,@rows_count 'rowcount'
	FROM	dbo.ASSET ast
			INNER JOIN	dbo.ASSET_VEHICLE av			ON av.ASSET_CODE	= ast.CODE
			INNER JOIN	IFINOPL.dbo.AGREEMENT_ASSET aa	ON aa.ASSET_NO		= ast.ASSET_NO
			--INNER JOIN	dbo.MAINTENANCE mnt				ON mnt.ASSET_CODE	= ast.CODE
			INNER JOIN  IFINOPL.dbo.AGREEMENT_MAIN  am	ON am.AGREEMENT_NO	= aa.AGREEMENT_NO
			inner join ifinopl.dbo.maturity ma on ma.agreement_no = aa.agreement_no AND ma.STATUS = 'ON PROCESS'
	where		ast.BRANCH_CODE = case @p_branch_code
										when 'ALL' then ast.BRANCH_CODE
										else @p_branch_code
									END
	AND			(
					ast.CODE IN (SELECT aa.FA_CODE 
								FROM IFINOPL.dbo.MATURITY ma 
								INNER JOIN IFINOPL.dbo.AGREEMENT_ASSET aa ON aa.AGREEMENT_NO = ma.AGREEMENT_NO 
								INNER JOIN IFINOPL.dbo.MATURITY_DETAIL mtd ON mtd.MATURITY_CODE = ma.CODE
								WHERE ma.STATUS = 'ON PROCESS' AND mtd.RESULT='CONTINUE')
				)
	AND			ast.STATUS				= 'STOCK'
	AND			ast.FISICAL_STATUS		= 'ON CUSTOMER'
	AND			ast.RENTAL_STATUS		= 'IN USE'
	--AND			ast.MONITORING_STATUS		= 'EXTEND PRCS'
	--AND			(ast.PROCESS_STATUS		= 'EXTENSION' OR ast.PROCESS_STATUS		= 'RENEWAL ON PROCESS')
	--AND			aa.ASSET_STATUS			= 'TERMINATE'
	and		(
				ast.code																			like '%' + @p_keywords + '%'
				or ast.branch_code																	like '%' + @p_keywords + '%'
				or ast.branch_name																	like '%' + @p_keywords + '%'
				or ast.item_name																	like '%' + @p_keywords + '%'
				or av.built_year																	like '%' + @p_keywords + '%'
				or av.plat_no																		like '%' + @p_keywords + '%'
				or av.engine_no																		like '%' + @p_keywords + '%'
				or av.chassis_no																	like '%' + @p_keywords + '%'
				or am.agreement_external_no															like '%' + @p_keywords + '%'
				or ast.client_name																	like '%' + @p_keywords + '%'
				or case when aa.is_purchase_requirement_after_lease = '1' then 'Yes' else 'No' end  LIKE '%' + @p_keywords + '%'
				or ast.parking_location																LIKE '%' + @p_keywords + '%'
				or ast.unit_province_name															LIKE '%' + @p_keywords + '%'
				or ast.unit_city_name																LIKE '%' + @p_keywords + '%'
				or CONVERT(varchar(30), ast.mod_date, 103)											LIKE '%' + @p_keywords + '%'
				or CONVERT(varchar(30), ma.date, 103)												LIKE '%' + @p_keywords + '%'
				--or mnt.spk_no																		like '%' + @p_keywords + '%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ast.code
													 when 2 then ast.item_name
													 when 3 then av.plat_no
													 when 4 then aa.agreement_no
													 when 5 then aa.is_purchase_requirement_after_lease
													 when 6 then cast(ma.date as sql_variant)
													 when 7 then ast.unit_province_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then ast.code
													 when 2 then ast.item_name
													 when 3 then av.plat_no
													 when 4 then aa.agreement_no
													 when 5 then aa.is_purchase_requirement_after_lease
													 when 6 then cast(ma.date as sql_variant)
													 when 7 then ast.unit_province_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
