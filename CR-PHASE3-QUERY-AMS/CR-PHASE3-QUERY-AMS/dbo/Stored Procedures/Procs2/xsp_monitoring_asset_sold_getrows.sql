CREATE procedure dbo.xsp_monitoring_asset_sold_getrows
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
		where	code	  = 'ho'
				and value = @p_branch_code
	)
	begin
		set @p_branch_code = 'all' ;
	end ;

	select	@rows_count = count(1)
	from	dbo.asset	ast
			inner join	dbo.asset_vehicle	av	on av.asset_code	= ast.code
			inner join dbo.sale_detail sd on sd.asset_code = ast.code and sd.is_sold = '1' and sd.sale_detail_status in ('post','paid')
			inner join dbo.sale sl on sl.code = sd.sale_code and sl.sell_type <> 'claim'
	where	ast.branch_code = case @p_branch_code
										when 'all' then ast.branch_code
										else @p_branch_code
									end
	and			ast.status					= 'sold'
	and			ast.fisical_status			= 'sold'
	and		(
				ast.code									like '%' + @p_keywords + '%'
				or ast.branch_code							like '%' + @p_keywords + '%'
				or ast.branch_name							like '%' + @p_keywords + '%'
				or ast.item_name							like '%' + @p_keywords + '%'
				or av.built_year							like '%' + @p_keywords + '%'
				or av.plat_no								like '%' + @p_keywords + '%'	
				or av.engine_no								like '%' + @p_keywords + '%'
				or av.chassis_no							like '%' + @p_keywords + '%'
				or convert(varchar(30),	sd.sale_date, 103)	like '%' + @p_keywords + '%'
				or sl.sell_type								like '%' + @p_keywords + '%'
				or sl.description							like '%' + @p_keywords + '%'
				or ast.unit_province_name				    like '%' + @p_keywords + '%'
				or ast.unit_city_name				        like '%' + @p_keywords + '%'
				or ast.parking_location				        like '%' + @p_keywords + '%'
			) ;

	select		ast.code		
				,ast.branch_code
				,ast.branch_name
				,ast.item_name
				,av.built_year
				,av.plat_no
				,av.engine_no
				,av.chassis_no
				,convert(varchar(30), sd.sale_date, 103) as sold_date
				,sl.sell_type
				,sl.description
				,ast.parking_location
				,ast.unit_province_name
				,ast.unit_city_name
				,@rows_count 'rowcount'
	from	dbo.asset	ast
			inner join	dbo.asset_vehicle	av	on av.asset_code	= ast.code
			inner join dbo.sale_detail sd on sd.asset_code = ast.code and sd.is_sold = '1' and sd.sale_detail_status in ('post','paid')
			inner join dbo.sale sl on sl.code = sd.sale_code and sl.sell_type <> 'claim'
	where	ast.branch_code = case @p_branch_code
										when 'all' then ast.branch_code
										else @p_branch_code
									end
	and			ast.status					= 'sold'
	and			ast.fisical_status			= 'sold'
	and		(
				ast.code									like '%' + @p_keywords + '%'
				or ast.branch_code							like '%' + @p_keywords + '%'
				or ast.branch_name							like '%' + @p_keywords + '%'
				or ast.item_name							like '%' + @p_keywords + '%'
				or av.built_year							like '%' + @p_keywords + '%'
				or av.plat_no								like '%' + @p_keywords + '%'	
				or av.engine_no								like '%' + @p_keywords + '%'
				or av.chassis_no							like '%' + @p_keywords + '%'
				or convert(varchar(30),	sd.sale_date, 103)	like '%' + @p_keywords + '%'
				or sl.sell_type								like '%' + @p_keywords + '%'
				or sl.description							like '%' + @p_keywords + '%'
				or ast.unit_province_name				    like '%' + @p_keywords + '%'
				or ast.unit_city_name				        like '%' + @p_keywords + '%'
				or ast.parking_location				        like '%' + @p_keywords + '%'
			)
	order by	
	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ast.code
													 when 2 then ast.item_name
													 when 3 then av.plat_no
													 when 4 then cast(sd.sale_date as sql_variant)
													 when 5 then sl.sell_type
													 when 6 then sl.description
													 when 7 then isnull(ast.unit_province_name, '')
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then ast.code
													 when 2 then ast.item_name
													 when 3 then av.plat_no
													 when 4 then cast(sd.sale_date as sql_variant)
													 when 5 then sl.sell_type
													 when 6 then sl.description
													 when 7 then isnull(ast.unit_province_name, '')
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
