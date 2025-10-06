CREATE PROCEDURE dbo.xsp_receipt_register_detail_getrows
(
	@p_keywords		  nvarchar(50)
	,@p_pagenumber	  int
	,@p_rowspage	  int
	,@p_order_by	  int
	,@p_sort_by		  nvarchar(5)
	,@p_register_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	receipt_register_detail
	where	register_code = @p_register_code
			and (
					receipt_no		like '%' + @p_keywords + '%'
				) ;

		select		id
					,receipt_no
					,@rows_count 'rowcount'
		from		receipt_register_detail
		where		register_code = @p_register_code
					and (
							receipt_no		like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then receipt_no
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then receipt_no
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
