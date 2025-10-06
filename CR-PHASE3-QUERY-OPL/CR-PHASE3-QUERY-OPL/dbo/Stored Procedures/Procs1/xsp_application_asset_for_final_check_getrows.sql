CREATE PROCEDURE dbo.xsp_application_asset_for_final_check_getrows
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_application_no nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from
			(
				select	aa.asset_no
						,aa.asset_name
						,aa.asset_type_code
						,sgs.description 'asset_type'
						,aa.asset_year 
				from	dbo.application_asset_vehicle aav
						inner join dbo.application_asset aa on (aa.asset_no = aav.asset_no)
						inner join dbo.sys_general_subcode sgs on (sgs.code = aa.asset_type_code)
				where	aa.application_no = @p_application_no
				union
				select	aa.asset_no
						,aa.asset_name
						,aa.asset_type_code
						,sgs.description 'asset_type'
						,aa.asset_year 
				from	dbo.application_asset_he aah
						inner join dbo.application_asset aa on (aa.asset_no = aah.asset_no)
						inner join dbo.sys_general_subcode sgs on (sgs.code = aa.asset_type_code)
				where	aa.application_no = @p_application_no
				union
				select	aa.asset_no
						,aa.asset_name
						,aa.asset_type_code
						,sgs.description 'asset_type'
						,aa.asset_year 
				from	dbo.application_asset_machine aam
						inner join dbo.application_asset aa on (aa.asset_no = aam.asset_no)
						inner join dbo.sys_general_subcode sgs on (sgs.code = aa.asset_type_code)
				where	aa.application_no = @p_application_no
			) as asset
	where	(
				asset.asset_name			like '%' + @p_keywords + '%'
				or	asset.asset_type		like '%' + @p_keywords + '%'
				or	asset.asset_year		like '%' + @p_keywords + '%' 
			) ;

		select	*
		from		
				(
					select	aa.asset_no
							,aa.asset_name
							,aa.asset_type_code
							,sgs.description 'asset_type'
							,aa.asset_year 
							,@rows_count 'rowcount'
					from	dbo.application_asset_vehicle aav
							inner join dbo.application_asset aa on (aa.asset_no = aav.asset_no)
							inner join dbo.sys_general_subcode sgs on (sgs.code = aa.asset_type_code)
					where	aa.application_no = @p_application_no
					union
					select	aa.asset_no
							,aa.asset_name
							,aa.asset_type_code
							,sgs.description 'asset_type'
							,aa.asset_year 
							,@rows_count 'rowcount'
					from	dbo.application_asset_he aah
							inner join dbo.application_asset aa on (aa.asset_no = aah.asset_no)
							inner join dbo.sys_general_subcode sgs on (sgs.code = aa.asset_type_code)
					where	aa.application_no = @p_application_no
					union
					select	aa.asset_no
							,aa.asset_name
							,aa.asset_type_code
							,sgs.description 'asset_type'
							,aa.asset_year 
							,@rows_count 'rowcount'
					from	dbo.application_asset_machine aam
							inner join dbo.application_asset aa on (aa.asset_no = aam.asset_no)
							inner join dbo.sys_general_subcode sgs on (sgs.code = aa.asset_type_code)
					where	aa.application_no = @p_application_no
				) as asset
		where	(
					asset.asset_name			like '%' + @p_keywords + '%'
					or	asset.asset_type		like '%' + @p_keywords + '%'
					or	asset.asset_year		like '%' + @p_keywords + '%' 
				) 
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then asset.asset_name			
														when 2 then asset.asset_type		
														when 3 then cast(asset.asset_year as sql_variant)	 
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then asset.asset_name			
														when 2 then asset.asset_type		
														when 3 then cast(asset.asset_year as sql_variant) 
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;  
end ;

