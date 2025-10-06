CREATE PROCEDURE dbo.xsp_inventory_adjustment_detail_getrows
(
	 @p_keywords					nvarchar(50)
	,@p_pagenumber					int
	,@p_rowspage					int
	,@p_order_by					int
	,@p_sort_by						nvarchar(5)
	,@p_inventory_adjustment_code	nvarchar(50)
)
as
begin
	declare 	@rows_count int = 0 ;

	select 	@rows_count = count(1)
	from	inventory_adjustment_detail iad
	left join dbo.master_warehouse mw on mw.code = iad.warehouse_code
	where	iad.inventory_adjustment_code = @p_inventory_adjustment_code
			and (
					iad.item_code											like 	'%'+@p_keywords+'%'
					or	convert(nvarchar(30), iad.total_adjustment, 103)	like 	'%'+@p_keywords+'%'
					or	iad.item_name										like 	'%'+@p_keywords+'%'
					or	case iad.plus_or_minus
							when '1' then 'Plus'
							else 'Minus'
						end													like '%' + @p_keywords + '%'
			);

	
		select	 iad.id
				,iad.inventory_adjustment_code
				,iad.item_code
				,iad.item_name
				,case iad.plus_or_minus
						when '1' then 'Plus'
						else 'Minus'
					end 'plus_or_minus'
				,iad.warehouse_code
				,mw.description 'warehouse_name'
				,iad.total_adjustment
				,iad.remark
				,@rows_count	 'rowcount'
		from	inventory_adjustment_detail iad
		left join dbo.master_warehouse mw on mw.code = iad.warehouse_code
		where	iad.inventory_adjustment_code = @p_inventory_adjustment_code
				and (
						iad.item_code											like 	'%'+@p_keywords+'%'
						or	convert(nvarchar(30), iad.total_adjustment, 103)	like 	'%'+@p_keywords+'%'
						or	iad.item_name										like 	'%'+@p_keywords+'%'
						or	case iad.plus_or_minus
								when '1' then 'Plus'
								else 'Minus'
							end													like '%' + @p_keywords + '%'
					)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
							when 1	then iad.item_code
							when 2	then iad.item_name
							when 3	then cast(iad.total_adjustment as sql_variant)
							when 4	then iad.plus_or_minus
					 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
							when 1	then iad.item_code
							when 2	then iad.item_name
							when 3	then cast(iad.total_adjustment as sql_variant)
							when 4	then iad.plus_or_minus
						 end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
