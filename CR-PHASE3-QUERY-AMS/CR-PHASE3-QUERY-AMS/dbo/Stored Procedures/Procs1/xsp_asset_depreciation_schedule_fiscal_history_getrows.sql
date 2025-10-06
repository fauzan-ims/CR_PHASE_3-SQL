
create procedure xsp_asset_depreciation_schedule_fiscal_history_getrows
(
	@p_keywords	nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by	nvarchar(5)
)
as
begin
	declare 	@rows_count int = 0 ;

	select 	@rows_count = count(1)
	from	asset_depreciation_schedule_fiscal_history
	where	(
				asset_code					like 	'%'+@p_keywords+'%'
				or	depreciation_date		like 	'%'+@p_keywords+'%'
				or	original_price			like 	'%'+@p_keywords+'%'
				or	depreciation_amount		like 	'%'+@p_keywords+'%'
				or	accum_depre_amount		like 	'%'+@p_keywords+'%'
				or	net_book_value			like 	'%'+@p_keywords+'%'
				or	transaction_code		like 	'%'+@p_keywords+'%'
			);

	select	id
			,asset_code
			,depreciation_date
			,original_price
			,depreciation_amount
			,accum_depre_amount
			,net_book_value
			,transaction_code
			,@rows_count	 'rowcount'
	from	asset_depreciation_schedule_fiscal_history
	where	(
				asset_code					like 	'%'+@p_keywords+'%'
				or	depreciation_date		like 	'%'+@p_keywords+'%'
				or	original_price			like 	'%'+@p_keywords+'%'
				or	depreciation_amount		like 	'%'+@p_keywords+'%'
				or	accum_depre_amount		like 	'%'+@p_keywords+'%'
				or	net_book_value			like 	'%'+@p_keywords+'%'
				or	transaction_code		like 	'%'+@p_keywords+'%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													when 1	then asset_code
													when 2	then transaction_code
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													when 1	then asset_code
													when 2	then transaction_code
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	
end
