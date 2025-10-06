CREATE PROCEDURE dbo.xsp_efam_interface_asset_maintenance_schedule_getrows
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
	from	efam_interface_asset_maintenance_schedule
	where	asset_code = @p_asset_code
	and		(
				asset_code											 like '%' + @p_keywords + '%'
				or	maintenance_no									 like '%' + @p_keywords + '%'
				or	convert(nvarchar(30),maintenance_date, 103)		 like '%' + @p_keywords + '%'
				or	maintenance_status								 like '%' + @p_keywords + '%'
				or	reff_trx_no										 like '%' + @p_keywords + '%'
			) ;

	select		id
				,asset_code
				,maintenance_no
				,convert(nvarchar(30), maintenance_date, 103) 'maintenance_date'
				,maintenance_status
				,last_status_date
				,reff_trx_no
				,@rows_count 'rowcount'
	from		efam_interface_asset_maintenance_schedule
	where		asset_code = @p_asset_code
	and			(
					asset_code											 like '%' + @p_keywords + '%'
					or	maintenance_no									 like '%' + @p_keywords + '%'
					or	convert(nvarchar(30),maintenance_date, 103)		 like '%' + @p_keywords + '%'
					or	maintenance_status								 like '%' + @p_keywords + '%'
					or	reff_trx_no										 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then asset_code
													 when 2 then maintenance_no
													 when 3 then cast(maintenance_date as sql_variant)
													 when 4 then maintenance_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													  when 1 then asset_code
													 when 2 then maintenance_no
													 when 3 then cast(maintenance_date as sql_variant)
													 when 4 then maintenance_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
