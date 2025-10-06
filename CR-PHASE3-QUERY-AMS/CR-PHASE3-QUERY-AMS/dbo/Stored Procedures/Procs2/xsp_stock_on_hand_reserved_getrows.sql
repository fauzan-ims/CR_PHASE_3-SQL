CREATE PROCEDURE [dbo].[xsp_stock_on_hand_reserved_getrows]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	if exists
	(
		select	1
		from	sys_global_param

		where	code	  = 'ho'
				and value = @p_branch_code
	)
	begin
		set @p_branch_code = 'all' ;
	end ;

	select	@rows_count = count(1)
	from	dbo.asset	ast
			inner join	dbo.asset_vehicle	av				on av.asset_code		= ast.code
			inner join ifinopl.dbo.application_asset aa		on aa.fa_code			= ast.code  and ast.rental_reff_no = aa.asset_no
			inner join ifinopl.dbo.application_main am		on am.application_no	= aa.application_no
	where		ast.branch_code = case @p_branch_code
										when 'all' then ast.branch_code
										else @p_branch_code
									end
	and			ast.status					= 'stock'
	and			ast.fisical_status			= 'on hand'
	and			ast.rental_status			= 'reserved'
	and			am.application_status not in ('reject','cancel')
	--and			ast.monitoring_status	= 'reserved'
	and		(
				ast.code										    LIKE '%' + @p_keywords + '%'
				or ast.branch_code								    LIKE '%' + @p_keywords + '%'
				or ast.branch_name								    LIKE '%' + @p_keywords + '%'
				or ast.item_name								    LIKE '%' + @p_keywords + '%'
				or av.built_year								    LIKE '%' + @p_keywords + '%'
				or av.plat_no									    LIKE '%' + @p_keywords + '%'	
				or av.engine_no									    LIKE '%' + @p_keywords + '%'
				or av.chassis_no								    LIKE '%' + @p_keywords + '%'
				or am.application_no							    LIKE '%' + @p_keywords + '%'
				or ast.client_name								    LIKE '%' + @p_keywords + '%'
				or am.marketing_name							    LIKE '%' + @p_keywords + '%'
				or convert(varchar(30), am.application_date, 103)	LIKE '%' + @p_keywords + '%'
				or replace(am.application_no, '.', '/')	            LIKE '%' + @p_keywords + '%'
				or ast.parking_location	                            LIKE '%' + @p_keywords + '%'
				or ast.unit_province_name	                        LIKE '%' + @p_keywords + '%'
				or ast.unit_city_name	                            LIKE '%' + @p_keywords + '%'
				or ast.status_condition                             LIKE '%' + @p_keywords + '%'
				or ast.status_remark	                            LIKE '%' + @p_keywords + '%'
				or ast.status_last_update_by	                    LIKE '%' + @p_keywords + '%'
				or ast.status_progress	                            LIKE '%' + @p_keywords + '%'
			) ;

	select		ast.code		
				,ast.branch_code
				,ast.branch_name
				,ast.item_name
				,av.built_year
				,av.plat_no
				,av.engine_no
				,av.chassis_no
				,replace(am.application_no, '.', '/') 'application_no'
				,ast.client_name
				,am.marketing_name
				--,convert(varchar(30), ast.reserved_date, 103) as reserved_date
				,convert(varchar(30), am.application_date, 103) as reserved_date
				,ast.parking_location
				,ast.unit_province_name
				,ast.unit_city_name
				,ast.status_condition
				,ast.status_progress
				,ast.status_remark
				,ast.status_last_update_by	'last_update_by'
				,@rows_count 'rowcount'
	from	dbo.asset	ast
			inner join	dbo.asset_vehicle	av				on av.asset_code		= ast.code
			inner join ifinopl.dbo.application_asset aa		on aa.fa_code			= ast.code and ast.rental_reff_no = aa.asset_no
			inner join ifinopl.dbo.application_main am		on am.application_no	= aa.application_no
	where		ast.branch_code = case @p_branch_code
										when 'all' then ast.branch_code
										else @p_branch_code
									end
	and			ast.status					= 'stock'
	and			ast.fisical_status			= 'on hand'
	and			ast.rental_status			= 'reserved'
	and			am.application_status not in ('reject','cancel')
	--and			ast.monitoring_status	= 'reserved'
	and		(
				ast.code										    LIKE '%' + @p_keywords + '%'
				or ast.branch_code								    LIKE '%' + @p_keywords + '%'
				or ast.branch_name								    LIKE '%' + @p_keywords + '%'
				or ast.item_name								    LIKE '%' + @p_keywords + '%'
				or av.built_year								    LIKE '%' + @p_keywords + '%'
				or av.plat_no									    LIKE '%' + @p_keywords + '%'	
				or av.engine_no									    LIKE '%' + @p_keywords + '%'
				or av.chassis_no								    LIKE '%' + @p_keywords + '%'
				or am.application_no							    LIKE '%' + @p_keywords + '%'
				or ast.client_name								    LIKE '%' + @p_keywords + '%'
				or am.marketing_name							    LIKE '%' + @p_keywords + '%'
				or convert(varchar(30), am.application_date, 103)	LIKE '%' + @p_keywords + '%'
				or replace(am.application_no, '.', '/')	            LIKE '%' + @p_keywords + '%'
				or ast.parking_location	                            LIKE '%' + @p_keywords + '%'
				or ast.unit_province_name	                        LIKE '%' + @p_keywords + '%'
				or ast.unit_city_name	                            LIKE '%' + @p_keywords + '%'
				or ast.status_condition                             LIKE '%' + @p_keywords + '%'
				or ast.status_remark	                            LIKE '%' + @p_keywords + '%'
				or ast.status_last_update_by	                    LIKE '%' + @p_keywords + '%'
				or ast.status_progress	                            LIKE '%' + @p_keywords + '%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ast.code
													 when 2 then ast.item_name
													 when 3 then av.plat_no
													 when 4 then am.application_no
													 when 5 then am.marketing_name
													 when 6 then cast(am.application_date as sql_variant)
													 when 7 then ast.unit_province_name
													 when 8 then ast.status_condition
													 when 9 then ast.status_progress
													 when 10 then ast.status_remark
													 when 11 then ast.status_last_update_by
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then ast.code
													 when 2 then ast.item_name
													 when 3 then av.plat_no
													 when 4 then am.application_no
													 when 5 then am.marketing_name
													 when 6 then cast(am.application_date as sql_variant)
													 when 7 then ast.unit_province_name
													 when 8 then ast.status_condition
													 when 9 then ast.status_progress
													 when 10 then ast.status_remark
													 when 11 then ast.status_last_update_by
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
