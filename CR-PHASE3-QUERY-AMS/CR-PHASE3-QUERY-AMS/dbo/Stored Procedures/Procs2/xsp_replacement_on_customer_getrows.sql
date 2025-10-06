CREATE PROCEDURE [dbo].[xsp_replacement_on_customer_getrows]
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

	IF EXISTS
	(
		SELECT	1
		FROM	sys_global_param
		WHERE	code	  = 'HO'
				AND value = @p_branch_code
	)
	BEGIN
		SET @p_branch_code = 'ALL' ;
	end ;

	select	@rows_count = count(1)
	from	dbo.asset ast WITH(NOLOCK)
			inner join	dbo.asset_vehicle			av WITH(NOLOCK)	on av.asset_code	= ast.code
			outer apply(
				select max(handover_date) handover_date from dbo.handover_asset ha WITH(NOLOCK) where ha.fa_code = ast.code
			) hd		
	where		ast.branch_code = case @p_branch_code
										when 'all' then ast.branch_code
										else @p_branch_code
									END
	AND			ast.status					= 'REPLACEMENT'
	AND			ast.fisical_status			= 'ON CUSTOMER'
	AND		(
				ast.CODE										like '%' + @p_keywords + '%'
				or ast.branch_code								like '%' + @p_keywords + '%'
				or ast.branch_name								like '%' + @p_keywords + '%'
				or ast.item_name								like '%' + @p_keywords + '%'
				or av.built_year								like '%' + @p_keywords + '%'
				or av.plat_no									like '%' + @p_keywords + '%'	
				or av.engine_no									like '%' + @p_keywords + '%'
				or av.chassis_no								like '%' + @p_keywords + '%'
				OR ast.LAST_KM_SERVICE							like '%' + @p_keywords + '%'
				OR ast.AGREEMENT_EXTERNAL_NO					like '%' + @p_keywords + '%'
				OR ast.CLIENT_NAME								like '%' + @p_keywords + '%'
				OR convert(varchar(30), hd.handover_date, 103)	like '%' + @p_keywords + '%'
				OR ast.unit_province_name						like '%' + @p_keywords + '%'
				OR ast.unit_city_name						    like '%' + @p_keywords + '%'
				OR ast.parking_location						    like '%' + @p_keywords + '%'
				OR ast.status_condition						    like '%' + @p_keywords + '%'
				OR ast.status_progress						    like '%' + @p_keywords + '%'
				OR ast.status_remark						    like '%' + @p_keywords + '%'
				OR ast.status_last_update_by					like '%' + @p_keywords + '%'
			) ;

	SELECT		ast.code		
				,ast.branch_code
				,ast.branch_name
				,ast.item_name
				,av.built_year
				,av.plat_no
				,av.engine_no
				,av.chassis_no
				,ast.last_km_service
				,ast.agreement_external_no
				,ast.client_name
				,convert(varchar(30), hd.handover_date, 103) as replacement_date
				,ast.parking_location
				,ast.unit_province_name
				,ast.unit_city_name
				,ast.status_condition
				,ast.status_progress
				,ast.status_remark
				,ast.status_last_update_by	'last_update_by'
				,@rows_count 'rowcount'
	from	dbo.asset	ast WITH(NOLOCK)
			inner join	dbo.asset_vehicle			av WITH(NOLOCK)	on av.asset_code	= ast.code
			outer apply(
				select max(handover_date) handover_date from dbo.handover_asset ha WITH(NOLOCK) where ha.fa_code = ast.code
			) hd		
	where		ast.branch_code = case @p_branch_code
										when 'all' then ast.branch_code
										else @p_branch_code
									END
	AND			ast.status					= 'REPLACEMENT'
	AND			ast.fisical_status			= 'ON CUSTOMER'
	AND		(
				ast.CODE										like '%' + @p_keywords + '%'
				or ast.branch_code								like '%' + @p_keywords + '%'
				or ast.branch_name								like '%' + @p_keywords + '%'
				or ast.item_name								like '%' + @p_keywords + '%'
				or av.built_year								like '%' + @p_keywords + '%'
				or av.plat_no									like '%' + @p_keywords + '%'	
				or av.engine_no									like '%' + @p_keywords + '%'
				or av.chassis_no								like '%' + @p_keywords + '%'
				OR ast.LAST_KM_SERVICE							like '%' + @p_keywords + '%'
				OR ast.AGREEMENT_EXTERNAL_NO					like '%' + @p_keywords + '%'
				OR ast.CLIENT_NAME								like '%' + @p_keywords + '%'
				OR convert(varchar(30), hd.handover_date, 103)	like '%' + @p_keywords + '%'
				OR ast.unit_province_name						like '%' + @p_keywords + '%'
				OR ast.unit_city_name						    like '%' + @p_keywords + '%'
				OR ast.parking_location						    like '%' + @p_keywords + '%'
				OR ast.status_condition						    like '%' + @p_keywords + '%'
				OR ast.status_progress						    like '%' + @p_keywords + '%'
				OR ast.status_remark						    like '%' + @p_keywords + '%'
				OR ast.status_last_update_by					like '%' + @p_keywords + '%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ast.code
													 when 2 then ast.item_name
													 when 3 then av.plat_no
													 when 4 then ast.agreement_external_no
													 when 5 then cast(hd.handover_date as sql_variant)
													 when 6 then ast.unit_province_name
													 when 7 then ast.status_condition
													 when 8 then ast.status_progress
													 when 9 then ast.status_remark
													 when 10 then ast.status_last_update_by
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then ast.code
													 when 2 then ast.item_name
													 when 3 then av.plat_no
													 when 4 then ast.agreement_external_no
													 when 5 then cast(hd.handover_date as sql_variant)
													 when 6 then ast.unit_province_name
													 when 7 then ast.status_condition
													 when 8 then ast.status_progress
													 when 9 then ast.status_remark
													 when 10 then ast.status_last_update_by
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
