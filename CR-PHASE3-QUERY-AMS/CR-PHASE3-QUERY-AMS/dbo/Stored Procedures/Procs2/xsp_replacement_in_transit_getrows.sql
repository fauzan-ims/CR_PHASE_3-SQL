CREATE PROCEDURE dbo.xsp_replacement_in_transit_getrows
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
			inner join	dbo.asset_vehicle					av	on av.asset_code		= ast.code
			inner join ifinopl.dbo.asset_replacement_detail	apsd on apsd.new_fa_code	= ast.code
			inner join ifinopl.dbo.asset_replacement aps on aps.code = apsd.replacement_code
			inner join ifinopl.dbo.agreement_main ag on ag.agreement_no = aps.agreement_no
	where	ast.status = 'replacement' and aps.status in ('POST','RETURN')
	and		ast.branch_code = case @p_branch_code
										when 'all' then ast.branch_code
										else @p_branch_code
									end
	and		(ast.code in (select hr.fa_code from dbo.handover_request hr
							where hr.type in ('return in','replace out','replace gts in') and hr.status = 'hold')
			or ast.code in (select hr.fa_code from dbo.handover_asset hr
							where hr.type in ('return in','replace out', 'replace gts in') and hr.status = 'hold'))
	and		(
				ast.code										like '%' + @p_keywords + '%'
				or ast.branch_code								like '%' + @p_keywords + '%'
				or ast.branch_name								like '%' + @p_keywords + '%'
				or ast.item_name								like '%' + @p_keywords + '%'
				or av.built_year								like '%' + @p_keywords + '%'
				or av.plat_no									like '%' + @p_keywords + '%'	
				or av.engine_no									like '%' + @p_keywords + '%'
				or av.chassis_no								like '%' + @p_keywords + '%'
				or convert(varchar(30), aps.date, 103)			like '%' + @p_keywords + '%'
				or convert(varchar(30), apsd.estimate_return_date, 103)	like '%' + @p_keywords + '%'
				or convert(varchar(30), case when aps.status = 'return' then aps.mod_date else null end, 103)	like '%' + @p_keywords + '%'
				or ast.unit_city_name							like '%' + @p_keywords + '%'
				or ast.unit_province_name						like '%' + @p_keywords + '%'
				or ast.parking_location							like '%' + @p_keywords + '%'
				or ag.agreement_external_no						like '%' + @p_keywords + '%'
				or ag.client_name								like '%' + @p_keywords + '%'
			)

	select		ast.code		
				,ast.branch_code
				,ast.branch_name
				,ast.item_name
				,av.built_year
				,av.plat_no
				,av.engine_no
				,av.chassis_no
				,ast.last_km_service
				,ag.agreement_external_no
				,ag.client_name
				,convert(varchar(30), aps.date, 103) as replacement_date
				,convert(varchar(30), apsd.estimate_return_date, 103) as estimate_return_date
				,convert(varchar(30), case when aps.status = 'return' then aps.mod_date else null end, 103) as return_date
				,ast.parking_location
				,ast.unit_province_name
				,ast.unit_city_name
				,@rows_count 'rowcount'
	from	dbo.asset	ast
			inner join	dbo.asset_vehicle					av	on av.asset_code		= ast.code
			inner join ifinopl.dbo.asset_replacement_detail	apsd on apsd.new_fa_code	= ast.code
			inner join ifinopl.dbo.asset_replacement aps on aps.code = apsd.replacement_code
			inner join ifinopl.dbo.agreement_main ag on ag.agreement_no = aps.agreement_no
	where	ast.status					= 'replacement' and aps.status in ('POST','RETURN')
	and		ast.branch_code = case @p_branch_code
										when 'all' then ast.branch_code
										else @p_branch_code
									end
	and		(ast.code in (select hr.fa_code from dbo.handover_request hr
							where hr.type in ('return in','replace out','replace gts in') and hr.status = 'hold')
			or ast.code in (select hr.fa_code from dbo.handover_asset hr
							where hr.type in ('return in','replace out', 'replace gts in') and hr.status = 'hold'))
	and		(
				ast.code										like '%' + @p_keywords + '%'
				or ast.branch_code								like '%' + @p_keywords + '%'
				or ast.branch_name								like '%' + @p_keywords + '%'
				or ast.item_name								like '%' + @p_keywords + '%'
				or av.built_year								like '%' + @p_keywords + '%'
				or av.plat_no									like '%' + @p_keywords + '%'	
				or av.engine_no									like '%' + @p_keywords + '%'
				or av.chassis_no								like '%' + @p_keywords + '%'
				or convert(varchar(30), aps.date, 103)			like '%' + @p_keywords + '%'
				or convert(varchar(30), apsd.estimate_return_date, 103)	like '%' + @p_keywords + '%'
				or convert(varchar(30), case when aps.status = 'return' then aps.mod_date else null end, 103)	like '%' + @p_keywords + '%'
				or ast.unit_city_name							like '%' + @p_keywords + '%'
				or ast.unit_province_name						like '%' + @p_keywords + '%'
				or ast.parking_location							like '%' + @p_keywords + '%'
				or ag.agreement_external_no						like '%' + @p_keywords + '%'
				or ag.client_name								like '%' + @p_keywords + '%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ast.code
													 when 2 then ast.item_name
													 when 3 then av.plat_no
													 when 4 then ag.agreement_external_no
													 when 5 then cast(aps.date as sql_variant)
													 when 6 then cast(case when aps.status = 'return' then aps.mod_date else null end as sql_variant)
													 when 7 then ast.parking_location
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then ast.code
													 when 2 then ast.item_name
													 when 3 then av.plat_no
													 when 4 then ag.agreement_external_no
													 when 5 then cast(aps.date as sql_variant)
													 when 6 then cast(case when aps.status = 'return' then aps.mod_date else null end as sql_variant)
													 when 7 then ast.parking_location
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;