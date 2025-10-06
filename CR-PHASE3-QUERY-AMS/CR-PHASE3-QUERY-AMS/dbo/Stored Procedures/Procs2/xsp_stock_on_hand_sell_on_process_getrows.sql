CREATE PROCEDURE dbo.xsp_stock_on_hand_sell_on_process_getrows
(
	@p_keywords			NVARCHAR(50)
	,@p_pagenumber		INT
	,@p_rowspage		INT
	,@p_order_by		INT
	,@p_sort_by			NVARCHAR(5)
	,@p_branch_code		NVARCHAR(50)
)
as
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
	from	dbo.asset	ast
			inner join	dbo.asset_vehicle	av		on av.asset_code	= ast.code
			INNER JOIN	dbo.SALE_DETAIL		sd		ON sd.ASSET_CODE	= ast.CODE
			inner join	dbo.sale			sl		on sl.CODE			= sd.SALE_CODE
	where		ast.branch_code = case @p_branch_code
										when 'all' then ast.branch_code
										else @p_branch_code
									END
	AND			ast.status					= 'STOCK'
	AND			ast.fisical_status			= 'ON HAND'
	AND			ast.rental_status			= ''
		and			sale_detail_status			IN ('ON PROCESS','HOLD')
	AND		(
				ast.code									like '%' + @p_keywords + '%'
				or ast.branch_code							like '%' + @p_keywords + '%'
				or ast.branch_name							like '%' + @p_keywords + '%'
				or ast.item_name							like '%' + @p_keywords + '%'
				or av.built_year							like '%' + @p_keywords + '%'
				or av.plat_no								like '%' + @p_keywords + '%'
				or av.engine_no								like '%' + @p_keywords + '%'
				or av.chassis_no							like '%' + @p_keywords + '%'
				or ast.last_km_service						like '%' + @p_keywords + '%'
				or convert(varchar(30), sl.sale_date, 103)	like '%' + @p_keywords + '%'
				or sl.sell_type								like '%' + @p_keywords + '%'
				or sl.description							like '%' + @p_keywords + '%'
				or ast.unit_province_name					like '%' + @p_keywords + '%'
				or ast.unit_city_name						like '%' + @p_keywords + '%'
				or ast.parking_location					    like '%' + @p_keywords + '%'
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
				,convert(varchar(30), sl.sale_date, 103) 'sell_request_date'
				,sl.sell_type
				,sl.description
				,ast.unit_province_name
				,ast.unit_city_name
				,ast.parking_location
				,@rows_count 'rowcount'
	from	dbo.asset	ast
			inner join	dbo.asset_vehicle	av		on av.asset_code	= ast.code
			inner join	dbo.sale_detail		sd		on sd.asset_code	= ast.code
			inner join	dbo.sale			sl		on sl.code			= sd.sale_code
	where		ast.branch_code = case @p_branch_code
										when 'all' then ast.branch_code
										else @p_branch_code
									END
	AND			ast.status					= 'STOCK'
	AND			ast.fisical_status			= 'ON HAND'
	AND			ast.rental_status			= ''
	and			sale_detail_status			IN ('ON PROCESS','HOLD')
	AND		(
				ast.code									like '%' + @p_keywords + '%'
				or ast.branch_code							like '%' + @p_keywords + '%'
				or ast.branch_name							like '%' + @p_keywords + '%'
				or ast.item_name							like '%' + @p_keywords + '%'
				or av.built_year							like '%' + @p_keywords + '%'
				or av.plat_no								like '%' + @p_keywords + '%'
				or av.engine_no								like '%' + @p_keywords + '%'
				or av.chassis_no							like '%' + @p_keywords + '%'
				or ast.last_km_service						like '%' + @p_keywords + '%'
				or convert(varchar(30), sl.sale_date, 103)	like '%' + @p_keywords + '%'
				or sl.sell_type								like '%' + @p_keywords + '%'
				or sl.description							like '%' + @p_keywords + '%'
				or ast.unit_province_name					like '%' + @p_keywords + '%'
				or ast.unit_city_name						like '%' + @p_keywords + '%'
				or ast.parking_location					    like '%' + @p_keywords + '%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ast.code
													 when 2 then ast.item_name
													 when 3 then av.plat_no
													 when 4 then cast(sl.sale_date as sql_variant)
													 when 5 then sl.sell_type
													 when 6 then sl.description
													 when 7 then ast.unit_province_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then ast.code
													 when 2 then ast.item_name
													 when 3 then av.plat_no
													 when 4 then cast(sl.sale_date as sql_variant)
													 when 5 then sl.sell_type
													 when 6 then sl.description
													 when 7 then ast.unit_province_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
