CREATE PROCEDURE [dbo].[xsp_replacement_on_hand_getrows]
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
			inner join	dbo.asset_vehicle			av	on av.asset_code	= ast.code
	where	ast.branch_code = case @p_branch_code
									when 'all' then ast.branch_code
									else @p_branch_code
								end
	and		ast.status			= 'replacement'
	and		ast.fisical_status	= 'on hand'
	and		(ast.code not in (select hr.fa_code from dbo.handover_request hr
							inner join ifinopl.dbo.asset_replacement_detail ard on ard.new_fa_code = hr.fa_code
							where hr.type in ('return in','replace out') and hr.status = 'hold')
			and ast.code not in (select hr.fa_code from dbo.handover_asset hr
							inner join ifinopl.dbo.asset_replacement_detail ard on ard.new_fa_code = hr.fa_code
							where hr.type in ('return in','replace out') and hr.status = 'hold'))
	and		(
				ast.code											like '%' + @p_keywords + '%'
				or ast.branch_code									like '%' + @p_keywords + '%'
				or ast.branch_name									like '%' + @p_keywords + '%'
				or ast.item_name									like '%' + @p_keywords + '%'
				or av.built_year									like '%' + @p_keywords + '%'
				or av.plat_no										like '%' + @p_keywords + '%'	
				or av.engine_no										like '%' + @p_keywords + '%'
				or av.chassis_no									like '%' + @p_keywords + '%'
				or convert(varchar(30), ast.purchase_date, 103)		like '%' + @p_keywords + '%'
				or convert(varchar(30), ast.posting_date, 103)		like '%' + @p_keywords + '%'
				or ast.unit_province_name						    like '%' + @p_keywords + '%'
				or ast.unit_city_name						        like '%' + @p_keywords + '%'
				or ast.parking_location						        like '%' + @p_keywords + '%'
				or ast.status_condition						        like '%' + @p_keywords + '%'
				or ast.status_progress						        like '%' + @p_keywords + '%'
				or ast.status_remark						        like '%' + @p_keywords + '%'
				or ast.status_last_update_by					    like '%' + @p_keywords + '%'
			) ;

	select		ast.code		
				,ast.branch_code
				,ast.branch_name
				,ast.item_name
				,av.built_year
				,av.plat_no
				,av.engine_no
				,av.chassis_no
				,convert(varchar(30), ast.purchase_date, 103) as purchase_date
				,convert(varchar(30), ast.posting_date, 103) as posting_date
				,ast.parking_location
				,ast.unit_province_name
				,ast.unit_city_name
				,ast.status_condition
				,ast.status_progress
				,ast.status_remark
				,ast.status_last_update_by	'last_update_by'
				,@rows_count 'rowcount'
	from	dbo.asset	ast
			inner join	dbo.asset_vehicle			av	on av.asset_code	= ast.code
	where	ast.branch_code = case @p_branch_code
									when 'all' then ast.branch_code
									else @p_branch_code
								end
	and		ast.status			= 'replacement'
	and		ast.fisical_status	= 'on hand'
	and		ast.code not in (select hr.fa_code from dbo.handover_request hr
							inner join ifinopl.dbo.asset_replacement_detail ard on ard.new_fa_code = hr.fa_code
							where hr.type in ('return in','replace out') and hr.status = 'hold')
	and		ast.code not in (select hr.fa_code from dbo.handover_asset hr
							inner join ifinopl.dbo.asset_replacement_detail ard on ard.new_fa_code = hr.fa_code
							where hr.type in ('return in','replace out') and hr.status = 'hold')
	and		(
				ast.code											like '%' + @p_keywords + '%'
				or ast.branch_code									like '%' + @p_keywords + '%'
				or ast.branch_name									like '%' + @p_keywords + '%'
				or ast.item_name									like '%' + @p_keywords + '%'
				or av.built_year									like '%' + @p_keywords + '%'
				or av.plat_no										like '%' + @p_keywords + '%'	
				or av.engine_no										like '%' + @p_keywords + '%'
				or av.chassis_no									like '%' + @p_keywords + '%'
				or convert(varchar(30), ast.purchase_date, 103)		like '%' + @p_keywords + '%'
				or convert(varchar(30), ast.posting_date, 103)		like '%' + @p_keywords + '%'
				or ast.unit_province_name						    like '%' + @p_keywords + '%'
				or ast.unit_city_name						        like '%' + @p_keywords + '%'
				or ast.parking_location						        like '%' + @p_keywords + '%'
				or ast.status_condition						        like '%' + @p_keywords + '%'
				or ast.status_progress						        like '%' + @p_keywords + '%'
				or ast.status_remark						        like '%' + @p_keywords + '%'
				or ast.status_last_update_by					    like '%' + @p_keywords + '%'
			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then ast.code
													 when 2 then ast.item_name
													 when 3 then plat_no
													 when 4 then cast(ast.purchase_date as sql_variant)
													 when 5 then ast.unit_city_name
													 when 6 then ast.status_condition
													 when 7 then ast.status_progress
													 when 8 then ast.status_remark
													 when 9 then ast.status_last_update_by
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then ast.code
													 when 2 then ast.item_name
													 when 3 then plat_no
													 when 4 then cast(ast.purchase_date as sql_variant)
													 when 5 then ast.unit_city_name
													 when 6 then ast.status_condition
													 when 7 then ast.status_progress
													 when 8 then ast.status_remark
													 when 9 then ast.status_last_update_by
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
