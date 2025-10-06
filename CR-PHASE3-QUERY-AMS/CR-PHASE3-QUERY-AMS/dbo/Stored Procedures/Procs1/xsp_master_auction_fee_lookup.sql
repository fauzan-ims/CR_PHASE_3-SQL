CREATE PROCEDURE dbo.xsp_master_auction_fee_lookup
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_sale_detail_id	bigint
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_auction_fee
	where	is_active = '1'
			and code not in (
					select	fee_code
					from	dbo.sale_detail_fee
					where	sale_detail_id	= @p_sale_detail_id
			)
			and (
					code					like '%' + @p_keywords + '%'
					or	auction_fee_name	like '%' + @p_keywords + '%'
				) ;

		select		code
					,auction_fee_name
					,@rows_count 'rowcount'
		from		master_auction_fee
		where		is_active = '1'
					and code not in (
							select	fee_code
							from	dbo.sale_detail_fee
							where	sale_detail_id	= @p_sale_detail_id
					)
					and (
							code					like '%' + @p_keywords + '%'
							or	auction_fee_name	like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then auction_fee_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then code
													   when 2 then auction_fee_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
