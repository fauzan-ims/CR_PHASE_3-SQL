CREATE PROCEDURE dbo.xsp_efam_interface_asset_furniture_getrows
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
	from	efam_interface_asset_furniture
	where	asset_code = @p_asset_code
	and		(
				asset_code			 like '%' + @p_keywords + '%'
				or	merk_code		 like '%' + @p_keywords + '%'
				or	merk_name		 like '%' + @p_keywords + '%'
				or	type_code		 like '%' + @p_keywords + '%'
				or	type_name		 like '%' + @p_keywords + '%'
				or	model_code		 like '%' + @p_keywords + '%'
				or	model_name		 like '%' + @p_keywords + '%'
				or	remark			 like '%' + @p_keywords + '%'
			) ;

	select		asset_code
				,merk_code
				,merk_name
				,type_code
				,type_name
				,model_code
				,model_name
				,remark
				,@rows_count 'rowcount'
	from		efam_interface_asset_furniture
	where		asset_code = @p_asset_code
	and			(
					asset_code			 like '%' + @p_keywords + '%'
					or	merk_code		 like '%' + @p_keywords + '%'
					or	merk_name		 like '%' + @p_keywords + '%'
					or	type_code		 like '%' + @p_keywords + '%'
					or	type_name		 like '%' + @p_keywords + '%'
					or	model_code		 like '%' + @p_keywords + '%'
					or	model_name		 like '%' + @p_keywords + '%'
					or	remark			 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then asset_code
													 when 2 then merk_code
													 when 3 then merk_name
													 when 4 then type_code
													 when 5 then type_name
													 when 6 then model_code
													 when 7 then model_name
													 when 8 then remark
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then asset_code
													   when 2 then merk_code
													   when 3 then merk_name
													   when 4 then type_code
													   when 5 then type_name
													   when 6 then model_code
													   when 7 then model_name
													   when 8 then remark
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
