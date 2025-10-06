CREATE PROCEDURE dbo.xsp_efam_interface_asset_barcode_history_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_asset_code		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	efam_interface_asset_barcode_history
	where	asset_code = @p_asset_code
	and		(
				id						 like '%' + @p_keywords + '%'
				or	asset_code			 like '%' + @p_keywords + '%'
				or	previous_barcode	 like '%' + @p_keywords + '%'
				or	new_barcode			 like '%' + @p_keywords + '%'
				or	remark				 like '%' + @p_keywords + '%'
			) ;

	select		id
				,asset_code
				,previous_barcode
				,new_barcode
				,remark
				,@rows_count 'rowcount'
	from		efam_interface_asset_barcode_history
	where		asset_code = @p_asset_code
	and			(
					id						 like '%' + @p_keywords + '%'
					or	asset_code			 like '%' + @p_keywords + '%'
					or	previous_barcode	 like '%' + @p_keywords + '%'
					or	new_barcode			 like '%' + @p_keywords + '%'
					or	remark				 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then asset_code
													 when 2 then previous_barcode
													 when 3 then new_barcode
													 when 4 then remark
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then asset_code
													   when 2 then previous_barcode
													   when 3 then new_barcode
													   when 4 then remark
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
