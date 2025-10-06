CREATE PROCEDURE dbo.xsp_unsubscribe_request_gps_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_status				nvarchar(20)
	,@p_source_transaction	nvarchar(20)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.gps_unsubcribe_request gur
	inner join	dbo.asset				ast on ast.code			= gur.fa_code
	left join dbo.asset_vehicle			av	on av.asset_code	= gur.fa_code
	where	gur.status = case @p_status
						when 'all' then gur.status
						else @p_status
					end
	and		gur.source_reff_name = case @p_source_transaction
						when 'all' then gur.source_reff_name
						else @p_source_transaction
					end
	and		(
				gur.request_no									like '%' + @p_keywords + '%'
				or convert(nvarchar(30), gur.request_date, 103)	like '%' + @p_keywords + '%'
				or ast.item_name								like '%' + @p_keywords + '%'
				or ast.code										like '%' + @p_keywords + '%'
				or av.plat_no									like '%' + @p_keywords + '%'
				or av.engine_no									like '%' + @p_keywords + '%'
				or av.chassis_no								like '%' + @p_keywords + '%'
				or gur.remark									like '%' + @p_keywords + '%'
				or gur.source_reff_no							like '%' + @p_keywords + '%'
				or gur.source_reff_name							like '%' + @p_keywords + '%'
				or ast.gps_vendor_name							like '%' + @p_keywords + '%'
				or gur.status									like '%' + @p_keywords + '%'
			) ;

	select		gur.request_no
				,convert(nvarchar(30), gur.request_date, 103) 'request_date'
				,ast.code
				,ast.item_name
				,av.plat_no
				,av.engine_no
				,av.chassis_no
				,gur.source_reff_no
				,gur.source_reff_name
				,gur.remark
				,ast.gps_vendor_name 'vendor_name'
				,gur.status
				,@rows_count 'rowcount'
	from	dbo.gps_unsubcribe_request gur
	inner join	dbo.asset				ast on ast.code			= gur.fa_code
	left join dbo.asset_vehicle			av	on av.asset_code	= gur.fa_code
	where	gur.status = case @p_status
						when 'all' then gur.status
						else @p_status
					end
	and		gur.source_reff_name = case @p_source_transaction
						when 'all' then gur.source_reff_name
						else @p_source_transaction
					end
	and		(
				gur.request_no									like '%' + @p_keywords + '%'
				or convert(nvarchar(30), gur.request_date, 103)	like '%' + @p_keywords + '%'
				or ast.item_name								like '%' + @p_keywords + '%'
				or ast.code										like '%' + @p_keywords + '%'
				or av.plat_no									like '%' + @p_keywords + '%'
				or av.engine_no									like '%' + @p_keywords + '%'
				or av.chassis_no								like '%' + @p_keywords + '%'
				or gur.remark									like '%' + @p_keywords + '%'
				or gur.source_reff_no							like '%' + @p_keywords + '%'
				or gur.source_reff_name							like '%' + @p_keywords + '%'
				or ast.gps_vendor_name							like '%' + @p_keywords + '%'
				or gur.status									like '%' + @p_keywords + '%'
				)	
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then gur.request_no + convert(varchar(10), gur.request_date, 112) 
													when 2 then ast.code + ast.item_name
													when 3 then av.plat_no + av.chassis_no + av.engine_no
													when 4 then gur.source_reff_no + gur.source_reff_name
													when 5 then gur.remark
													when 6 then ast.gps_vendor_name
													when 7 then gur.status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													when 1 then gur.request_no + convert(varchar(10), gur.request_date, 112) 
													when 2 then ast.code + ast.item_name
													when 3 then av.plat_no + av.chassis_no + av.engine_no
													when 4 then gur.source_reff_no + gur.source_reff_name
													when 5 then gur.remark
													when 6 then ast.gps_vendor_name
													when 7 then gur.status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
