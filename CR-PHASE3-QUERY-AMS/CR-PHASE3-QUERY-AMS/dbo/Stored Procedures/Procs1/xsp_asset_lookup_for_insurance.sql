CREATE PROCEDURE dbo.xsp_asset_lookup_for_insurance
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	--
	,@p_register_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.asset					ass
			left join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
	where	ass.status in
	(
		'STOCK', 'REPLACEMENT'
	)
			and
			(
				ISNULL(ass.RENTAL_STATUS,'') <> 'IN USE'
				or	ass.CODE in
					(
						select	ass2.CODE
						from	dbo.asset					   ass2
								inner join dbo.asset_insurance ain on ass2.code = ain.asset_code
						where	ass2.RENTAL_STATUS = 'IN USE'
					)
			)
			and ass.code not in
				(
					select	fa_code
					from	dbo.insurance_register_asset	  a
							inner join dbo.insurance_register b on a.register_code = b.code
					where	b.register_status = 'HOLD'
				)
			--and ass.code not in ( 
			--									select	rm.fa_code from dbo.register_main rm 
			--									where	rm.register_status not in ('PAID','CANCEL')

			--								)
			and
			(
				ass.code			like '%' + @p_keywords + '%'
				or	avh.plat_no		like '%' + @p_keywords + '%'
				or	ass.item_name	like '%' + @p_keywords + '%'
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
				,ass.purchase_price + isnull(ass.ppn_amount, 0) 'purchase_price'
				,ass.total_depre_comm
				,ass.net_book_value_comm
				,ass.item_group_code
				,avh.plat_no
				,avh.built_year
				,@rows_count									'rowcount'
	from		dbo.asset					ass
				left join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
	where		ass.status in
	(
		'STOCK', 'REPLACEMENT'
	)
				and
				(
					ISNULL(ass.RENTAL_STATUS,'') <> 'IN USE'
					or	ass.CODE in
						(
							select	ass2.CODE
							from	dbo.asset					   ass2
									inner join dbo.asset_insurance ain on ass2.code = ain.asset_code
							where	ass2.RENTAL_STATUS = 'IN USE'
						)
				)
				and ass.code not in
					(
						select	fa_code
						from	dbo.insurance_register_asset	  a
								inner join dbo.insurance_register b on a.register_code = b.code
						where	b.register_status = 'HOLD'
					)
				--and ass.code not in ( 
				--									select	rm.fa_code from dbo.register_main rm 
				--									where	rm.register_status not in ('PAID','CANCEL')

				--								)
				and
				(
					ass.code			like '%' + @p_keywords + '%'
					or	avh.plat_no		like '%' + @p_keywords + '%'
					or	ass.item_name	like '%' + @p_keywords + '%'
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
