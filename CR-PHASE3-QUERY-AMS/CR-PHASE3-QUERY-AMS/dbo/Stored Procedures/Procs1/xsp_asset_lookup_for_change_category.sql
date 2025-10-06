CREATE PROCEDURE dbo.xsp_asset_lookup_for_change_category
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_company_code		nvarchar(50)
	,@p_branch_code			nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.asset ass
	left join dbo.master_depre_category_fiscal mdcf on (mdcf.code = ass.depre_category_fiscal_code and mdcf.company_code = ass.company_code)
	left join dbo.master_depre_category_commercial mdcc on (mdcc.code = ass.depre_category_comm_code and ass.company_code = mdcc.company_code)
	left join dbo.master_category mc on (mc.code = ass.category_code)
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
			and ass.code not in
								(
									select	asset_code
									from	dbo.maintenance
									where	status in
													(
														'HOLD', 'ON PROCESS'
													)
											and company_code = @p_company_code
								)
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
	and		ass.status		 = 'STOCK'
	and		ass.company_code = @p_company_code
	and		ass.branch_code	 = @p_branch_code
	and		(
				ass.code						like '%' + @p_keywords + '%'
				or	ass.barcode					like '%' + @p_keywords + '%'
				or	ass.item_name				like '%' + @p_keywords + '%'
			) ;

	select		 ass.code
				,ass.branch_code
				,ass.branch_name
				,ass.item_name
				,ass.item_code
				,ass.division_code
				,ass.division_name
				,ass.department_code
				,ass.department_name
				,ass.barcode
				,ass.depre_category_comm_code
				,mdcc.description 'depre_category_comm_name'
				,ass.depre_category_fiscal_code
				,mdcf.description 'depre_category_fiscal_name'
				,ass.category_code
				,mc.description 'category_name'
				,ass.original_price
				,ass.purchase_price
				,ass.net_book_value_comm
				,ass.net_book_value_fiscal
				,@rows_count 'rowcount'
	from		dbo.asset ass
	left join dbo.master_depre_category_fiscal mdcf on (mdcf.code = ass.depre_category_fiscal_code and mdcf.company_code = ass.company_code)
	left join dbo.master_depre_category_commercial mdcc on (mdcc.code = ass.depre_category_comm_code and ass.company_code = mdcc.company_code)
	left join .dbo.master_category mc on (mc.code = ass.category_code)
	where		ass.code not in
							(
								select	asset_code
								from	dbo.mutation_detail		md
										inner join dbo.mutation mt on (mt.code = md.mutation_code)
								where	md.status_received		= 'SENT'
										--or md.status_received = 'RETURNED'
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
			and ass.code not in
								(
									select	asset_code
									from	dbo.maintenance
									where	status in
													(
														'HOLD', 'ON PROCESS'
													)
											and company_code = @p_company_code
								)
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
	and			ass.status		 = 'STOCK'
	and			ass.company_code = @p_company_code
	and			ass.branch_code	 = @p_branch_code
	and			(
					ass.code							like '%' + @p_keywords + '%'
					or	ass.barcode						like '%' + @p_keywords + '%'
					or	ass.item_name					like '%' + @p_keywords + '%'
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
