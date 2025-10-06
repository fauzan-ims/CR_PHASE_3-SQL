create PROCEDURE dbo.xsp_master_barcode_register_detail_getrows
(
	@p_keywords					nvarchar(50)
	,@p_pagenumber				int
	,@p_rowspage				int
	,@p_order_by				int
	,@p_sort_by					nvarchar(5)
	,@p_barcode_register_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_barcode_register_detail
	where	barcode_register_code = @p_barcode_register_code
	and	
			(
				id								like '%' + @p_keywords + '%'
				or	barcode_no					like '%' + @p_keywords + '%'
				or	barcode_register_code		like '%' + @p_keywords + '%'
				or	asset_code					like '%' + @p_keywords + '%'
				or	status						like '%' + @p_keywords + '%'
			) ;

	select		id
				,barcode_no
				,barcode_register_code
				,asset_code
				,status
				,@rows_count 'rowcount'
	from		master_barcode_register_detail
	where		barcode_register_code = @p_barcode_register_code
	and
				(
					id								like '%' + @p_keywords + '%'
					or	barcode_no					like '%' + @p_keywords + '%'
					or	barcode_register_code		like '%' + @p_keywords + '%'
					or	asset_code					like '%' + @p_keywords + '%'
					or	status						like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then barcode_no
													 when 2 then barcode_register_code
													 when 3 then asset_code
													 when 4 then status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then barcode_no
													   when 2 then barcode_register_code
													   when 3 then asset_code
													   when 4 then status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
