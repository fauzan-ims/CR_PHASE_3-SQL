CREATE PROCEDURE dbo.xsp_sale_detail_fee_getrows
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
	from	sale_detail_fee
	where	sale_detail_id = @p_sale_detail_id
	and		(
					fee_code			like '%' + @p_keywords + '%'
					or	fee_name		like '%' + @p_keywords + '%'
					or	fee_amount		like '%' + @p_keywords + '%'
					or	pph_amount		like '%' + @p_keywords + '%'
					or	ppn_amount		like '%' + @p_keywords + '%'
			) ;

	select		id
				,sale_detail_id
				,fee_code
				,fee_name
				,fee_amount
				,pph_amount
				,ppn_amount
				,master_tax_description
				,@rows_count 'rowcount'
	from		sale_detail_fee
	where		sale_detail_id = @p_sale_detail_id
	and			(
					fee_code			like '%' + @p_keywords + '%'
					or	fee_name		like '%' + @p_keywords + '%'
					or	fee_amount		like '%' + @p_keywords + '%'
					or	pph_amount		like '%' + @p_keywords + '%'
					or	ppn_amount		like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then fee_name
													 when 2 then cast(fee_amount as sql_variant)
													 when 3 then master_tax_description
													 when 4 then cast(pph_amount as sql_variant)
													 when 5 then cast(ppn_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then fee_name
													 when 2 then cast(fee_amount as sql_variant)
													 when 3 then master_tax_description
													 when 4 then cast(pph_amount as sql_variant)
													 when 5 then cast(ppn_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
