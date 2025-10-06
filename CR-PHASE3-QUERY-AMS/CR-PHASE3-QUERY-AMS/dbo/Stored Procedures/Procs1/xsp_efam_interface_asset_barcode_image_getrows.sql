CREATE procedure dbo.xsp_efam_interface_asset_barcode_image_getrows
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
	from	efam_interface_asset_barcode_image
	where	(
				asset_code like '%' + @p_keywords + '%'
				or	barcode like '%' + @p_keywords + '%'
			) ;

	select		asset_code
				,barcode
				,barcode_image
				,@rows_count 'rowcount'
	from		efam_interface_asset_barcode_image
	where		(
					asset_code like '%' + @p_keywords + '%'
					or	barcode like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then asset_code
													 when 2 then barcode
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then asset_code
													   when 2 then barcode
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
