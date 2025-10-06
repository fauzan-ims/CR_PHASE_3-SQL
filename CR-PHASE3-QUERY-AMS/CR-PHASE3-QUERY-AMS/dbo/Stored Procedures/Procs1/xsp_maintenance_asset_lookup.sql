CREATE PROCEDURE dbo.xsp_maintenance_asset_lookup
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_company_code	nvarchar(50)
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
		set @p_branch_code = 'ALL' 
	end;

	select	@rows_count = count(1)
	from	dbo.asset ass
	inner join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
	outer apply(select agsa.is_use_maintenance from ifinopl.dbo.agreement_asset agsa where agsa.asset_no = ass.asset_no) agreement_asset
	--left join ifinopl.dbo.agreement_asset agsa on (agsa.agreement_no = ass.agreement_no)
	where	ass.code not in
							(
								select	asset_code
								from	dbo.mutation_detail		md
										inner join dbo.mutation mt on (mt.code = md.mutation_code)
								where	md.status_received		= 'SENT'
										or	md.status_received is null
										or	mt.status in
														(
															'HOLD', 'ON PROCESS'
														)
											and mt.company_code = @p_company_code
							)
			and ass.code not in
								(
									select	asset_code
									from	dbo.disposal_detail		dd
											inner join dbo.disposal ds on (ds.code = dd.disposal_code)
									where	ds.status in
														(
															'HOLD', 'ON PROCESS'
														)
											and ds.company_code = @p_company_code
								)
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
			and ass.code not in
								(
									select	asset_code
									from	dbo.sale_detail		sd
											inner join dbo.sale sl on (sl.code = sd.sale_code)
									where	sl.status in
														(
															'HOLD', 'ON PROCESS'
														)
											and sl.company_code = @p_company_code
								)
			and ass.code not in
								(
									select	asset_code
									from	dbo.adjustment
									where	status in
													(
														'HOLD', 'ON PROCESS'
													)
											and company_code = @p_company_code
								)
	and		ass.company_code = @p_company_code			
	and		ass.status in ('STOCK', 'REPLACEMENT')
--OR (ass.CODE IN
--(
--N'4120039766'
--)
--))-- Untuk exclude agar asset yang sudah ke sold bisa dibuatkan tagihan maintenance 

	and		ass.branch_code		  = case @p_branch_code
										when 'ALL' then ass.branch_code
										else @p_branch_code
									end
	and		(
				ass.code				like '%' + @p_keywords + '%'
				or	ass.item_name		like '%' + @p_keywords + '%'
				or	avh.plat_no			like '%' + @p_keywords + '%'
			) ;

	select	ass.code
			,ass.barcode
			,ass.item_code
			,ass.item_name
			,ass.branch_code
			,ass.branch_name
			,ass.barcode
			,ass.division_code
			,ass.division_name
			,ass.department_code
			,ass.department_name
			,ass.company_code
			,ass.net_book_value_comm
			,ass.net_book_value_fiscal
			,ass.original_price
			,ass.purchase_price
			,ass.category_code
			,ass.category_name
			,ass.type_code
			,avh.plat_no
			,case
					when isnull(agreement_asset.is_use_maintenance,'0') = '1' then 'MAINTENANCE' + ' - ' + ass.agreement_external_no		-- (+) Ari 2023-12-27 ket : add isnull
					when isnull(agreement_asset.is_use_maintenance,'0') = '0' then 'NON MAINTENANCE' + ' - ' + ass.agreement_external_no
					else 'STOCK IN MAINTENANCE'
				end 'is_use_maintenance'
			,@rows_count 'rowcount'
	from	dbo.asset ass
	inner join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
	outer apply(select agsa.is_use_maintenance from ifinopl.dbo.agreement_asset agsa where agsa.asset_no = ass.asset_no) agreement_asset
	--left join ifinopl.dbo.agreement_asset agsa on (agsa.agreement_no = ass.agreement_no)
	where	ass.code not in
							(
								select	asset_code
								from	dbo.mutation_detail		md
										inner join dbo.mutation mt on (mt.code = md.mutation_code)
								where	md.status_received		= 'SENT'
										or	md.status_received is null
										or	mt.status in
														(
															'HOLD', 'ON PROCESS'
														)
											and mt.company_code = @p_company_code
							)
			and ass.code not in
								(
									select	asset_code
									from	dbo.disposal_detail		dd
											inner join dbo.disposal ds on (ds.code = dd.disposal_code)
									where	ds.status in
														(
															'HOLD', 'ON PROCESS'
														)
											and ds.company_code = @p_company_code
								)
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
			and ass.code not in
								(
									select	asset_code
									from	dbo.sale_detail		sd
											inner join dbo.sale sl on (sl.code = sd.sale_code)
									where	sl.status in
														(
															'HOLD', 'ON PROCESS'
														)
											and sl.company_code = @p_company_code
								)
			and ass.code not in
								(
									select	asset_code
									from	dbo.adjustment
									where	status in
													(
														'HOLD', 'ON PROCESS'
													)
											and company_code = @p_company_code
								)
	and		ass.company_code = @p_company_code			
	and		ass.status in ('STOCK', 'REPLACEMENT')
--OR (ass.CODE IN
--(
--N'4120039766'
--)
--))-- Untuk exclude agar asset yang sudah ke sold bisa dibuatkan tagihan maintenance 
	and		ass.branch_code		  = case @p_branch_code
										when 'ALL' then ass.branch_code
										else @p_branch_code
									end
	and		(
				ass.code				like '%' + @p_keywords + '%'
				or	ass.item_name		like '%' + @p_keywords + '%'
				or	avh.plat_no			like '%' + @p_keywords + '%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ass.code
													 when 2 then ass.item_name
													 when 3 then avh.plat_no
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													    when 1 then ass.code
														when 2 then ass.item_name
														when 3 then avh.plat_no
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
