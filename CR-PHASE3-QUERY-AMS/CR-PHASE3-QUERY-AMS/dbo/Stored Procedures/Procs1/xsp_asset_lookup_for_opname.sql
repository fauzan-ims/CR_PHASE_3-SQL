CREATE PROCEDURE dbo.xsp_asset_lookup_for_opname
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	--
	,@p_branch_code		nvarchar(50)
	,@p_company_code	nvarchar(50)
	,@p_code			nvarchar(50)
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
	from	dbo.asset ass
	left join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
	where	ass.status		 in ('STOCK', 'REPLACEMENT')
			and ass.FISICAL_STATUS = 'ON HAND'
			and	ass.branch_code		  = case @p_branch_code
											when 'ALL' then ass.branch_code
											else @p_branch_code
										end
			and ass.company_code = @p_company_code
			and ass.code not in (select asset_code from dbo.opname_detail od left join dbo.opname op on (op.code = od.opname_code) where opname_code = @p_code and op.status = 'HOLD')
			and (
					ass.code											like '%' + @p_keywords + '%'
					or	avh.plat_no										like '%' + @p_keywords + '%'
					or	ass.item_name									like '%' + @p_keywords + '%'
					or	ass.last_location_name							like '%' + @p_keywords + '%'
					or	avh.engine_no									like '%' + @p_keywords + '%'
					or	avh.chassis_no									like '%' + @p_keywords + '%'
					or	convert(nvarchar(30), ass.last_so_date, 103)	like '%' + @p_keywords + '%'
				) ;

	select		ass.code
				,ass.branch_code
				,ass.branch_name
				,ass.item_name
				,ass.barcode
				,ass.division_code
				,ass.division_name
				,ass.department_code
				,ass.department_name
				,ass.purchase_price
				,ass.total_depre_comm
				,ass.net_book_value_comm
				,ass.item_group_code
				,avh.plat_no
				,ass.last_location_code
				,ass.last_location_name
				,avh.engine_no
				,avh.chassis_no
				,convert(nvarchar(30), ass.last_so_date, 103) 'last_so_date'
				,@rows_count 'rowcount'
	from		dbo.asset ass
	left join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
	where	ass.status		 in ('STOCK', 'REPLACEMENT')
			and ass.FISICAL_STATUS = 'ON HAND'
			and	ass.branch_code		  = case @p_branch_code
											when 'ALL' then ass.branch_code
											else @p_branch_code
										end
			and ass.company_code = @p_company_code
			and ass.code not in (select asset_code from dbo.opname_detail od left join dbo.opname op on (op.code = od.opname_code) where opname_code = @p_code and op.status = 'HOLD')
			and (
						ass.code											like '%' + @p_keywords + '%'
						or	avh.plat_no										like '%' + @p_keywords + '%'
						or	ass.item_name									like '%' + @p_keywords + '%'
						or	ass.last_location_name							like '%' + @p_keywords + '%'
						or	avh.engine_no									like '%' + @p_keywords + '%'
						or	avh.chassis_no									like '%' + @p_keywords + '%'
						or	convert(nvarchar(30), ass.last_so_date, 103)	like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ass.code + ass.item_name
													 when 2 then ass.last_location_name
													 when 3 then avh.plat_no
													 when 4 then cast(ass.last_so_date as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													    when 1 then ass.code + ass.item_name
														when 2 then ass.last_location_name
														when 3 then avh.plat_no
														when 4 then cast(ass.last_so_date as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
