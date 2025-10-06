
-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_sale_detail_getrows_for_sold_settlement]
(
	@p_keywords	    nvarchar(50)
	,@p_pagenumber  int
	,@p_rowspage    int
	,@p_order_by    int
	,@p_sort_by	    nvarchar(5)
	,@p_status		nvarchar(50)
	,@p_from_date	DATETIME = ''
	,@p_to_date		DATETIME = ''
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	sale_detail sd
			inner join dbo.asset ass		on (ass.code = sd.asset_code)
			left join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
			inner join dbo.sale sl on (sl.code = sd.sale_code)
	where		sd.sale_detail_status = case @p_status
											when 'ALL' then sd.sale_detail_status
											else @p_status
										end
	and isnull(cast(sd.sale_date as date),'') between 
				case cast(@p_from_date as date) 
					when '' then isnull(cast(sd.sale_date as date),'')
					else cast(@p_from_date as date)		
					end		
				and case cast(@p_to_date as date)
					WHEN '' THEN ISNULL(CAST(sd.sale_date AS DATE),'')
					ELSE CAST(@p_to_date AS DATE)
					END
	AND sl.status = 'APPROVE'
	AND		(
				sd.asset_code										LIKE '%' + @p_keywords + '%'
				OR	ass.item_name									LIKE '%' + @p_keywords + '%'
				OR	sd.sale_code									LIKE '%' + @p_keywords + '%'
				OR	sd.sell_request_amount							LIKE '%' + @p_keywords + '%'
				OR	sd.description									LIKE '%' + @p_keywords + '%'
				OR	sd.net_book_value								LIKE '%' + @p_keywords + '%'
				OR	sd.sale_detail_status							LIKE '%' + @p_keywords + '%'
				OR	CONVERT(NVARCHAR(30), sd.sale_date, 103)		LIKE '%' + @p_keywords + '%'
				OR	avh.engine_no									LIKE '%' + @p_keywords + '%'
				OR	avh.chassis_no									LIKE '%' + @p_keywords + '%'
				OR	avh.plat_no										LIKE '%' + @p_keywords + '%'
				OR	ass.agreement_external_no						LIKE '%' + @p_keywords + '%'
				OR	ass.client_name									LIKE '%' + @p_keywords + '%'
				OR	CASE WHEN sl.sell_type = 'COP' THEN 'PURCHASE REQUIREMENT AFTER LEASE'
						ELSE sl.sell_type
					END												LIKE '%' + @p_keywords + '%'
				or	sd.print_count									like '%' + @p_keywords + '%'
				OR	CASE 
					WHEN sd.is_sold = '1' THEN 'SOLD'
					ELSE 'NOT SOLD'
				END													LIKE '%' + @p_keywords + '%'
				OR	sl.buyer_name									LIKE '%' + @p_keywords + '%'
			) ;

	SELECT		id
				,sale_code
				,sd.asset_code
				,ass.item_name
				,sd.description
				,ass.barcode
				,sd.net_book_value
				,gain_loss --(isnull(sd.sale_value,0) - isnull(sd.net_book_value,0)) 'gain_loss'
				,sd.sell_request_amount
				,sd.sale_detail_status
				,convert(nvarchar(30), sd.sale_date, 103) 'sale_date'
				,avh.engine_no
				,avh.plat_no
				,avh.chassis_no
				,ass.agreement_external_no
				,ass.client_name
				--,sl.sell_type
				,case when sl.sell_type = 'COP' then 'PURCHASE REQUIREMENT AFTER LEASE'
						else sl.sell_type
					end 'sell_type'
				,case 
					when isnull(sd.is_sold,0) = '1' then 'SOLD'
					else 'NOT SOLD'
				end 'is_sold'
				,sl.buyer_name
				,sd.print_count
				,@rows_count 'rowcount'
	from		sale_detail sd
				inner join dbo.asset ass on (ass.code = sd.asset_code)
				left join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
				inner join dbo.sale sl on (sl.code = sd.sale_code)
	where		sd.sale_detail_status = case @p_status
											when 'ALL' then sd.sale_detail_status
											else @p_status
										END
    and isnull(cast(sd.sale_date as date),'') between 
				case cast(@p_from_date as date) 
					when '' then isnull(cast(sd.sale_date as date),'')
					else cast(@p_from_date as date)		
					end		
				and case cast(@p_to_date as date)
					when '' then isnull(cast(sd.sale_date as date),'')
					else cast(@p_to_date as date)
					end
	and sl.status = 'APPROVE'
	and			(
					sd.asset_code										like '%' + @p_keywords + '%'
					or	ass.item_name									like '%' + @p_keywords + '%'
					or	sd.sale_code									like '%' + @p_keywords + '%'
					or	sd.sell_request_amount							like '%' + @p_keywords + '%'
					or	sd.description									like '%' + @p_keywords + '%'
					or	sd.net_book_value								like '%' + @p_keywords + '%'
					or	sd.sale_detail_status							like '%' + @p_keywords + '%'
					or	convert(nvarchar(30), sd.sale_date, 103)		like '%' + @p_keywords + '%'
					or	avh.engine_no									like '%' + @p_keywords + '%'
					or	avh.chassis_no									like '%' + @p_keywords + '%'
					or	avh.plat_no										like '%' + @p_keywords + '%'
					or	ass.agreement_external_no						like '%' + @p_keywords + '%'
					or	ass.client_name									like '%' + @p_keywords + '%'
					or	case when sl.sell_type = 'COP' then 'PURCHASE REQUIREMENT AFTER LEASE'
						else sl.sell_type
					end													like '%' + @p_keywords + '%'
					or	sl.buyer_name									like '%' + @p_keywords + '%'
					or	sd.print_count									like '%' + @p_keywords + '%'
					or	case 
						when sd.is_sold = '1' then 'SOLD'
						else 'NOT SOLD'
					end													like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then sd.sale_code
													 when 2 then sd.asset_code 
													 when 3 then avh.plat_no
													 when 4 then cast(sd.sale_date as sql_variant)
													 when 5 then sell_type--sl.sell_type
													 when 6 then cast(sd.net_book_value as sql_variant)
													 when 7 then cast(sd.sell_request_amount as sql_variant)
													 when 8 then sd.description
													 --when 9 then sd.sale_detail_status
													 when 9 then sd.print_count
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then sd.sale_code
													 when 2 then sd.asset_code + ass.item_name
													 when 3 then avh.plat_no
													 when 4 then cast(sd.sale_date as sql_variant)
													 when 5 then sell_type --sl.sell_type
													 when 6 then cast(sd.net_book_value as sql_variant)
													 when 7 then cast(sd.sell_request_amount as sql_variant)
													 when 8 then sd.description
													 --when 9 then sd.sale_detail_status
													 when 9 then sd.print_count
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
