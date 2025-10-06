
-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_final_good_receipt_note_detail_getrows]
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_final_good_receipt_note_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	final_good_receipt_note_detail
	where	final_good_receipt_note_code = @p_final_good_receipt_note_code
	and		(
					item_name									like '%' + @p_keywords + '%'
					or	(po_quantity - receive_quantity)		like '%' + @p_keywords + '%'
					or	receive_quantity						like '%' + @p_keywords + '%'
					or	uom_name								like '%' + @p_keywords + '%'
					or	price_amount							like '%' + @p_keywords + '%'
					or	specification							like '%' + @p_keywords + '%'

			) ;

	select		id
				,item_name
				,po_quantity - receive_quantity 'po_quantity'
				,receive_quantity
				,uom_name
				,price_amount
				,specification
				,@rows_count 'rowcount'
	from		final_good_receipt_note_detail
	where		final_good_receipt_note_code = @p_final_good_receipt_note_code
	AND			(
					item_name									like '%' + @p_keywords + '%'
					or	(po_quantity - receive_quantity)		like '%' + @p_keywords + '%'
					or	receive_quantity						like '%' + @p_keywords + '%'
					or	uom_name								like '%' + @p_keywords + '%'
					or	price_amount							like '%' + @p_keywords + '%'
					or	specification							like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then item_name
														when 2 then cast(po_quantity as sql_variant)
														when 3 then cast(receive_quantity as sql_variant)
														when 4 then uom_name
														when 5 then cast(price_amount as sql_variant)
														when 6 then specification
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then item_name
														when 2 then cast(po_quantity as sql_variant)
														when 3 then cast(receive_quantity as sql_variant)
														when 4 then uom_name
														when 5 then cast(price_amount as sql_variant)
														when 6 then specification
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
