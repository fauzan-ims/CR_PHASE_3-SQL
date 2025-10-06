CREATE PROCEDURE [dbo].[xsp_opname_detail_getrows]
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_opname_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	opname_detail od
			left join dbo.asset ass on (ass.code = od.asset_code)
			left join dbo.asset_vehicle av on (av.asset_code = ass.code)
	where	opname_code = @p_opname_code
	and		(
				od.asset_code												like '%' + @p_keywords + '%'
				or	ass.item_name											like '%' + @p_keywords + '%'
				or	ass.barcode												like '%' + @p_keywords + '%'
				or	condition_code											like '%' + @p_keywords + '%'
				or	km														like '%' + @p_keywords + '%'
				or	convert(nvarchar(30), od.date, 103)      				like '%' + @p_keywords + '%'
				or	av.plat_no												like '%' + @p_keywords + '%'
				or	av.engine_no											like '%' + @p_keywords + '%'
				or	av.chassis_no											like '%' + @p_keywords + '%'
				or	od.location_name										like '%' + @p_keywords + '%'
			) ;

	select		id
				,opname_code
				,od.asset_code
				,ass.item_name
				,od.branch_code
				,od.branch_name
				,ass.barcode
				,ass.status
				,od.location_code
				,isnull(condition_code, '')		'condition_code'
				,isnull(od.location_name, '')	'location_name'
				,od.file_name
				,od.path
				,od.km
				,convert(nvarchar(30), od.date, 103)'date'
				,av.plat_no
				,av.engine_no
				,av.chassis_no
				,@rows_count 'rowcount'
	from		opname_detail od
				left join dbo.asset ass on (ass.code = od.asset_code)
				left join dbo.asset_vehicle av on (av.asset_code = ass.code)
	where		opname_code = @p_opname_code
	and			(
					od.asset_code												like '%' + @p_keywords + '%'
					or	ass.item_name											like '%' + @p_keywords + '%'
					or	ass.barcode												like '%' + @p_keywords + '%'
					or	condition_code											like '%' + @p_keywords + '%'
					or	km														like '%' + @p_keywords + '%'
					or	convert(nvarchar(30), od.date, 103)      				like '%' + @p_keywords + '%'
					or	av.plat_no												like '%' + @p_keywords + '%'
					or	av.engine_no											like '%' + @p_keywords + '%'
					or	av.chassis_no											like '%' + @p_keywords + '%'
					or	od.location_name										like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then od.asset_code
													 when 2 then av.plat_no
													 when 3 then ass.status
													 when 4 then cast(od.km as sql_variant)
													 when 5 then location_name
													 when 6 then od.file_name									
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then od.asset_code
													 when 2 then av.plat_no
													 when 3 then ass.status
													 when 4 then cast(od.km as sql_variant)
													 when 5 then location_name
													 when 6 then od.file_name				
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
