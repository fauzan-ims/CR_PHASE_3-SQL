CREATE PROCEDURE dbo.xsp_asset_lookup_for_sold_request
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	--
	,@p_branch_code		nvarchar(50)
	,@p_sell_type		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
		and		value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;

	if(@p_sell_type <> 'COP')
	begin
		select	@rows_count = count(1)
		from	dbo.asset ass
		left join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
		where	ass.code not in
									(
										select	asset_code
										from	dbo.disposal_detail		dd
												inner join dbo.disposal ds on (ds.code = dd.disposal_code)
										where	ds.status in
															(
																'HOLD', 'ON PROCESS'
															)
									)
				and ass.code not in
									(
										select	asset_code
										from	dbo.maintenance
										where	status in
														(
															'HOLD', 'ON PROCESS'
														)
									)
				and ass.code not in
									(
										select	asset_code
										from	dbo.sale_detail sd
										inner join dbo.sale s on s.code = sd.sale_code
										where	s.status not in ('CANCEL','REJECT') and
												(sd.sale_detail_status in
															(
																'HOLD', 'ON PROCESS'
															)
												OR (ISNULL(sd.IS_SOLD,'')='1' AND sd.SALE_DETAIL_STATUS ='POST')) --(+) RAFFY 2025/07/09 PENAMBAHAN LOGIC AGAR JIKA SOLD DAN SUDAH POST, TIDAK BISA DIINPUT ULANG ASSETNYA DI SALE REQUEST : IMON 2507000088
									)
				and ass.code not in
									(
										select	asset_code
										from	dbo.adjustment
										where	status in
														(
															'HOLD', 'ON PROCESS'
														)
									)
				and ass.status		 in ('STOCK', 'REPLACEMENT')
				and ass.asset_from = 'BUY'
				and ass.fisical_status = 'ON HAND'
				and isnull(ass.rental_status,'')=''
				and	ass.branch_code = case @p_branch_code
									when 'ALL' then ass.branch_code
									else @p_branch_code
								end	
				and (
						ass.code					like '%' + @p_keywords + '%'
						or	ass.item_name			like '%' + @p_keywords + '%'
						or	ass.sell_request_amount	like '%' + @p_keywords + '%'
						or	avh.plat_no				like '%' + @p_keywords + '%'
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
					,isnull(ass.sell_request_amount,0) 'sell_request_amount'
					,avh.plat_no
					,@rows_count 'rowcount'
		from		dbo.asset ass
		left join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
		where	ass.code not in
									(
										select	asset_code
										from	dbo.disposal_detail		dd
												inner join dbo.disposal ds on (ds.code = dd.disposal_code)
										where	ds.status in
															(
																'HOLD', 'ON PROCESS'
															)
									)
				and ass.code not in
									(
										select	asset_code
										from	dbo.maintenance
										where	status in
														(
															'HOLD', 'ON PROCESS'
														)
									)
				and ass.code not in
									(
										select	asset_code
										from	dbo.sale_detail sd
										inner join dbo.sale s on s.code = sd.sale_code
										where	s.status not in ('CANCEL','REJECT') and
												(sd.sale_detail_status in
															(
																'HOLD', 'ON PROCESS'
															)
												OR (ISNULL(sd.IS_SOLD,'')='1' AND sd.SALE_DETAIL_STATUS ='POST')) --(+) RAFFY 2025/07/09 PENAMBAHAN LOGIC AGAR JIKA SOLD DAN SUDAH POST, TIDAK BISA DIINPUT ULANG ASSETNYA DI SALE REQUEST : IMON 2507000088
									)
				and ass.code not in
									(
										select	asset_code
										from	dbo.adjustment
										where	status in
														(
															'HOLD', 'ON PROCESS'
														)
									)
					and ass.status		 in ('STOCK', 'REPLACEMENT')
					and ass.asset_from = 'BUY'
					and ass.fisical_status = 'ON HAND'
					and isnull(ass.rental_status,'')=''
					and	ass.branch_code = case @p_branch_code
									when 'ALL' then ass.branch_code
									else @p_branch_code
								end	
					and (
							ass.code					like '%' + @p_keywords + '%'
							or	ass.item_name			like '%' + @p_keywords + '%'
							or	ass.sell_request_amount	like '%' + @p_keywords + '%'
							or	avh.plat_no				like '%' + @p_keywords + '%'
						)
		order by	case
		when @p_sort_by = 'asc' then case @p_order_by
										when 1 then ass.code
										when 2 then ass.item_name
										when 3 then avh.plat_no
										when 4 then cast(ass.sell_request_amount as sql_variant)
									end
					end asc
					,case
						 when @p_sort_by = 'desc' then case @p_order_by
															when 1 then ass.code
															when 2 then ass.item_name
															when 3 then avh.plat_no
															when 4 then cast(ass.sell_request_amount as sql_variant)
													   end
					 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end
	else
	begin
		select	@rows_count = count(1)
		from	dbo.asset ass
		left join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
		where	ass.code not in
									(
										select	asset_code
										from	dbo.disposal_detail		dd
												inner join dbo.disposal ds on (ds.code = dd.disposal_code)
										where	ds.status in
															(
																'HOLD', 'ON PROCESS'
															)
									)
				and ass.code not in
									(
										select	asset_code
										from	dbo.maintenance
										where	status in
														(
															'HOLD', 'ON PROCESS'
														)
									)
				and ass.code not in
									(
										select	asset_code
										from	dbo.sale_detail sd
										inner join dbo.sale s on s.code = sd.sale_code
										where	s.status not in ('CANCEL','REJECT') and
												(sd.sale_detail_status in
															(
																'HOLD', 'ON PROCESS'
															)
												OR (ISNULL(sd.IS_SOLD,'')='1' AND sd.SALE_DETAIL_STATUS ='POST')) --(+) RAFFY 2025/07/09 PENAMBAHAN LOGIC AGAR JIKA SOLD DAN SUDAH POST, TIDAK BISA DIINPUT ULANG ASSETNYA DI SALE REQUEST : IMON 2507000088
									)
				and ass.code not in
									(
										select	asset_code
										from	dbo.adjustment
										where	status in
														(
															'HOLD', 'ON PROCESS'
														)
									)
				and ass.status		 = 'STOCK'
				and ass.fisical_status IN ('ON CUSTOMER', 'ON HAND')
				and	ass.branch_code = case @p_branch_code
									when 'ALL' then ass.branch_code
									else @p_branch_code
								end	
				and (
						ass.code					like '%' + @p_keywords + '%'
						or	ass.item_name			like '%' + @p_keywords + '%'
						or	ass.sell_request_amount	like '%' + @p_keywords + '%'
						or	avh.plat_no				like '%' + @p_keywords + '%'
					) ;

		select	ass.code
				,ass.branch_code
				,ass.branch_name
				,ass.item_name
				,ass.division_code
				,ass.division_name
				,ass.department_code
				,ass.barcode
				,ass.department_name
				,ass.net_book_value_comm
				,isnull(ass.sell_request_amount,0) 'sell_request_amount'
				,avh.plat_no
				,@rows_count 'rowcount'
		from		dbo.asset ass
		left join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
		where	ass.code not in
									(
										select	asset_code
										from	dbo.disposal_detail		dd
												inner join dbo.disposal ds on (ds.code = dd.disposal_code)
										where	ds.status in
															(
																'HOLD', 'ON PROCESS'
															)
									)
				and ass.code not in
									(
										select	asset_code
										from	dbo.maintenance
										where	status in
														(
															'HOLD', 'ON PROCESS'
														)
									)
				and ass.code not in
									(
										select	asset_code
										from	dbo.sale_detail sd
										inner join dbo.sale s on s.code = sd.sale_code
										where	s.status not in ('CANCEL','REJECT') and
												(sd.sale_detail_status in
															(
																'HOLD', 'ON PROCESS'
															)
												OR (ISNULL(sd.IS_SOLD,'')='1' AND sd.SALE_DETAIL_STATUS ='POST')) --(+) RAFFY 2025/07/09 PENAMBAHAN LOGIC AGAR JIKA SOLD DAN SUDAH POST, TIDAK BISA DIINPUT ULANG ASSETNYA DI SALE REQUEST : IMON 2507000088
									)
				and ass.code not in
									(
										select	asset_code
										from	dbo.adjustment
										where	status in
														(
															'HOLD', 'ON PROCESS'
														)
									)
					and ass.status		 = 'STOCK'
					and ass.fisical_status IN ('ON CUSTOMER', 'ON HAND')
					and	ass.branch_code = case @p_branch_code
									when 'ALL' then ass.branch_code
									else @p_branch_code
								end	
					and (
							ass.code					like '%' + @p_keywords + '%'
							or	ass.item_name			like '%' + @p_keywords + '%'
							or	ass.sell_request_amount	like '%' + @p_keywords + '%'
							or	avh.plat_no				like '%' + @p_keywords + '%'
						)
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
														 when 1 then ass.code
														 when 2 then ass.item_name
														 when 3 then avh.plat_no
														 when 4 then cast(ass.sell_request_amount as sql_variant)
													 end
					end asc
					,case
						 when @p_sort_by = 'desc' then case @p_order_by
															when 1 then ass.code
															when 2 then ass.item_name
															when 3 then avh.plat_no
															when 4 then cast(ass.sell_request_amount as sql_variant)
													   end
					 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end
end ;
