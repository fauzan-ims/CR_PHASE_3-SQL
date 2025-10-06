create procedure dbo.xsp_document_movement_lookup_for_received
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	document_movement
	where	flag_borrow = 'ON BORROW'
			and (movement_to_client_name like '%' + @p_keywords + '%') ;

	select		code
				,movement_to_client_name
				,@rows_count 'rowcount'
	from		document_movement
	where		flag_borrow = 'ON BORROW'
				and (movement_to_client_name like '%' + @p_keywords + '%')
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then movement_to_client_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then movement_to_client_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
