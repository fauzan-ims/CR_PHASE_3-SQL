CREATE PROCEDURE dbo.xsp_asset_lookup_for_maintenance
(
	@p_keywords		 nvarchar(50)
	,@p_pagenumber	 int
	,@p_rowspage	 int
	,@p_order_by	 int
	,@p_sort_by		 nvarchar(5)
	,@p_company_code nvarchar(50)
	,@p_branch_code	 nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;	

	select	@rows_count = count(1)
	from	dbo.asset					ass
			left join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
	where	NOT exists
			(
				select	1
				from	dbo.disposal_detail		dd
						inner join dbo.disposal ds on (ds.code = dd.disposal_code)
				where	ds.status in
				(
					'HOLD', 'ON PROCESS'
				)
				and ass.code = dd.asset_code
			)
			--and not exists
			--(
			--	select	1
			--	from	dbo.maintenance mnt
			--	where	status in
			--	(
			--		'HOLD', 'ON PROCESS'
			--	)
			--	and ass.code = mnt.asset_code
			--)
			and not exists
			(
				select	asset_code
				from	dbo.sale_detail		sd
						inner join dbo.sale sl on (sl.code = sd.sale_code)
				where	sl.status in
				(
					'HOLD', 'ON PROCESS'
				)
				and ass.code = sd.asset_code
			)
			and not exists
			(
				select	1
				from	dbo.adjustment adj
				where	status in
				(
					'HOLD', 'ON PROCESS'
				)
				and ass.code = adj.asset_code
			)
			and ass.status		 = 'STOCK'--) OR (ass.CODE IN ('4120035565','4120035568'))
			and		ass.branch_code		  = case @p_branch_code
										when 'ALL' then ass.branch_code
										else @p_branch_code
									end
			and
			(
				ass.code			like '%' + @p_keywords + '%'
				or	ass.item_name	like '%' + @p_keywords + '%'
			) ;

	select		ass.code
				,ass.branch_code
				,ass.branch_name
				,ass.item_name
				,ass.division_code
				,ass.division_name
				,ass.department_code
				,ass.department_name
				,ass.category_code
				,ass.category_name
				,ass.type_code
				,avh.plat_no
				,@rows_count 'rowcount'
	from		dbo.asset					ass
				left join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
	where		NOT exists
			(
				select	1
				from	dbo.disposal_detail		dd
						inner join dbo.disposal ds on (ds.code = dd.disposal_code)
				where	ds.status in
				(
					'HOLD', 'ON PROCESS'
				)
				and ass.code = dd.asset_code
			)
			--and not exists
			--(
			--	select	1
			--	from	dbo.maintenance mnt
			--	where	status in
			--	(
			--		'HOLD', 'ON PROCESS'
			--	)
			--	and ass.code = mnt.asset_code
			--)
			and not exists
			(
				select	asset_code
				from	dbo.sale_detail		sd
						inner join dbo.sale sl on (sl.code = sd.sale_code)
				where	sl.status in
				(
					'HOLD', 'ON PROCESS'
				)
				and ass.code = sd.asset_code
			)
			and not exists
			(
				select	1
				from	dbo.adjustment adj
				where	status in
				(
					'HOLD', 'ON PROCESS'
				)
				and ass.code = adj.asset_code
			)
			and ass.status		 = 'STOCK'--) OR (ass.CODE IN ('4120035565','4120035568'))
			and		ass.branch_code		  = case @p_branch_code
										when 'ALL' then ass.branch_code
										else @p_branch_code
									end
			and
			(
				ass.code			like '%' + @p_keywords + '%'
				or	ass.item_name	like '%' + @p_keywords + '%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ass.code
													 when 2 then ass.item_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then ass.code
													   when 2 then ass.item_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
