--Created, Rian at 28/12/2022

CREATE PROCEDURE dbo.xsp_master_bast_checklist_asset_detail_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_asset_type_code	nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;

	select		@rows_count = count(1)
	from		dbo.master_bast_checklist_asset
	where		asset_type_code = @p_asset_type_code
	and			(
					code									like '%' + @p_keywords + '%'
					or	asset_type_code						like '%' + @p_keywords + '%'
					or	checklist_name						like '%' + @p_keywords + '%'
					or	order_key							like '%' + @p_keywords + '%'	
					or	case is_active
						when '1' then 'Yes'
						else 'No'
					end										like '%' + @p_keywords + '%'
				) ;

	select		code
				,asset_type_code
				,checklist_name
				,order_key
				,case is_active
						 when '1' then 'Yes'
						 else 'No'
				end 'is_active'
				,@rows_count 'rowcount'
	from		dbo.master_bast_checklist_asset
	where		asset_type_code = @p_asset_type_code
	and			(
					code									like '%' + @p_keywords + '%'
					or	asset_type_code						like '%' + @p_keywords + '%'
					or	checklist_name						like '%' + @p_keywords + '%'
					or	order_key							like '%' + @p_keywords + '%'	
					or	case is_active
						when '1' then 'Yes'
						else 'No'
					end										like '%' + @p_keywords + '%'
				) 
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code
													 when 2 then checklist_name
													 when 3 then cast(order_key as sql_variant)	
													 when 4 then is_active
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then code
													 when 2 then checklist_name
													 when 3 then cast(order_key as sql_variant)	
													 when 4 then is_active
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
