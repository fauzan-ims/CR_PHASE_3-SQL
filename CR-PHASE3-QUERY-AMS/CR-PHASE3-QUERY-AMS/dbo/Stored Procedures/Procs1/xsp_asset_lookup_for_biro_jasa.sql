CREATE PROCEDURE dbo.xsp_asset_lookup_for_biro_jasa
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
	,@p_company_code	nvarchar(50)
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
	inner join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
	where	
	--ass.code not in
	--						(
	--							select	asset_code
	--							from	dbo.mutation_detail		md
	--									inner join dbo.mutation mt on (mt.code = md.mutation_code)
	--							where	md.status_received		= 'SENT'
	--									--or md.status_received = 'RETURNED'
	--									or	md.status_received is null
	--									or	mt.status in
	--													(
	--														'HOLD', 'ON PROCESS'
	--													)
	--										and mt.company_code = @p_company_code
	--						)
	--		and ass.code not in
	--							(
	--								select	asset_code
	--								from	dbo.disposal_detail		dd
	--										inner join dbo.disposal ds on (ds.code = dd.disposal_code)
	--								where	ds.status in
	--													(
	--														'HOLD', 'ON PROCESS'
	--													)
	--										and ds.company_code = @p_company_code
	--							)
	--		and ass.code not in
	--							(
	--								select	asset_code
	--								from	dbo.maintenance
	--								where	status in
	--												(
	--													'HOLD', 'ON PROCESS'
	--												)
	--										and company_code = @p_company_code
	--							)
	--		and ass.code not in
	--							(
	--								select	asset_code
	--								from	dbo.sale_detail		sd
	--										inner join dbo.sale sl on (sl.code = sd.sale_code)
	--								where	sl.status in
	--													(
	--														'HOLD', 'ON PROCESS'
	--													)
	--										and sl.company_code = @p_company_code
	--							)
	--		and ass.code not in
	--							(
	--								select	asset_code
	--								from	dbo.adjustment
	--								where	status in
	--												(
	--													'HOLD', 'ON PROCESS'
	--												)
	--										and company_code = @p_company_code
	--							)
	--		and ass.code not in (
	--								select fa_code 
	--								from dbo.register_main
	--								--(+) raffyanda 09/10/2023 15.41.00.00 perubahan kondisi where agar data register no yang dicancel dapat digunakan kembali assetnya  
	--								where register_status = 'CANCEL' --NOT IN ( 'DONE', 'CANCEL') 
									--where register_status <> 'DONE'
									--where register_status in ('DELIVERY', 'HOLD', 'ON PROCESS', 'ORDER', 'PAID', 'REALIZATION', 'REALIZATION PROCEED')
									--(+) raffyanda 09/10/2023 15.41.00.00 perubahan kondisi where agar data register no yang dicancel dapat digunakan kembali assetnya  
			--)
			ass.status		 in ('STOCK', 'REPLACEMENT')
			and ass.company_code = @p_company_code
			and	ass.branch_code		  = case @p_branch_code
										when 'ALL' then ass.branch_code
										else @p_branch_code
									end
			and (
					ass.code			like '%' + @p_keywords + '%'
					or	ass.item_name	like '%' + @p_keywords + '%'
					or	avh.plat_no		like '%' + @p_keywords + '%'
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
				,avh.plat_no
				,@rows_count 'rowcount'
	from		dbo.asset ass
	inner join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
	where	
	--ass.code not in
			--				(
			--					select	asset_code
			--					from	dbo.mutation_detail		md
			--							inner join dbo.mutation mt on (mt.code = md.mutation_code)
			--					where	md.status_received		= 'SENT'
			--							--or md.status_received = 'RETURNED'
			--							or	md.status_received is null
			--							or	mt.status in
			--											(
			--												'HOLD', 'ON PROCESS'
			--											)
			--								and mt.company_code = @p_company_code
			--				)
			--and ass.code not in
			--					(
			--						select	asset_code
			--						from	dbo.disposal_detail		dd
			--								inner join dbo.disposal ds on (ds.code = dd.disposal_code)
			--						where	ds.status in
			--											(
			--												'HOLD', 'ON PROCESS'
			--											)
			--								and ds.company_code = @p_company_code
			--					)
			--and ass.code not in
			--					(
			--						select	asset_code
			--						from	dbo.maintenance
			--						where	status in
			--										(
			--											'HOLD', 'ON PROCESS'
			--										)
			--								and company_code = @p_company_code
			--					)
			--and ass.code not in
			--					(
			--						select	asset_code
			--						from	dbo.sale_detail		sd
			--								inner join dbo.sale sl on (sl.code = sd.sale_code)
			--						where	sl.status in
			--											(
			--												'HOLD', 'ON PROCESS'
			--											)
			--								and sl.company_code = @p_company_code
			--					)
			--and ass.code not in
			--					(
			--						select	asset_code
			--						from	dbo.adjustment
			--						where	status in
			--										(
			--											'HOLD', 'ON PROCESS'
			--										)
			--								and company_code = @p_company_code
			--					)
			--	and ass.code not in (
			--						select fa_code 
			--						from dbo.register_main
			--						--(+) raffyanda 09/10/2023 15.41.00.00 perubahan kondisi where agar data register no yang dicancel dapat digunakan kembali assetnya  
			--						where register_status = 'CANCEL' --not IN ( 'DONE', 'CANCEL') 
			--						--where register_status <> 'DONE'
			--						--where register_status in ('DELIVERY', 'HOLD', 'ON PROCESS', 'ORDER', 'PAID', 'REALIZATION', 'REALIZATION PROCEED')
			--						--(+) raffyanda 09/10/2023 15.41.00.00 perubahan kondisi where agar data register no yang dicancel dapat digunakan kembali assetnya  
			--				)
				ass.status		 in ('STOCK', 'REPLACEMENT')
				and	ass.branch_code		  = case @p_branch_code
										when 'ALL' then ass.branch_code
										else @p_branch_code
									end
				and ass.company_code = @p_company_code
				and (
						ass.code				like '%' + @p_keywords + '%'
						or	ass.item_name		like '%' + @p_keywords + '%'
						or	avh.plat_no			like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ass.code
													 when 2 then avh.plat_no
													 when 3 then ass.item_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													    when 1 then ass.code
														when 2 then avh.plat_no
														when 3 then ass.item_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
