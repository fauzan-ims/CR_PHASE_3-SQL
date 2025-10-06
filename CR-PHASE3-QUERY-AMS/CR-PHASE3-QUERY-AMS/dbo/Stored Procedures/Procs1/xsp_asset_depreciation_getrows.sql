CREATE PROCEDURE dbo.xsp_asset_depreciation_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_company_code	nvarchar(50)
	,@p_year			nvarchar(4)		= ''
	,@p_month			nvarchar(2)		= ''
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	asset_depreciation ad
			left join dbo.asset ass on (ass.code = ad.asset_code)
	where	ass.company_code = @p_company_code
			and ad.status = 'POST'
			and year(ad.depreciation_date) = @p_year
			and right('0' + convert(nvarchar(2),month(ad.depreciation_date)),2) = @p_month
	and		(
				asset_code											 like '%' + @p_keywords + '%'
				or	convert(nvarchar(30),depreciation_date, 103)	 like '%' + @p_keywords + '%'
				or	depreciation_commercial_amount					 like '%' + @p_keywords + '%'
				or	net_book_value_commercial						 like '%' + @p_keywords + '%'
				or	depreciation_fiscal_amount						 like '%' + @p_keywords + '%'
				or	ad.net_book_value_fiscal						 like '%' + @p_keywords + '%'
				or	purchase_amount									 like '%' + @p_keywords + '%'
				or	ad.status										 like '%' + @p_keywords + '%'
				or	ass.item_name									 like '%' + @p_keywords + '%'
				or	ad.journal_code									 like '%' + @p_keywords + '%'
			) ;

	select		asset_code
				,ass.item_name
				,convert(nvarchar(30),depreciation_date, 103) 'depreciation_date'
				,depreciation_commercial_amount
				,net_book_value_commercial
				,depreciation_fiscal_amount
				,ad.net_book_value_fiscal
				,purchase_amount
				,ad.status
				,ad.journal_code
				,@rows_count 'rowcount'
	from		asset_depreciation ad
				left join dbo.asset ass on (ass.code = ad.asset_code)
	where		ass.company_code = @p_company_code
				and ad.status = 'POST'
				and right('0' + convert(nvarchar(2),month(ad.depreciation_date)),2) = @p_month
	and		(
					asset_code											 like '%' + @p_keywords + '%'
					or	convert(nvarchar(30),depreciation_date, 103)	 like '%' + @p_keywords + '%'
					or	depreciation_commercial_amount					 like '%' + @p_keywords + '%'
					or	net_book_value_commercial						 like '%' + @p_keywords + '%'
					or	depreciation_fiscal_amount						 like '%' + @p_keywords + '%'
					or	ad.net_book_value_fiscal						 like '%' + @p_keywords + '%'
					or	purchase_amount									 like '%' + @p_keywords + '%'
					or	ad.status										 like '%' + @p_keywords + '%'
					or	ass.item_name									 like '%' + @p_keywords + '%'
					or	ad.journal_code									 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then asset_code
													 when 2 then cast(ad.depreciation_date as sql_variant)
													 when 3 then cast(ad.depreciation_commercial_amount as sql_variant)
													 when 4 then cast(ad.net_book_value_commercial as sql_variant)
													 when 5 then cast(ad.depreciation_fiscal_amount as sql_variant)
													 when 6 then cast(ad.net_book_value_fiscal as sql_variant)
													 when 7 then cast(ad.purchase_amount as sql_variant)
													 when 8 then ad.journal_code
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then asset_code
													 when 2 then cast(ad.depreciation_date as sql_variant)
													 when 3 then cast(ad.depreciation_commercial_amount as sql_variant)
													 when 4 then cast(ad.net_book_value_commercial as sql_variant)
													 when 5 then cast(ad.depreciation_fiscal_amount as sql_variant)
													 when 6 then cast(ad.net_book_value_fiscal as sql_variant)
													 when 7 then cast(ad.purchase_amount as sql_variant)
													 when 8 then ad.journal_code
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
