CREATE PROCEDURE dbo.xsp_asset_lookup_for_sale
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
	,@p_location_code	nvarchar(50)
	--,@p_company_code	nvarchar(50)

)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.asset ass
	where	ass.code not in
							(
								select	asset_code
								from	dbo.mutation_detail		md
										inner join dbo.mutation mt on (mt.code = md.mutation_code)
								where	md.status_received		= 'SENT'
										--or md.status_received = 'RETURNED'
										or	md.status_received is null
										or	mt.status in
														(
															'NEW', 'ON PROGRESS'
														)
											--and mt.company_code = @p_company_code
							)
			and ass.code not in
								(
									select	asset_code
									from	dbo.disposal_detail		dd
											inner join dbo.disposal ds on (ds.code = dd.disposal_code)
									where	ds.status in
														(
															'NEW', 'ON PROGRESS'
														)
											--and ds.company_code = @p_company_code
								)
			and ass.code not in
								(
									select	asset_code
									from	dbo.maintenance
									where	status in
													(
														'NEW', 'ON PROGRESS'
													)
										--	and company_code = @p_company_code
								)
			and ass.code not in
								(
									select	asset_code
									from	dbo.sale_detail		sd
											inner join dbo.sale sl on (sl.code = sd.sale_code)
									where	sl.status in
														(
															'NEW', 'ON PROGRESS'
														)
											--and sl.company_code = @p_company_code
								)
			and ass.code not in
								(
									select	asset_code
									from	dbo.adjustment
									where	status in
													(
														'NEW', 'ON PROGRESS'
													)
											--and company_code = @p_company_code
								)
			and ass.status		 = 'STOCK'
			and	ass.branch_code = @p_branch_code
			and (
					ass.code			like '%' + @p_keywords + '%'
					or	ass.barcode		like '%' + @p_keywords + '%'
					or	ass.item_name	like '%' + @p_keywords + '%'
				) ;

	select		ass.code
				,ass.branch_code
				,ass.branch_name
				,ass.item_name
				,ass.division_code
				,ass.division_name
				,ass.department_code
				,ass.barcode
				,ass.department_name
				,ass.net_book_value_comm
				,@rows_count 'rowcount'
	from		dbo.asset ass			
	where	ass.code not in
							(
								select	asset_code
								from	dbo.mutation_detail		md
										inner join dbo.mutation mt on (mt.code = md.mutation_code)
								where	md.status_received		= 'SENT'
										--or md.status_received = 'RETURNED'
										or	md.status_received is null
										or	mt.status in
														(
															'NEW', 'ON PROGRESS'
														)
											--and mt.company_code = @p_company_code
							)
			and ass.code not in
								(
									select	asset_code
									from	dbo.disposal_detail		dd
											inner join dbo.disposal ds on (ds.code = dd.disposal_code)
									where	ds.status in
														(
															'NEW', 'ON PROGRESS'
														)
											--and ds.company_code = @p_company_code
								)
			and ass.code not in
								(
									select	asset_code
									from	dbo.maintenance
									where	status in
													(
														'NEW', 'ON PROGRESS'
													)
											--and company_code = @p_company_code
								)
			and ass.code not in
								(
									select	asset_code
									from	dbo.sale_detail		sd
											inner join dbo.sale sl on (sl.code = sd.sale_code)
									where	sl.status in
														(
															'NEW', 'ON PROGRESS'
														)
											--and sl.company_code = @p_company_code
								)
			and ass.code not in
								(
									select	asset_code
									from	dbo.adjustment
									where	status in
													(
														'NEW', 'ON PROGRESS'
													)
											--and company_code = @p_company_code
								)
				and ass.status		 = 'STOCK'
				and	ass.branch_code = @p_branch_code
				and (
						ass.code			like '%' + @p_keywords + '%'
						or	ass.barcode		like '%' + @p_keywords + '%'
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
